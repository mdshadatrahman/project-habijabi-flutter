import StoreKit

class SubscriptionManager: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    // MARK: - Properties
    
    // Singleton instance for easy access throughout the app
    static let shared = SubscriptionManager()
    
    // Variable to store the current subscription product
    private var product: SKProduct?
    
    // MARK: - Public Functions
    
    // Call this method to initiate the subscription purchase process
    func purchaseSubscription() {
        guard let product = product else {
            print("Error: Subscription product not available.")
            return
        }
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    // Call this to Check if the user has an active subscription
    func hasActiveSubscription() -> Bool {
        let paymentQueue = SKPaymentQueue.default()
        for transaction in paymentQueue.transactions {
            if transaction.transactionState == .purchased &&
                transaction.payment.productIdentifier == subscriptionProductID {
                return true
            }
        }
        return false
    }

    // Call this to Cancel the current subscription
    func cancelSubscription() {
        let paymentQueue = SKPaymentQueue.default()
        for transaction in paymentQueue.transactions {
            if transaction.payment.productIdentifier == subscriptionProductID {
                // Finish the transaction, update status, and show confirmation
                paymentQueue.finishTransaction(transaction)
                print("Subscription canceled: \(subscriptionProductID)")
                updateSubscriptionStatus(isCanceled: true)
                showCancellationConfirmation()
                return
            }
        }
    }

    // Update the subscription status (on server and locally)
    func updateSubscriptionStatus(isCanceled: Bool) {
	// You can implement this in flutters side as well
        // Implement logic to update server and local app state - ask mehdi bhai to update IAP and his backend
    }

    // Shows a confirmation message to the user after canceling the subscription
    // You can do this on flutter as well I guess.
    func showCancellationConfirmation() {
        let alert = UIAlertController(
            title: "Subscription Canceled",
            message: "Your subscription has been canceled.",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    // Call this method to initiate the upgrade or downgrade process
    func upgradeOrDowngradeSubscription(newProductIdentifier: String) {
        // Basically whatever new product you choose from fetched producs feed it in and request and upgrade
	// then let backend know
        let productIdentifiers: Set<String> = [newProductIdentifier]
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    // Call this method to restore previous purchases
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // MARK: - SKProductsRequestDelegate
    
    // Handle the response from the App Store when requesting product information
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let product = response.products.first {
            // Save the new product and initiate the purchase process
            self.product = product
            purchaseSubscription()
        } else {
            print("Error: No subscription products found.")
        }
    }

    // MARK: - SKPaymentTransactionObserver
    
    // Observe transaction updates
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                // Handle the purchase, provide content, and finish the transaction
		// You can return something and handle on flutters side as well if you want to. or show a native alert dialogue your choice.
                print("Purchase successful!")
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                // Handle the failed transaction again whatever you want, flutter or ios
                if let error = transaction.error {
                    print("Transaction failed with error: \(error.localizedDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                // Handle restored transaction again show a dialogue flutter or ios doesnt matter. if flutter then return a boolean or something
                print("Transaction restored successfully!")
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    // Called when the restoreCompletedTransactions() method has finished
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        // Handle restored transactions
        print("All purchases restored successfully!")
    }
}

/**
on flutter side
**/

import 'dart:ffi' as ffi;
import 'dart:io' show Platform;

// Define the Swift library
ffi.DynamicLibrary _swiftLibrary() {
 return ffi.DynamicLibrary.process();
}

// Define the Dart FFI functions
typedef PurchaseSubscriptionFunc = ffi.Void Function();
typedef HasActiveSubscriptionFunc = ffi.Uint8 Function();
typedef CancelSubscriptionFunc = ffi.Void Function();
typedef UpgradeOrDowngradeSubscriptionFunc = ffi.Void Function(ffi.Pointer<ffi.Utf8>);
typedef RestorePurchasesFunc = ffi.Void Function();

// Create Dart FFI bindings
final purchaseSubscription = _swiftLibrary()
    .lookupFunction<PurchaseSubscriptionFunc, void>('purchaseSubscription');

final hasActiveSubscription = _swiftLibrary()
    .lookupFunction<HasActiveSubscriptionFunc, int>('hasActiveSubscription');

final cancelSubscription = _swiftLibrary()
    .lookupFunction<CancelSubscriptionFunc, void>('cancelSubscription');

final upgradeOrDowngradeSubscription = _swiftLibrary()
    .lookupFunction<UpgradeOrDowngradeSubscriptionFunc, void>(
        'upgradeOrDowngradeSubscription');

final restorePurchases = _swiftLibrary()
    .lookupFunction<RestorePurchasesFunc, void>('restorePurchases');

void callSwiftFunctions() {
  // Call Swift functions
  purchaseSubscription();
  
  bool hasSubscription = hasActiveSubscription() == 1;
  print('Has active subscription: $hasSubscription');
  
  cancelSubscription();
  
  upgradeOrDowngradeSubscription(ffi.Utf8.toUtf8('newProductIdentifier'));
  
  restorePurchases();
}

//You get the idea