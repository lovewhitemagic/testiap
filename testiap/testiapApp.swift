//
//  testiapApp.swift
//  testiap
//
//  Created by Hui Peng on 2024/12/1.
//

import SwiftUI
import StoreKit

@main
struct testiapApp: App {
    @StateObject private var purchaseManager = PurchaseManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(purchaseManager)
        }
    }
}

@MainActor
class PurchaseManager: ObservableObject {
    @Published private(set) var subscriptions: [Product] = []
    @Published private(set) var purchasedSubscriptions: [Product] = []
    
    private let productIds = ["subscription.monthly", "subscription.yearly"]
    
    init() {
        print("PurchaseManager 初始化")
        
        Task {
            print("开始加载商品...")
            await loadProducts()
            await updatePurchasedProducts()
        }
        
        listenForTransactions()
    }
    
    func loadProducts() async {
        do {
            print("正在请求商品，商品ID: \(productIds)")
            let products = try await Product.products(for: productIds)
            print("API 返回商品数量: \(products.count)")
            
            if products.isEmpty {
                print("警告：没有找到任何商品")
            } else {
                for product in products {
                    print("商品信息:")
                    print("- ID: \(product.id)")
                    print("- 名称: \(product.displayName)")
                    print("- 价格: \(product.displayPrice)")
                    print("- 描述: \(product.description)")
                }
            }
            
            DispatchQueue.main.async {
                self.subscriptions = products
            }
            
        } catch {
            print("加载商品失败: \(error.localizedDescription)")
            print("错误类型: \(type(of: error))")
            
            if let nsError = error as NSError? {
                print("Domain: \(nsError.domain)")
                print("Code: \(nsError.code)")
                print("User Info: \(nsError.userInfo)")
            }
        }
    }
    
    private func updatePurchasedProducts() async {
        for await result in StoreKit.Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                purchasedSubscriptions.append(subscription)
            }
        }
    }
    
    private func listenForTransactions() {
        Task.detached {
            for await result in StoreKit.Transaction.updates {
                await self.handleTransactionResult(result)
            }
        }
    }
    
    private func handleTransactionResult(_ result: VerificationResult<StoreKit.Transaction>) async {
        guard case .verified(let transaction) = result else {
            return
        }
        
        // 完成交易
        await transaction.finish()
        
        // 更新已购买产品列表
        await updatePurchasedProducts()
    }
}
