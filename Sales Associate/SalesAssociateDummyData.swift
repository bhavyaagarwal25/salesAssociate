extension SalesAssociateDashboard {
    static let sample = SalesAssociateDashboard(
        associate: AssociateProfile(
            initials: "SA",
            role: "Sales Associate",
            boutique: "South Mumbai"
        ),
        monthlyGoal: SalesGoal(
            title: "Monthly Sales Goal",
            progress: 0.68,
            achieved: "Rs. 4.8L",
            target: "Rs. 7.0L"
        ),
        priorityItems: [
            PriorityItem(
                icon: "crown",
                title: "VIP appointment",
                subtitle: "Aisha Kapoor, 12:30 PM",
                badge: "Now"
            ),
            PriorityItem(
                icon: "camera",
                title: "Display photos",
                subtitle: "Upload pending for planogram",
                badge: nil
            )
        ],
        quickActions: [
            QuickAction(icon: "person.badge.plus", title: "Start Client", isPrimary: true),
            QuickAction(icon: "calendar.badge.clock", title: "Appointments", isPrimary: false),
            QuickAction(icon: "list.clipboard", title: "Issue", isPrimary: false),
            QuickAction(icon: "viewfinder", title: "Scan Item", isPrimary: false)
        ],
        metrics: [
            DashboardMetric(title: "Open Carts", value: "11"),
            DashboardMetric(title: "Follow-ups", value: "09"),
            DashboardMetric(title: "VIP Today", value: "03")
        ],
        weeklySales: WeeklySalesSummary(
            total: "Rs. 1.18L",
            change: "+12%",
            comparison: "Compared with last week",
            bestDay: "Fri",
            bestDayLabel: "Best sales day",
            days: [
                DailySales(day: "Mon", amount: "12k", progress: 0.42, isBest: false),
                DailySales(day: "Tue", amount: "16k", progress: 0.55, isBest: false),
                DailySales(day: "Wed", amount: "14k", progress: 0.48, isBest: false),
                DailySales(day: "Thu", amount: "19k", progress: 0.66, isBest: false),
                DailySales(day: "Fri", amount: "25k", progress: 0.86, isBest: true),
                DailySales(day: "Sat", amount: "21k", progress: 0.74, isBest: false),
                DailySales(day: "Sun", amount: "11k", progress: 0.39, isBest: false)
            ]
        )
    )
}

extension StockDashboard {
    static let sample = StockDashboard(
        metrics: [
            StockMetric(title: "In Boutique", value: "18", detail: "sellable pieces"),
            StockMetric(title: "SM Review", value: "03", detail: "fulfillment checks"),
            StockMetric(title: "Scanned Today", value: "12", detail: "certificate checks")
        ],
        issueTypes: [
            StockIssueType(id: "missing", title: "Missing", icon: "exclamationmark.triangle", description: "Received quantity is lower than the inventory handoff count."),
            StockIssueType(id: "damage", title: "Damage", icon: "sparkle.magnifyingglass", description: "Item arrived damaged during inventory handoff or transit."),
            StockIssueType(id: "mismatch", title: "Mismatch", icon: "tag", description: "Received item does not match the expected box, tag, or name.")
        ],
        scanChecks: [
            StockScanCheck(title: "SKU matched", status: "HB-221 verified", icon: "checkmark.seal"),
            StockScanCheck(title: "Certificate", status: "Authenticity record found", icon: "doc.text.magnifyingglass"),
            StockScanCheck(title: "Store status", status: "Available for selling", icon: "shippingbox")
        ],
        reviews: [
            StoreManagerReview(
                title: "Missing quantity reviewed",
                status: "Approved follow-up",
                note: "SM confirmed short receipt and routed it to Inventory Controller.",
                time: "Today, 10:05 AM",
                icon: "checkmark.seal"
            ),
            StoreManagerReview(
                title: "Damage photo checked",
                status: "More evidence needed",
                note: "Upload a closer photo of clasp and packaging seal.",
                time: "Yesterday, 6:20 PM",
                icon: "camera.macro"
            )
        ]
    )
}

extension IssueDashboard {
    static let sample = IssueDashboard(
        returnExchangeTypes: ["Return", "Exchange", "Cancellation"],
        serviceTypes: ["Cleaning", "Authentication", "Warranty", "Resize / Adjustment"],
        repairStatuses: ["Assessment pending", "Receipt generated", "Client informed", "SM review needed"],
        historyItems: [
            IssueHistoryItem(
                title: "Exchange exception",
                requestType: "Return / Exchange",
                status: .approved,
                note: "SM approved exchange after receipt and product condition check.",
                time: "Today, 9:40 AM",
                icon: "arrow.left.arrow.right"
            ),
            IssueHistoryItem(
                title: "Clasp repair estimate",
                requestType: "Repair",
                status: .pending,
                note: "Waiting for SM review on repair charge before sharing final receipt.",
                time: "Yesterday, 6:15 PM",
                icon: "wrench.adjustable"
            ),
            IssueHistoryItem(
                title: "Late return request",
                requestType: "Return / Exchange",
                status: .rejected,
                note: "Return window exceeded and exception was not approved.",
                time: "22 Jun, 4:30 PM",
                icon: "xmark.seal"
            )
        ]
    )
}

