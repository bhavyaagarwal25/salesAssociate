extension ClientProfile {
    static let sampleProfiles: [ClientProfile] = [
        ClientProfile(
            id: "CL-1024",// unique identifier
            phone: "+91 98765 12024",
            initials: "AK",
            name: "Aisha Kapoor",
            tier: "Normal", // teir for vip purpose there is normal teir, silver tier,platinum,gold,diamond
            lifetimePurchaseAmount: 544_000,
            boutique: "Mumbai",
            lastVisit: "18 Jun",
            status: "Consent verified",
            note: "Prefers compact evening pieces, champagne tones, and gold hardware.",
            attributes: [
                ClientAttribute(title: "Size", value: "EU 38"),
                ClientAttribute(title: "Style", value: "Minimal"),
                ClientAttribute(title: "Budget", value: "Rs. 2L+"),
                ClientAttribute(title: "Preference", value: "Matte gold")
            ],
            tasks: [
                ClientTask(icon: "checkmark.shield", title: "Consent verified", subtitle: "Profile and purchase history allowed"),
                ClientTask(icon: "heart", title: "Wishlist", subtitle: "3 saved pieces"),
                ClientTask(icon: "calendar.badge.clock", title: "Follow-up", subtitle: "Tomorrow, 4 PM")
            ],
            purchaseHistory: [
                ClientPurchase(id: "PH-AK-01", productID: "HB-221", productName: "Serpenti Mini", price: "Rs. 1.84L", purchasedOn: "18 Jun", boutique: "South Mumbai"),
                ClientPurchase(id: "PH-AK-02", productID: "JW-311", productName: "Diamond Set", price: "Rs. 3.60L", purchasedOn: "04 May", boutique: "South Mumbai")
            ],
            wishlistProductIDs: ["HB-224", "HB-227", "JW-401"]
        ),
        ClientProfile(
            id: "CL-1088",
            phone: "+91 99887 41088",
            initials: "RS",
            name: "Riya Shah",
            tier: "Normal",
            lifetimePurchaseAmount: 142_000,
            boutique: "Mumbai",
            lastVisit: "20 Jun",
            status: "Consent verified",
            note: "Looking for an elegant evening clutch and rose-gold details.",
            attributes: [
                ClientAttribute(title: "Size", value: "EU 37"),
                ClientAttribute(title: "Style", value: "Classic"),
                ClientAttribute(title: "Budget", value: "Rs. 1.4L"),
                ClientAttribute(title: "Preference", value: "Rose gold")
            ],
            tasks: [
                ClientTask(icon: "checkmark.shield", title: "Consent verified", subtitle: "Profile and purchase history allowed"),
                ClientTask(icon: "heart", title: "Wishlist", subtitle: "1 saved piece"),
                ClientTask(icon: "message", title: "Follow-up", subtitle: "Friday, 1 PM")
            ],
            purchaseHistory: [
                ClientPurchase(id: "PH-RS-01", productID: "HB-301", productName: "Pearl Floral Clutch", price: "Rs. 1.42L", purchasedOn: "20 Jun", boutique: "South Mumbai")
            ],
            wishlistProductIDs: ["HB-305"]
        ),
        ClientProfile(
            id: "CL-1142",
            phone: "+91 98111 41142",
            initials: "NG",
            name: "Naina Gupta",
            tier: "Normal",
            lifetimePurchaseAmount: 420_000,
            boutique: "Mumbai",
            lastVisit: "New",
            status: "Guest context only",
            note: "Exploring diamond necklaces for a family event; no full profile consent yet.",
            attributes: [
                ClientAttribute(title: "Size", value: "One size"),
                ClientAttribute(title: "Style", value: "Statement"),
                ClientAttribute(title: "Budget", value: "Rs. 3L"),
                ClientAttribute(title: "Preference", value: "Diamond")
            ],
            tasks: [
                ClientTask(icon: "eye.slash", title: "Preference consent pending", subtitle: "Only identity is visible to sales associate"),
                ClientTask(icon: "heart", title: "Preferences pending", subtitle: "Other preferences require client consent"),
                ClientTask(icon: "calendar.badge.clock", title: "Follow-up", subtitle: "After event shortlist")
            ],
            purchaseHistory: [
                ClientPurchase(id: "PH-NG-01", productID: "JW-402", productName: "Ruby Teardrop Set", price: "Rs. 4.20L", purchasedOn: "11 Mar", boutique: "South Mumbai")
            ],
            wishlistProductIDs: ["JW-403", "JW-404"]
        ),
        ClientProfile(
            id: "CL-1176",
            phone: "+91 90044 31176",
            initials: "MI",
            name: "Meera Iyer",
            tier: "Normal",
            lifetimePurchaseAmount: 281_000,
            boutique: "Mumbai",
            lastVisit: "12 Jun",
            status: "Consent verified",// it shows that user gave their consent or not
            note: "Prefers quiet luxury, pearl tones, and lightweight handbags for travel.",
            attributes: [
                ClientAttribute(title: "Size", value: "Small"),
                ClientAttribute(title: "Style", value: "Quiet luxury"),
                ClientAttribute(title: "Budget", value: "Rs. 2.5L"),
                ClientAttribute(title: "Preference", value: "Pearl")
            ],
            tasks: [
                ClientTask(icon: "checkmark.shield", title: "Consent verified", subtitle: "Profile and purchase history allowed"),
                ClientTask(icon: "bag", title: "Open cart", subtitle: "Pearl Sling and Satin Clutch"),
                ClientTask(icon: "message", title: "Follow-up", subtitle: "Today, 6 PM")
            ],
            purchaseHistory: [
                ClientPurchase(id: "PH-MI-01", productID: "HB-227", productName: "Pearl Sling", price: "Rs. 1.26L", purchasedOn: "12 Jun", boutique: "South Mumbai"),
                ClientPurchase(id: "PH-MI-02", productID: "HB-314", productName: "Ivory Mini Top Handle", price: "Rs. 1.55L", purchasedOn: "25 Apr", boutique: "South Mumbai")
            ],
            wishlistProductIDs: ["HB-312", "HB-315"]
        ),
        ClientProfile(
            id: "CL-1219",
            phone: "+91 77770 51219",
            initials: "AM",
            name: "Arjun Mehta",
            tier: "Normal",
            lifetimePurchaseAmount: 475_000,
            boutique: "Mumbai",
            lastVisit: "10 Jun",
            status: "Consent verified",
            note: "Buying a premium gift; prefers watches and black leather details.",
            attributes: [
                ClientAttribute(title: "Size", value: "42 mm"),
                ClientAttribute(title: "Style", value: "Formal"),
                ClientAttribute(title: "Budget", value: "Rs. 5L"),
                ClientAttribute(title: "Preference", value: "Black")
            ],
            tasks: [
                ClientTask(icon: "checkmark.shield", title: "Consent verified", subtitle: "Profile and purchase history allowed"),
                ClientTask(icon: "gift", title: "Gift edit", subtitle: "Premium watch recommendation"),
                ClientTask(icon: "calendar.badge.clock", title: "Appointment", subtitle: "Saturday, 5 PM")
            ],
            purchaseHistory: [
                ClientPurchase(id: "PH-AM-01", productID: "WT-501", productName: "Heritage Chrono", price: "Rs. 4.75L", purchasedOn: "10 Jun", boutique: "South Mumbai")
            ],
            wishlistProductIDs: ["WT-602", "WT-604"]
        ),
        ClientProfile(
            id: "CL-1284",
            phone: "+91 88990 21284",
            initials: "TB",
            name: "Tara Batra",
            tier: "Normal",
            lifetimePurchaseAmount: 184_000,
            boutique: "Mumbai",
            lastVisit: "08 Jun",
            status: "Consent verified",
            note: "Likes champagne satin, crystal hardware, and compact occasion bags.",
            attributes: [
                ClientAttribute(title: "Size", value: "Mini"),
                ClientAttribute(title: "Style", value: "Evening"),
                ClientAttribute(title: "Budget", value: "Rs. 1.8L"),
                ClientAttribute(title: "Preference", value: "Champagne")
            ],
            tasks: [
                ClientTask(icon: "checkmark.shield", title: "Consent verified", subtitle: "Profile and purchase history allowed"),
                ClientTask(icon: "heart", title: "Wishlist", subtitle: "2 saved pieces"),
                ClientTask(icon: "message", title: "Follow-up", subtitle: "Next week")
            ],
            purchaseHistory: [
                ClientPurchase(id: "PH-TB-01", productID: "HB-221", productName: "Serpenti Mini", price: "Rs. 1.84L", purchasedOn: "08 Jun", boutique: "South Mumbai")
            ],
            wishlistProductIDs: ["HB-310", "AC-201"]
        )
    ]
}
