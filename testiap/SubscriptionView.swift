import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @State private var isPurchasing = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("升级会员")
                    .font(.title)
                    .padding(.top)
                
                if purchaseManager.subscriptions.isEmpty {
                    ProgressView()
                } else {
                    ForEach(purchaseManager.subscriptions, id: \.id) { product in
                        SubscriptionCard(product: product)
                            .onTapGesture {
                                Task {
                                    await purchase(product)
                                }
                            }
                    }
                }
            }
            .padding()
            .navigationBarItems(trailing: Button("关闭") {
                dismiss()
            })
        }
    }
    
    private func purchase(_ product: Product) async {
        do {
            isPurchasing = true
            let result = try await product.purchase()
            switch result {
            case .success(let verificationResult):
                switch verificationResult {
                case .verified(let transaction):
                    await transaction.finish()
                    dismiss()
                case .unverified:
                    print("Transaction unverified")
                }
            case .userCancelled:
                break
            case .pending:
                break
            @unknown default:
                break
            }
        } catch {
            print("Failed to purchase: \(error)")
        }
        isPurchasing = false
    }
}

struct SubscriptionCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(product.displayName)
                .font(.headline)
            
            Text(product.description)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Text(product.displayPrice)
                    .font(.title2)
                    .bold()
                
                if product.id.contains("yearly") {
                    Text("省钱")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .cornerRadius(4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    SubscriptionView()
        .environmentObject(PurchaseManager())
} 