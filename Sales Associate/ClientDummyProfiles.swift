extension ClientProfile {
    static let sampleProfiles: [ClientProfile] = [
        ClientProfile(
            id: "CL-1024",
            phone: "+91 98765 12024",
            initials: "AK",
            name: "Aisha Kapoor",
            tier: "Platinum Tier",
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
            ]
        ),
        ClientProfile(
            id: "CL-1088",
            phone: "+91 99887 41088",
            initials: "RS",
            name: "Riya Shah",
            tier: "Gold Tier",
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
            ]
        ),
        ClientProfile(
            id: "CL-1142",
            phone: "+91 98111 41142",
            initials: "NG",
            name: "Naina Gupta",
            tier: "Guest Profile",
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
                ClientTask(icon: "person.crop.circle.badge.plus", title: "Guest profile", subtitle: "Use consent only if client agrees"),
                ClientTask(icon: "sparkles", title: "VIP preview", subtitle: "Show diamond showcase pieces"),
                ClientTask(icon: "calendar.badge.clock", title: "Follow-up", subtitle: "After event shortlist")
            ]
        ),
        ClientProfile(
            id: "CL-1176",
            phone: "+91 90044 31176",
            initials: "MI",
            name: "Meera Iyer",
            tier: "Diamond Tier",
            boutique: "Mumbai",
            lastVisit: "12 Jun",
            status: "Consent verified",
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
            ]
        ),
        ClientProfile(
            id: "CL-1219",
            phone: "+91 77770 51219",
            initials: "AM",
            name: "Arjun Mehta",
            tier: "Platinum Tier",
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
            ]
        ),
        ClientProfile(
            id: "CL-1284",
            phone: "+91 88990 21284",
            initials: "TB",
            name: "Tara Batra",
            tier: "Gold Tier",
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
            ]
        )
    ]
}
