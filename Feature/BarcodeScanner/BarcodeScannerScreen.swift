//
//  BarcodeScannerScreen.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import SwiftUI
import AVFoundation

struct BarcodeScannerScreen: View {
    
    @StateObject var state: BarcodeScannerState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cameraManager = CameraManager()
    
    var body: some View {
        NavigationStack {
            ZStack {
                CameraPreview(session: cameraManager.session)
                    .ignoresSafeArea()
                
                // Overlay с рамкой для сканирования
                VStack {
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 250, height: 250)
                    
                    Text("Наведите камеру на штрих-код")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.top, 24)
                        .shadow(color: .black, radius: 2)
                    
                    Spacer()
                }
            }
            .navigationTitle("Сканирование")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .task {
                // Ждем настройки камеры и разрешения (максимум 5 секунд)
                var attempts = 0
                while !cameraManager.isSetupComplete && attempts < 50 {
                    if cameraManager.cameraPermissionStatus == .denied {
                        // Разрешение отклонено - закрываем экран
                        dismiss()
                        return
                    }
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 секунды
                    attempts += 1
                }
                
                // Если настройка не завершилась, все равно пытаемся запустить
                if cameraManager.cameraPermissionStatus == .authorized {
                    cameraManager.startScanning { barcode in
                        state.handleScannedBarcode(barcode)
                        dismiss()
                    }
                }
            }
            .onDisappear {
                cameraManager.stopScanning()
            }
        }
    }
}

// MARK: - Camera Manager

@MainActor
class CameraManager: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private var metadataOutput = AVCaptureMetadataOutput()
    private var videoOutput: AVCaptureVideoDataOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    @Published var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    @Published var isSetupComplete: Bool = false
    
    var onBarcodeScanned: ((String) -> Void)?
    
    override init() {
        super.init()
        checkCameraPermission()
    }
    
    private func checkCameraPermission() {
        cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraPermissionStatus {
        case .authorized:
            setupCamera()
        case .notDetermined:
            requestCameraPermission()
        default:
            break
        }
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.cameraPermissionStatus = granted ? .authorized : .denied
                if granted {
                    self.setupCamera()
                }
            }
        }
    }
    
    private func setupCamera() {
        guard cameraPermissionStatus == .authorized else { return }
        
        // Настраиваем session только если она еще не настроена
        guard !isSetupComplete else { return }
        
        session.sessionPreset = .high
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        // Начинаем конфигурацию сессии
        session.beginConfiguration()
        defer { session.commitConfiguration() }
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        } else {
            return
        }
        
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            // Устанавливаем типы метаданных после добавления output
            if metadataOutput.availableMetadataObjectTypes.contains(.ean13) {
                metadataOutput.metadataObjectTypes = [.ean13, .ean8, .upce]
            }
        } else {
            return
        }
        
        isSetupComplete = true
    }
    
    func startScanning(onScanned: @escaping (String) -> Void) {
        onBarcodeScanned = onScanned
        
        guard cameraPermissionStatus == .authorized, isSetupComplete else {
            if cameraPermissionStatus == .notDetermined {
                requestCameraPermission()
            }
            return
        }
        
        guard !session.isRunning else { return }
        
        Task { @MainActor in
            session.startRunning()
        }
    }
    
    func stopScanning() {
        guard session.isRunning else { return }
        session.stopRunning()
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension CameraManager: AVCaptureMetadataOutputObjectsDelegate {
    nonisolated func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue,
              !stringValue.isEmpty else {
            // Автоматический перезапуск при ошибке (тихий) - просто продолжаем сканирование
            return
        }
        
        Task { @MainActor in
            // Останавливаем сканирование после успешного распознавания
            session.stopRunning()
            onBarcodeScanned?(stringValue)
        }
    }
}

// MARK: - Camera Preview

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> CameraPreviewView {
        let view = CameraPreviewView()
        view.setupPreview(session: session)
        return view
    }
    
    func updateUIView(_ uiView: CameraPreviewView, context: Context) {
        uiView.updateFrame()
    }
}

class CameraPreviewView: UIView {
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    func setupPreview(session: AVCaptureSession) {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        self.layer.addSublayer(layer)
        self.previewLayer = layer
        updateFrame()
    }
    
    func updateFrame() {
        previewLayer?.frame = bounds
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrame()
    }
}