extension ProductCategory {
    static let sampleCategories: [ProductCategory] = [
        ProductCategory(id: "handbags", title: "Handbags", icon: "handbag"),
        ProductCategory(id: "watches", title: "Watches", icon: "applewatch"),
        ProductCategory(id: "jewellery", title: "Jewellery", icon: "sparkles"),
        ProductCategory(id: "footwear", title: "Footwear", icon: "shoeprints.fill"),
        ProductCategory(id: "accessories", title: "Accessories", icon: "sunglasses")
    ]
}

extension SalesProduct {
    static let sampleProducts: [SalesProduct] = [
        SalesProduct(
            id: "HB-221",
            name: "Serpenti Mini",
            categoryID: "handbags",
            audience: "Women",
            price: "Rs. 1.84L",
            originalPrice: "Rs. 2.05L",
            imageName: "ProductSerpentiMini",
            badge: "Client fit",
            availability: "In boutique",
            stockNote: "1 piece available in South Mumbai boutique",
            sizes: ["Mini", "Small"],
            materials: ["Champagne satin", "Crystal handle"],
            colors: ["Champagne", "Black"],
            suggestedReason: "Matches evening event and gold hardware preference",
            isWishlisted: true
        ),
        SalesProduct(
            id: "HB-224",
            name: "Noir Clutch",
            categoryID: "handbags",
            audience: "Women",
            price: "Rs. 2.10L",
            originalPrice: nil,
            imageName: "ProductNoirClutch",
            badge: "Limited",
            availability: "Store Manager visible",
            stockNote: "Not in boutique. Store Manager can review transfer or reorder.",
            sizes: ["Mini"],
            materials: ["Black satin", "Crystal arc"],
            colors: ["Black"],
            suggestedReason: "Best for formal evening looks",
            isWishlisted: false
        ),
        SalesProduct(
            id: "HB-227",
            name: "Pearl Sling",
            categoryID: "handbags",
            audience: "Women",
            price: "Rs. 1.26L",
            originalPrice: nil,
            imageName: "ProductPearlSling",
            badge: nil,
            availability: "In boutique",
            stockNote: "2 pieces available for immediate checkout",
            sizes: ["Small", "Medium"],
            materials: ["Pearl leather", "Gold hardware"],
            colors: ["Ivory", "Pearl"],
            suggestedReason: "Soft neutral option for guest clients",
            isWishlisted: false
        ),
        SalesProduct(
            id: "JW-311",
            name: "Diamond Set",
            categoryID: "jewellery",
            audience: "Women",
            price: "Rs. 3.60L",
            originalPrice: nil,
            imageName: "ProductDiamondSet",
            badge: "VIP",
            availability: "In boutique",
            stockNote: "Display-ready hero set available",
            sizes: ["One size"],
            materials: ["Diamond", "White gold"],
            colors: ["Silver", "Platinum"],
            suggestedReason: "Premium showcase piece for VIP previews",
            isWishlisted: true
        ),
        SalesProduct(
            id: "JW-322",
            name: "Art Deco Necklace",
            categoryID: "jewellery",
            audience: "Women",
            price: "Rs. 2.48L",
            originalPrice: "Rs. 2.70L",
            imageName: "ProductArtDeco",
            badge: "New",
            availability: "In boutique",
            stockNote: "Available after authentication scan",
            sizes: ["One size"],
            materials: ["White gold", "Blue velvet set"],
            colors: ["Silver", "Midnight"],
            suggestedReason: "Strong match for statement jewellery requests",
            isWishlisted: false
        ),
        SalesProduct(
            id: "AC-114",
            name: "Satin Evening Clutch",
            categoryID: "accessories",
            audience: "Women",
            price: "Rs. 1.58L",
            originalPrice: nil,
            imageName: "ProductSatinClutch",
            badge: "Gift edit",
            availability: "In boutique",
            stockNote: "Ready for packaging and gift note",
            sizes: ["Compact"],
            materials: ["Pearl satin", "Crystal clasp"],
            colors: ["Ivory", "Champagne"],
            suggestedReason: "Good fallback for guest profile styling",
            isWishlisted: false
        ),
        SalesProduct(
            id: "WT-501",
            name: "Heritage Chrono",
            categoryID: "watches",
            audience: "Men",
            price: "Rs. 4.75L",
            originalPrice: nil,
            imageName: "ProductArtDeco",
            badge: "Men",
            availability: "By transfer",
            stockNote: "Available from partner store after Store Manager review",
            sizes: ["40 mm", "42 mm"],
            materials: ["Steel", "Leather strap"],
            colors: ["Black", "Silver"],
            suggestedReason: "Men's gifting recommendation for high-value clients",
            isWishlisted: false
        )
    ]
}
