import SwiftUI

struct SalesAssociateDashboard {
    let associate: AssociateProfile
    let monthlyGoal: SalesGoal
    let priorityItems: [PriorityItem]
    let quickActions: [QuickAction]
    let metrics: [DashboardMetric]
    let weeklySales: WeeklySalesSummary
}

struct AssociateProfile {
    let initials: String
    let role: String
    let boutique: String
}

struct SalesGoal {
    let title: String
    let progress: Double
    let achieved: String
    let target: String

    var percentageText: String {
        "\(Int(progress * 100))%"
    }

    var detailText: String {
        "\(achieved) achieved from \(target) target"
    }
}

struct PriorityItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let badge: String?
}

struct QuickAction: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let isPrimary: Bool
}

struct DashboardMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
}

struct WeeklySalesSummary {
    let total: String
    let change: String
    let comparison: String
    let bestDay: String
    let bestDayLabel: String
    let days: [DailySales]
}

struct DailySales: Identifiable {
    let id = UUID()
    let day: String
    let amount: String
    let progress: Double
    let isBest: Bool
}

struct ClientProfile: Identifiable, Equatable {
    let id: String
    let phone: String
    let initials: String
    let name: String
    let tier: String
    let boutique: String
    let lastVisit: String
    let status: String
    let note: String
    let attributes: [ClientAttribute]
    let tasks: [ClientTask]

    func matches(_ query: String) -> Bool {
        let normalizedQuery = query
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !normalizedQuery.isEmpty else { return false }

        return name.lowercased().contains(normalizedQuery)
            || id.lowercased().contains(normalizedQuery)
            || phone.lowercased().contains(normalizedQuery)
    }
}

struct ClientAttribute: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let value: String
}

struct ClientTask: Identifiable, Equatable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
}

struct ProductCategory: Identifiable, Equatable {
    let id: String
    let title: String
    let icon: String
}

struct SalesProduct: Identifiable, Equatable {
    let id: String
    let name: String
    let categoryID: String
    let audience: String
    let price: String
    let originalPrice: String?
    let imageName: String
    let badge: String?
    let availability: String
    let stockNote: String
    let sizes: [String]
    let materials: [String]
    let colors: [String]
    let suggestedReason: String
    let isWishlisted: Bool

    func matches(_ query: String) -> Bool {
        let normalizedQuery = query
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !normalizedQuery.isEmpty else { return false }

        return id.lowercased().contains(normalizedQuery)
            || name.lowercased().contains(normalizedQuery)
            || categoryID.lowercased().contains(normalizedQuery)
    }
}

struct StockDashboard {
    let metrics: [StockMetric]
    let issueTypes: [StockIssueType]
    let scanChecks: [StockScanCheck]
    let reviews: [StoreManagerReview]
}

struct StockMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let detail: String
}

struct StockIssueType: Identifiable, Equatable {
    let id: String
    let title: String
    let icon: String
    let description: String
}

struct StockScanCheck: Identifiable {
    let id = UUID()
    let title: String
    let status: String
    let icon: String
}

struct StoreManagerReview: Identifiable {
    let id = UUID()
    let title: String
    let status: String
    let note: String
    let time: String
    let icon: String
}

struct IssueDashboard {
    let returnExchangeTypes: [String]
    let serviceTypes: [String]
    let repairStatuses: [String]
    let historyItems: [IssueHistoryItem]
}

struct IssueHistoryItem: Identifiable {
    let id = UUID()
    let title: String
    let requestType: String
    let status: IssueApprovalStatus
    let note: String
    let time: String
    let icon: String
}

enum IssueApprovalStatus: String {
    case approved = "Approved"
    case rejected = "Rejected"
    case pending = "Pending"
}
