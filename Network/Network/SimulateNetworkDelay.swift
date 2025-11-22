//
//  SimulateNetworkDelay.swift
//  RequestKit
//
//  Created by aristarh on 16.11.2025.
//


func simulateNetworkDelay() async {
    let nanosecondsDelay = UInt64.random(in: 300_000_000...2_000_000_000)
    try? await Task.sleep(nanoseconds: nanosecondsDelay)
}