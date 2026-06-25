import Foundation

enum SellingSessionPanel: Equatable {
    case wishlist
    case cart
    case createProfile
}

struct SellingSessionState: Equatable {
    var guestID: String?
    var wishlistProductIDs: [String] = []
    var cartProductIDs: [String] = []
    var cartQuantitiesByProductID: [String: Int] = [:]
    var createdClient: ClientProfile?
    var activePanel: SellingSessionPanel?

    var hasActiveClient: Bool {
        guestID != nil || createdClient != nil
    }

    var displayName: String {
        createdClient?.name ?? guestID ?? "Guest client"
    }

    var hasCreatedProfile: Bool {
        createdClient != nil
    }

    var wishlistItemCount: Int {
        wishlistProductIDs.count
    }

    var cartItemCount: Int {
        cartQuantitiesByProductID.values.reduce(0, +)
    }

    mutating func startNewGuest() {
        guestID = "GUEST-\(Int.random(in: 1000...9999))"
        wishlistProductIDs = []
        cartProductIDs = []
        cartQuantitiesByProductID = [:]
        createdClient = nil
        activePanel = nil
    }

    mutating func startForClient(_ client: ClientProfile) {
        guestID = nil
        wishlistProductIDs = []
        cartProductIDs = []
        cartQuantitiesByProductID = [:]
        createdClient = client
        activePanel = nil
    }

    mutating func discard() {
        guestID = nil
        wishlistProductIDs = []
        cartProductIDs = []
        cartQuantitiesByProductID = [:]
        createdClient = nil
        activePanel = nil
    }

    mutating func toggleWishlist(_ product: SalesProduct) {
        if wishlistProductIDs.contains(product.id) {
            wishlistProductIDs.removeAll { $0 == product.id }
        } else {
            wishlistProductIDs.append(product.id)
        }
    }

    mutating func addToCart(_ product: SalesProduct, quantity: Int = 1) {
        let resolvedQuantity = max(1, quantity)
        if !cartProductIDs.contains(product.id) {
            cartProductIDs.append(product.id)
        }
        cartQuantitiesByProductID[product.id, default: 0] += resolvedQuantity
    }

    mutating func moveWishlistToCart() {
        for productID in wishlistProductIDs {
            if !cartProductIDs.contains(productID) {
                cartProductIDs.append(productID)
            }
            cartQuantitiesByProductID[productID, default: 0] += 1
        }
        wishlistProductIDs = []
        activePanel = .cart
    }

    func isWishlisted(_ product: SalesProduct) -> Bool {
        wishlistProductIDs.contains(product.id)
    }

    func isInCart(_ product: SalesProduct) -> Bool {
        cartProductIDs.contains(product.id)
    }

    func quantity(for product: SalesProduct) -> Int {
        cartQuantitiesByProductID[product.id] ?? 0
    }
}
