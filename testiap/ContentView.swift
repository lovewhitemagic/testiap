//
//  ContentView.swift
//  testiap
//
//  Created by Hui Peng on 2024/12/1.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    @State private var showSubscription = false
    @EnvironmentObject private var purchaseManager: PurchaseManager

    var body: some View {
        VStack(spacing: 20) {
            Button(action: { showSubscription = true }) {
                Text("升级会员")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            #if DEBUG
            Button(action: {
                Task {
                    await purchaseManager.loadProducts()
                }
            }) {
                Text("重新加载商品")
                    .font(.caption)
            }
            #endif
        }
        .sheet(isPresented: $showSubscription) {
            SubscriptionView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PurchaseManager())
}
