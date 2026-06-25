import SwiftUI

struct ContentView: View {
    @State private var selectedTab: SalesAssociateTab = .today
    @State private var navigationMode: SalesNavigationMode = .sidebar
    @State private var recentlyViewedClients: [ClientProfile] = []
    @State private var clientProfiles = ClientProfileJSONStore.loadProfiles()
    @State private var sellingSession = SellingSessionState()

    private let dashboard = SalesAssociateDashboard.sample
    private let categories = ProductCategory.sampleCategories
    private let products = SalesProduct.sampleProducts
    private let stockDashboard = StockDashboard.sample
    private let issueDashboard = IssueDashboard.sample

//Dashboard Navigation Controller
    var body: some View {
        TodayDashboardView(
            dashboard: dashboard,
            clientProfiles: $clientProfiles,
            categories: categories,
            products: products,
            stockDashboard: stockDashboard,
            issueDashboard: issueDashboard,
            selectedTab: $selectedTab,
            navigationMode: $navigationMode,
            recentlyViewedClients: $recentlyViewedClients,
            sellingSession: $sellingSession
        )
    }
}

enum SalesNavigationMode: Equatable {
    case sidebar
    case top
}

struct TodayDashboardView: View {
    let dashboard: SalesAssociateDashboard
    @Binding var clientProfiles: [ClientProfile]
    let categories: [ProductCategory]
    let products: [SalesProduct]
    let stockDashboard: StockDashboard
    let issueDashboard: IssueDashboard

    @Binding var selectedTab: SalesAssociateTab
    @Binding var navigationMode: SalesNavigationMode
    @Binding var recentlyViewedClients: [ClientProfile]
    @Binding var sellingSession: SellingSessionState
    @State private var isAssociateProfilePresented = false

    var body: some View {
        GeometryReader { proxy in
            Group {
                switch navigationMode {
                case .sidebar:
                    HStack(spacing: 0) {
                        SidebarView(
                            associate: dashboard.associate,
                            selectedTab: $selectedTab,
                            navigationMode: $navigationMode,
                            onProfileTap: {
                                isAssociateProfilePresented = true
                            }
                        )
                        .frame(width: sidebarWidth(for: proxy.size.width))

                        content
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                case .top:
                    VStack(spacing: 0) {
                        TopNavigationBar(
                            selectedTab: $selectedTab,
                            navigationMode: $navigationMode
                        )

                        content
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .background(Theme.background)
            .animation(.snappy(duration: 0.26), value: navigationMode)
            .sheet(isPresented: $isAssociateProfilePresented) {
                AssociateProfileSheet(associate: dashboard.associate)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch selectedTab {
        case .today:
            DashboardContent(
                dashboard: dashboard,
                onStartClient: startGuestSelling
            )
        case .client:
            ClientelingContent(
                availableClients: clientProfiles,
                onStartGuestClient: startGuestSelling,
                onBuildCuratedCart: startClientSelling,
                recentlyViewedClients: $recentlyViewedClients
            )
        case .sell:
            SellContent(
                categories: categories,
                products: products,
                session: $sellingSession,
                onDiscardClient: discardSellingSession,
                onCreateProfile: saveCreatedProfile
            )
        case .stock:
            StockContent(dashboard: stockDashboard, products: products)
        case .issue:
            IssueContent(dashboard: issueDashboard, products: products)
        }
    }

    private func sidebarWidth(for width: CGFloat) -> CGFloat {
        width > 900 ? 210 : 150
    }

    private func startGuestSelling() {
        sellingSession.startNewGuest()
        selectedTab = .sell
    }

    private func startClientSelling(_ client: ClientProfile) {
        sellingSession.startForClient(client)
        selectedTab = .sell
    }

    private func discardSellingSession() {
        sellingSession.discard()
        selectedTab = .today
    }

    private func saveCreatedProfile(_ profile: ClientProfile) {
        clientProfiles.removeAll { $0.id == profile.id }
        clientProfiles.insert(profile, at: 0)
        ClientProfileJSONStore.saveProfiles(clientProfiles)
        recentlyViewedClients.removeAll { $0.id == profile.id }
        recentlyViewedClients.insert(profile, at: 0)
    }
}

enum SalesAssociateTab: String, CaseIterable, Identifiable {
    case today = "Today"
    case client = "Clienteling"
    case sell = "Sell"
    case stock = "Stock"
    case issue = "Issue"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .today:
            return "square.grid.2x2"
        case .client:
            return "person"
        case .sell:
            return "bag"
        case .stock:
            return "shippingbox"
        case .issue:
            return "list.clipboard"
        }
    }
}

//Dashboard content view
private struct DashboardContent: View {
    let dashboard: SalesAssociateDashboard
    let onStartClient: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                HeaderBar()

                HStack(alignment: .top, spacing: 18) {
                    VStack(spacing: 18) {
                        MonthlyGoalCard(goal: dashboard.monthlyGoal)
                        WeeklySalesCard(summary: dashboard.weeklySales)
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: 18) {
                        PriorityQueueCard(items: dashboard.priorityItems)
                        QuickActionsCard(
                            actions: dashboard.quickActions,
                            metrics: dashboard.metrics,
                            onStartClient: onStartClient
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 22)
        }
        .scrollIndicators(.hidden)
    }
}

// Header Bar view
private struct HeaderBar: View {
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("9:41")
                    .font(.headline.weight(.bold))
                Text("Today")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.ink)
            }

            Spacer()

            Button {
            } label: {
                Image(systemName: "bell")
                    .font(.title3.weight(.semibold))
                    .frame(width: 54, height: 54)
                    .background(.white.opacity(0.76), in: Circle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(Theme.ink)
        }
    }
}

//Sidebar Navigation Menu
private struct SidebarView: View {
    let associate: AssociateProfile

    @Binding var selectedTab: SalesAssociateTab
    @Binding var navigationMode: SalesNavigationMode
    let onProfileTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(spacing: 12) {
                ForEach(SalesAssociateTab.allCases) { tab in
                    SidebarItem(
                        tab: tab,
                        isSelected: selectedTab == tab
                    ) {
                        selectedTab = tab
                    }
                }
            }
            .padding(.top, 58)

            Spacer()

            SidebarAssociateProfileButton(
                associate: associate,
                action: onProfileTap
            )
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 22)
        .background(.white.opacity(0.55))
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(Theme.line)
                .frame(width: 1)
        }
        .contentShape(Rectangle())
        .gesture(sidebarCollapseGesture)
        .accessibilityAction(named: "Collapse Sidebar") {
            navigationMode = .top
        }
    }

    private var sidebarCollapseGesture: some Gesture {
        DragGesture(minimumDistance: 32, coordinateSpace: .local)
            .onEnded { value in
                let horizontalDrag = abs(value.translation.width) > abs(value.translation.height)

                guard horizontalDrag, value.translation.width < -70 else { return }

                withAnimation(.snappy(duration: 0.26)) {
                    navigationMode = .top
                }
            }
    }
}

private struct TopNavigationBar: View {
    @Binding var selectedTab: SalesAssociateTab
    @Binding var navigationMode: SalesNavigationMode

    var body: some View {
        HStack(spacing: 14) {
            Spacer(minLength: 0)

            HStack(spacing: 12) {
                NavigationModeButton(symbol: "sidebar.left") {
                    navigationMode = .sidebar
                }
                .frame(width: 52)

                HStack(spacing: 8) {
                    ForEach(SalesAssociateTab.allCases) { tab in
                        TopNavigationItem(
                            tab: tab,
                            isSelected: selectedTab == tab
                        ) {
                            selectedTab = tab
                        }
                    }
                }
                .padding(6)
                .background(.white.opacity(0.62), in: Capsule())
                .overlay(
                    Capsule()
                        .stroke(Theme.line.opacity(0.6), lineWidth: 1)
                )
            }
            .fixedSize(horizontal: true, vertical: false)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 16)
        .background(.white.opacity(0.54))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Theme.line)
                .frame(height: 1)
        }
    }
}

//Top Navigation view
private struct TopNavigationItem: View {
    let tab: SalesAssociateTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(tab.rawValue, systemImage: tab.symbol)
                .font(.subheadline.weight(.black))
                .lineLimit(1)
                .padding(.horizontal, 16)
                .frame(height: 44)
                .foregroundStyle(isSelected ? .white : Theme.muted)
                .background(
                    isSelected ? AnyShapeStyle(Theme.bestBar) : AnyShapeStyle(.clear),
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
    }
}

private struct NavigationModeButton: View {
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.headline.weight(.black))
                .frame(maxWidth: .infinity, minHeight: 44)
                .foregroundStyle(Theme.gold)
                .background(.white.opacity(0.70), in: Capsule())
                .overlay(
                    Capsule()
                        .stroke(Theme.line.opacity(0.62), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Show Sidebar")
    }
}

// SideBar items
private struct SidebarItem: View {
    let tab: SalesAssociateTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: tab.symbol)
                    .font(.headline)
                    .frame(width: 22)
                Text(tab.rawValue)
                    .font(.headline.weight(.bold))
            }
            .foregroundStyle(isSelected ? Theme.gold : Theme.muted)
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
            .padding(.horizontal, 14)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 17, style: .continuous)
                        .fill(Theme.selected)
                        .overlay(
                            RoundedRectangle(cornerRadius: 17, style: .continuous)
                                .stroke(Theme.line, lineWidth: 1)
                        )
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct SidebarAssociateProfileButton: View {
    let associate: AssociateProfile
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(associate.initials)
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(Theme.goldGradient, in: RoundedRectangle(cornerRadius: 15, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(associate.name)
                        .font(.headline.weight(.black))
                        .foregroundStyle(Theme.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    Text(associate.role)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.muted)
                        .lineLimit(1)
                    Text(associate.boutique)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Theme.muted.opacity(0.85))
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 76, alignment: .leading)
            .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Theme.line.opacity(0.62), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open sales associate profile")
    }
}

private struct AssociateProfileSheet: View {
    let associate: AssociateProfile
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top, spacing: 14) {
                Text(associate.initials)
                    .font(.title.weight(.black))
                    .foregroundStyle(.white)
                    .frame(width: 68, height: 68)
                    .background(Theme.goldGradient, in: RoundedRectangle(cornerRadius: 22, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    Text(associate.name)
                        .font(.title2.weight(.black))
                        .foregroundStyle(Theme.ink)
                    Text(associate.role)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Theme.muted)
                    Text(associate.boutique)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Theme.gold)
                }

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline.weight(.black))
                        .foregroundStyle(Theme.muted)
                        .frame(width: 42, height: 42)
                        .background(.white.opacity(0.74), in: Circle())
                }
                .buttonStyle(.plain)
            }

            VStack(spacing: 12) {
                AssociateProfileInfoRow(title: "Email", value: associate.email, icon: "envelope")
                AssociateProfileInfoRow(title: "Phone", value: associate.phone, icon: "phone")
                AssociateProfileInfoRow(title: "Employee ID", value: associate.employeeID, icon: "person.text.rectangle")
                AssociateProfileInfoRow(title: "Shift", value: associate.shift, icon: "clock")
                AssociateProfileInfoRow(title: "Permissions", value: "Clienteling, selling, stock visibility, issue intake", icon: "checkmark.shield")
            }

            Spacer(minLength: 0)
        }
        .padding(26)
        .frame(minWidth: 420, minHeight: 430)
        .background(Theme.background)
    }
}

private struct AssociateProfileInfoRow: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.headline.weight(.black))
                .foregroundStyle(Theme.gold)
                .frame(width: 44, height: 44)
                .background(Theme.selected, in: RoundedRectangle(cornerRadius: 15, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(title.uppercased())
                    .font(.caption.weight(.black))
                    .tracking(1.1)
                    .foregroundStyle(Theme.muted)
                Text(value)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Theme.line.opacity(0.45), lineWidth: 1)
        )
    }
}

// client content
private struct ClientelingContent: View {
    let availableClients: [ClientProfile]
    let onStartGuestClient: () -> Void
    let onBuildCuratedCart: (ClientProfile) -> Void

    @Binding var recentlyViewedClients: [ClientProfile]

    @State private var query = ""
    @State private var selectedClient: ClientProfile?
    @State private var missedSearchTerm: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                ClientHeader()

                HStack(alignment: .top, spacing: 18) {
                    if let selectedClient {
                        ClientSearchPanel(
                            query: $query,
                            clients: recentlyViewedClients,
                            selectedClient: $selectedClient,
                            missedSearchTerm: $missedSearchTerm,
                            onSearch: searchExistingClient,
                            onSelectClient: openClientProfile,
                            onStartClient: onStartGuestClient
                        )
                        .frame(width: 318)

                        ClientDetailCard(
                            client: selectedClient,
                            onBuildCuratedCart: {
                                onBuildCuratedCart(selectedClient)
                            }
                        )
                            .frame(maxWidth: .infinity)
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                    } else {
                        ClientSearchPanel(
                            query: $query,
                            clients: recentlyViewedClients,
                            selectedClient: $selectedClient,
                            missedSearchTerm: $missedSearchTerm,
                            onSearch: searchExistingClient,
                            onSelectClient: openClientProfile,
                            onStartClient: onStartGuestClient
                        )
                        .frame(maxWidth: .infinity)
                    }
                }
                .animation(.snappy(duration: 0.28), value: selectedClient)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 22)
        }
        .scrollIndicators(.hidden)
    }

//search the existing client
    private func searchExistingClient() {
        let searchTerm = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !searchTerm.isEmpty else {
            missedSearchTerm = nil
            return
        }

        guard let match = availableClients.first(where: { $0.matches(searchTerm) }) else {
            missedSearchTerm = searchTerm
            return
        }

        missedSearchTerm = nil
        rememberRecentlyViewed(match)
        query = ""
    }

    private func openClientProfile(_ client: ClientProfile) {
        rememberRecentlyViewed(client)
        selectedClient = client
    }

    private func rememberRecentlyViewed(_ client: ClientProfile) {
        recentlyViewedClients.removeAll { $0.id == client.id }
        recentlyViewedClients.insert(client, at: 0)
    }
}

private struct ClientHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("9:41")
                .font(.headline.weight(.bold))
            Text("Clienteling")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ClientSearchPanel: View {
    @Binding var query: String
    let clients: [ClientProfile]
    @Binding var selectedClient: ClientProfile?
    @Binding var missedSearchTerm: String?
    let onSearch: () -> Void
    let onSelectClient: (ClientProfile) -> Void
    let onStartClient: () -> Void

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Theme.muted)

                    TextField("Search clients, phone, ID", text: $query)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.search)
                        .onSubmit(onSearch)
                        .onChange(of: query) { _, _ in
                            missedSearchTerm = nil
                        }

                    if !query.isEmpty {
                        Button {
                            query = ""
                            missedSearchTerm = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Theme.muted.opacity(0.7))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .font(.headline.weight(.semibold))
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
                .background(.white.opacity(0.70), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Theme.line.opacity(0.55), lineWidth: 1)
                )

                if let missedSearchTerm {
                    NoProfileFoundCard(searchTerm: missedSearchTerm, onStartClient: onStartClient)
                }

                if !clients.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recently Viewed")
                            .font(.caption.weight(.black))
                            .tracking(1.1)
                            .foregroundStyle(Theme.muted)
                            .padding(.horizontal, 4)

                        ForEach(clients) { client in
                            Button {
                                onSelectClient(client)
                            } label: {
                                ClientResultRow(
                                    client: client,
                                    isSelected: selectedClient == client
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 490, alignment: .top)
        }
    }
}

// if there is no profile avialable
private struct NoProfileFoundCard: View {
    let searchTerm: String
    let onStartClient: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle.badge.questionmark")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Theme.gold)
                    .frame(width: 42, height: 42)
                    .background(Theme.selected, in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("No profile found")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Theme.ink)
                    Text("No client profile matched \(searchTerm).")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.muted)
                }

                Spacer()
            }

            Button(action: onStartClient) {
                Label("Start Client", systemImage: "person.badge.plus")
                    .font(.headline.weight(.bold))
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .foregroundStyle(.white)
                    .background(Theme.goldGradient, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Theme.selected.opacity(0.58), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Theme.line.opacity(0.55), lineWidth: 1)
        )
    }
}

private struct ClientResultRow: View {
    let client: ClientProfile
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            ClientAvatar(initials: client.initials, size: 48)

            VStack(alignment: .leading, spacing: 3) {
                Text(client.name)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)
                Text(client.tier)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.muted)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(12)
        .background(isSelected ? Theme.selected : .white.opacity(0.54), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isSelected ? Theme.line : .clear, lineWidth: 1)
        )
    }
}

private struct ClientDetailCard: View {
    let client: ClientProfile
    let onBuildCuratedCart: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    ClientAvatar(initials: client.initials, size: 74)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(client.tier.uppercased())
                                .font(.caption.weight(.black))
                                .tracking(1.2)
                                .foregroundStyle(Theme.gold)
                            Text("VIP")
                                .font(.caption.weight(.black))
                                .foregroundStyle(Theme.gold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Theme.selected, in: Capsule())
                        }

                        Text(client.name)
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(Theme.ink)
                            .lineLimit(2)
                            .minimumScaleFactor(0.78)

                        Text("\(client.boutique) • last visit \(client.lastVisit) • \(client.status.lowercased())")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.muted)
                            .lineLimit(2)
                    }

                    Spacer()
                }
                .padding(18)
                .background(Theme.selected.opacity(0.72), in: RoundedRectangle(cornerRadius: 26, style: .continuous))

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(client.attributes) { attribute in
                        ClientAttributeTile(attribute: attribute)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Client Note")
                        .font(.headline.weight(.black))
                    Text(client.note)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Theme.selected.opacity(0.65), in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Consent & Tasks")
                            .font(.title3.weight(.black))
                        Spacer()
                        Text("Protected")
                            .font(.caption.weight(.black))
                            .foregroundStyle(Theme.gold)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 7)
                            .background(Theme.selected, in: Capsule())
                    }

                    ForEach(client.tasks) { task in
                        ClientTaskRow(task: task)
                    }

                    Button(action: onBuildCuratedCart) {
                        Label("Build Curated Cart", systemImage: "bag")
                            .font(.headline.weight(.black))
                            .frame(maxWidth: .infinity, minHeight: 54)
                            .foregroundStyle(.white)
                            .background(Theme.goldGradient, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(16)
                .background(.white.opacity(0.56), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Theme.line.opacity(0.55), lineWidth: 1)
                )
            }
        }
    }
}

private struct ClientAttributeTile: View {
    let attribute: ClientAttribute

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(attribute.title.uppercased())
                .font(.caption.weight(.black))
                .tracking(1.1)
                .foregroundStyle(Theme.muted)
            Text(attribute.value)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(Theme.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, minHeight: 106, alignment: .leading)
        .padding(16)
        .background(.white.opacity(0.60), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Theme.line.opacity(0.45), lineWidth: 1)
        )
    }
}

private struct ClientTaskRow: View {
    let task: ClientTask

    var body: some View {
        HStack(spacing: 13) {
            Image(systemName: task.icon)
                .font(.headline.weight(.semibold))
                .foregroundStyle(Theme.gold)
                .frame(width: 42, height: 42)
                .background(Theme.selected, in: RoundedRectangle(cornerRadius: 15, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Theme.ink)
                Text(task.subtitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.muted)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Theme.muted.opacity(0.72))
        }
    }
}

private struct ClientAvatar: View {
    let initials: String
    let size: CGFloat

    var body: some View {
        Text(initials)
            .font(.system(size: size * 0.34, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(Theme.goldGradient, in: RoundedRectangle(cornerRadius: size * 0.32, style: .continuous))
    }
}

private struct SellContent: View {
    let categories: [ProductCategory]
    let products: [SalesProduct]
    @Binding var session: SellingSessionState
    let onDiscardClient: () -> Void
    let onCreateProfile: (ClientProfile) -> Void

    @State private var query = ""
    @State private var selectedCategoryID: String
    @State private var selectedProduct: SalesProduct?
    @State private var returnPanelAfterProfile: SellingSessionPanel = .wishlist

    init(
        categories: [ProductCategory],
        products: [SalesProduct],
        session: Binding<SellingSessionState>,
        onDiscardClient: @escaping () -> Void,
        onCreateProfile: @escaping (ClientProfile) -> Void
    ) {
        self.categories = categories
        self.products = products
        _session = session
        self.onDiscardClient = onDiscardClient
        self.onCreateProfile = onCreateProfile
        _selectedCategoryID = State(initialValue: categories.first?.id ?? "")
    }

    private var activeCategoryTitle: String {
        categories.first(where: { $0.id == selectedCategoryID })?.title ?? "Products"
    }

    private var filteredProducts: [SalesProduct] {
        let searchTerm = query.trimmingCharacters(in: .whitespacesAndNewlines)

        if !searchTerm.isEmpty {
            return products.filter { $0.matches(searchTerm) }
        }

        return products.filter { $0.categoryID == selectedCategoryID }
    }

    private var suggestedProducts: [SalesProduct] {
        let categoryMatches = products.filter { $0.categoryID == selectedCategoryID }
        return Array((categoryMatches.isEmpty ? products : categoryMatches).prefix(5))
    }

    private var wishlistProducts: [SalesProduct] {
        products.filter { session.wishlistProductIDs.contains($0.id) }
    }

    private var cartProducts: [SalesProduct] {
        products.filter { session.cartProductIDs.contains($0.id) }
    }

    private var selectedPanelTitle: String {
        session.activePanel == .cart ? "View Cart" : "Wishlist"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                SellHeader(session: session)

                if session.activePanel == nil {
                    SellSearchRow(
                        query: $query,
                        showsClientActions: session.hasActiveClient,
                        wishlistCount: session.wishlistItemCount,
                        cartCount: session.cartItemCount,
                        onOpenWishlist: {
                            selectedProduct = nil
                            session.activePanel = .wishlist
                        },
                        onOpenCart: {
                            selectedProduct = nil
                            session.activePanel = .cart
                        }
                    )

                    CategoryStrip(
                        categories: categories,
                        selectedCategoryID: selectedCategoryID
                    ) { category in
                        selectedCategoryID = category.id
                        selectedProduct = nil
                        query = ""
                        session.activePanel = nil
                    }
                }

                if session.activePanel == .wishlist {
                    collectionPanelLayout(
                        panel: .wishlist,
                        products: wishlistProducts,
                        count: session.wishlistItemCount,
                        title: "Wishlist",
                        subtitle: "Saved for \(session.displayName)",
                        emptyTitle: "No wishlist items yet",
                        emptySubtitle: "Tap the heart on product cards to save pieces here.",
                        primaryActionTitle: "Move All Items to Cart",
                        primaryActionIcon: "bag.badge.plus",
                        quantityForProduct: { _ in nil },
                        onPrimaryAction: {
                            session.moveWishlistToCart()
                            selectedProduct = nil
                        }
                    )
                } else if session.activePanel == .cart {
                    collectionPanelLayout(
                        panel: .cart,
                        products: cartProducts,
                        count: session.cartItemCount,
                        title: "View Cart",
                        subtitle: "Cart for \(session.displayName)",
                        emptyTitle: "Cart is empty",
                        emptySubtitle: "Use Add to Cart from product details to build this order.",
                        primaryActionTitle: "Proceed to Pay",
                        primaryActionIcon: "creditcard",
                        quantityForProduct: { product in
                            session.quantity(for: product)
                        },
                        onPrimaryAction: {
                        }
                    )
                } else if session.activePanel == .createProfile {
                    CreateClientProfilePanel(
                        guestID: session.guestID ?? "Guest",
                        onSave: { profile in
                            session.createdClient = profile
                            session.activePanel = returnPanelAfterProfile
                            onCreateProfile(profile)
                        }
                    )
                } else if let selectedProduct {
                    HStack(alignment: .top, spacing: 18) {
                        SellProductBrowser(
                            title: activeCategoryTitle,
                            products: filteredProducts,
                            suggestedProducts: suggestedProducts,
                            selectedProduct: selectedProduct,
                            allowsWishlist: session.hasActiveClient,
                            isWishlisted: { product in
                                session.isWishlisted(product)
                            },
                            onToggleWishlist: { product in
                                session.toggleWishlist(product)
                            }
                        ) { product in
                            self.selectedProduct = product
                        }
                        .frame(maxWidth: .infinity)

                        SellProductDetailCard(
                            product: selectedProduct,
                            allowsClientActions: session.hasActiveClient,
                            isWishlisted: session.isWishlisted(selectedProduct),
                            onClose: {
                                self.selectedProduct = nil
                            },
                            onToggleWishlist: {
                                session.toggleWishlist(selectedProduct)
                            },
                            onAddToCart: { quantity in
                                session.addToCart(selectedProduct, quantity: quantity)
                            }
                        )
                            .id(selectedProduct.id)
                            .frame(width: 390)
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                    }
                } else {
                    SellProductBrowser(
                        title: activeCategoryTitle,
                        products: filteredProducts,
                        suggestedProducts: suggestedProducts,
                        selectedProduct: nil,
                        allowsWishlist: session.hasActiveClient,
                        isWishlisted: { product in
                            session.isWishlisted(product)
                        },
                        onToggleWishlist: { product in
                            session.toggleWishlist(product)
                        }
                    ) { product in
                        selectedProduct = product
                        session.activePanel = nil
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 22)
        }
        .scrollIndicators(.hidden)
        .animation(.snappy(duration: 0.28), value: selectedProduct)
    }

    @ViewBuilder
    private func collectionPanelLayout(
        panel: SellingSessionPanel,
        products: [SalesProduct],
        count: Int,
        title: String,
        subtitle: String,
        emptyTitle: String,
        emptySubtitle: String,
        primaryActionTitle: String,
        primaryActionIcon: String,
        quantityForProduct: @escaping (SalesProduct) -> Int?,
        onPrimaryAction: @escaping () -> Void
    ) -> some View {
        HStack(alignment: .top, spacing: 18) {
            SellingCollectionPanel(
                title: title,
                subtitle: subtitle,
                emptyTitle: emptyTitle,
                emptySubtitle: emptySubtitle,
                products: products,
                itemCount: count,
                hasCreatedProfile: session.hasCreatedProfile,
                primaryActionTitle: primaryActionTitle,
                primaryActionIcon: primaryActionIcon,
                quantityForProduct: quantityForProduct,
                onSelectProduct: { product in
                    selectedProduct = product
                },
                onBack: {
                    selectedProduct = nil
                    session.activePanel = nil
                },
                onDiscardClient: onDiscardClient,
                onProceed: {
                    returnPanelAfterProfile = panel
                    session.activePanel = .createProfile
                },
                onPrimaryAction: onPrimaryAction
            )
            .frame(maxWidth: .infinity)

            if let selectedProduct {
                SellProductDetailCard(
                    product: selectedProduct,
                    allowsClientActions: session.hasActiveClient,
                    isWishlisted: session.isWishlisted(selectedProduct),
                    onClose: {
                        self.selectedProduct = nil
                    },
                    onToggleWishlist: {
                        session.toggleWishlist(selectedProduct)
                    },
                    onAddToCart: { quantity in
                        session.addToCart(selectedProduct, quantity: quantity)
                    }
                )
                .id("\(selectedPanelTitle)-\(selectedProduct.id)")
                .frame(width: 390)
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
    }
}

private struct SellHeader: View {
    let session: SellingSessionState

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 6) {
                Text("9:41")
                    .font(.headline.weight(.bold))
                Text("Sell")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.ink)
            }

            Spacer()

            if session.hasActiveClient {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(session.hasCreatedProfile ? "Client Profile" : "Guest Session")
                        .font(.caption.weight(.black))
                        .foregroundStyle(Theme.muted)
                    Text(session.displayName)
                        .font(.headline.weight(.black))
                        .foregroundStyle(Theme.gold)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Theme.selected, in: Capsule())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SellSearchRow: View {
    @Binding var query: String
    let showsClientActions: Bool
    let wishlistCount: Int
    let cartCount: Int
    let onOpenWishlist: () -> Void
    let onOpenCart: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Theme.muted)

                TextField("Search product name or product ID", text: $query)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.search)
            }
            .font(.headline.weight(.semibold))
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .background(.white.opacity(0.72), in: Capsule())
            .overlay(
                Capsule()
                    .stroke(Theme.line.opacity(0.55), lineWidth: 1)
            )

            ToolbarPillButton(title: "Filters", icon: "slider.horizontal.3")
            if showsClientActions {
                ToolbarPillButton(
                    title: "Wishlist",
                    icon: "heart",
                    count: wishlistCount,
                    action: onOpenWishlist
                )
                ToolbarPillButton(
                    title: "View Cart",
                    icon: "bag",
                    count: cartCount,
                    action: onOpenCart
                )
            }
        }
    }
}

private struct ToolbarPillButton: View {
    let title: String
    let icon: String
    var count: Int = 0
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.title2.weight(.black))
                    .frame(width: 54, height: 54)
                    .foregroundStyle(Theme.ink)

                if count > 0 {
                    Text("\(count)")
                        .font(.caption2.weight(.black))
                        .foregroundStyle(.white)
                        .frame(minWidth: 22, minHeight: 22)
                        .padding(.horizontal, 4)
                        .background(Theme.goldGradient, in: Capsule())
                        .offset(x: 5, y: -3)
                        .accessibilityHidden(true)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(count > 0 ? "\(title), \(count) items" : title)
    }
}

private struct CategoryStrip: View {
    let categories: [ProductCategory]
    let selectedCategoryID: String
    let onSelect: (ProductCategory) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(categories) { category in
                    Button {
                        onSelect(category)
                    } label: {
                        Label(category.title, systemImage: category.icon)
                            .font(.headline.weight(.bold))
                            .padding(.horizontal, 16)
                            .frame(height: 48)
                            .foregroundStyle(selectedCategoryID == category.id ? .white : Theme.ink)
                            .background(
                                selectedCategoryID == category.id ? AnyShapeStyle(Theme.goldGradient) : AnyShapeStyle(.white.opacity(0.66)),
                                in: Capsule()
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Theme.line.opacity(0.55), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
        .scrollIndicators(.hidden)
    }
}

private struct SellProductBrowser: View {
    let title: String
    let products: [SalesProduct]
    let suggestedProducts: [SalesProduct]
    let selectedProduct: SalesProduct?
    let allowsWishlist: Bool
    let isWishlisted: (SalesProduct) -> Bool
    let onToggleWishlist: (SalesProduct) -> Void
    let onSelect: (SalesProduct) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 158), spacing: 14)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SuggestedProductsRow(
                products: suggestedProducts,
                allowsWishlist: allowsWishlist,
                isWishlisted: isWishlisted,
                onToggleWishlist: onToggleWishlist,
                onSelect: onSelect
            )

            Card {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(title)
                            .font(.title2.weight(.black))

                        Spacer()

                        Image(systemName: "slider.horizontal.3")
                            .font(.title3.weight(.black))
                            .foregroundStyle(Theme.ink)
                            .frame(width: 42, height: 42)
                            .accessibilityLabel("Filters")
                    }

                    if products.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .font(.title.weight(.bold))
                                .foregroundStyle(Theme.gold)
                            Text("No products found")
                                .font(.headline.weight(.bold))
                            Text("Try another product name, product ID, or category.")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.muted)
                        }
                        .frame(maxWidth: .infinity, minHeight: 220)
                    } else {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(products) { product in
                                ProductGridCard(
                                    product: product,
                                    isSelected: selectedProduct == product,
                                    allowsWishlist: allowsWishlist,
                                    isWishlisted: isWishlisted(product),
                                    onToggleWishlist: {
                                        onToggleWishlist(product)
                                    }
                                ) {
                                    onSelect(product)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        }
    }
}

private struct SuggestedProductsRow: View {
    let products: [SalesProduct]
    let allowsWishlist: Bool
    let isWishlisted: (SalesProduct) -> Bool
    let onToggleWishlist: (SalesProduct) -> Void
    let onSelect: (SalesProduct) -> Void

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Top Suggestions")
                        .font(.title2.weight(.black))
                    Spacer()
                    Button {
                    } label: {
                        Text("View All")
                            .font(.caption.weight(.black))
                            .foregroundStyle(Theme.gold)
                            .padding(.horizontal, 13)
                            .padding(.vertical, 8)
                            .background(Theme.selected, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }

                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(products) { product in
                            SuggestedProductCard(
                                product: product,
                                allowsWishlist: allowsWishlist,
                                isWishlisted: isWishlisted(product),
                                onToggleWishlist: {
                                    onToggleWishlist(product)
                                }
                            ) {
                                onSelect(product)
                            }
                            .frame(width: 170)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}

private struct SuggestedProductCard: View {
    let product: SalesProduct
    let allowsWishlist: Bool
    let isWishlisted: Bool
    let onToggleWishlist: () -> Void
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ProductImageView(imageName: product.imageName)
                .frame(height: 118)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(alignment: .topTrailing) {
                    if allowsWishlist {
                        Button(action: onToggleWishlist) {
                            Image(systemName: isWishlisted ? "heart.fill" : "heart")
                                .font(.caption.weight(.black))
                                .foregroundStyle(isWishlisted ? Theme.gold : Theme.ink)
                                .frame(width: 30, height: 30)
                                .background(.white.opacity(0.82), in: Circle())
                                .padding(7)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(isWishlisted ? "Remove from wishlist" : "Add to wishlist")
                    }
                }

            Text(product.name)
                .font(.subheadline.weight(.black))
                .foregroundStyle(Theme.ink)
                .lineLimit(1)

            Text(product.price)
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.muted)
        }
        .padding(10)
        .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Theme.line.opacity(0.45), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onTapGesture(perform: onTap)
    }
}

private struct ProductGridCard: View {
    let product: SalesProduct
    let isSelected: Bool
    let allowsWishlist: Bool
    let isWishlisted: Bool
    let onToggleWishlist: () -> Void
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ProductImageView(imageName: product.imageName)
                .frame(height: 142)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(alignment: .topTrailing) {
                    if allowsWishlist {
                        Button(action: onToggleWishlist) {
                            Image(systemName: isWishlisted ? "heart.fill" : "heart")
                                .font(.subheadline.weight(.black))
                                .foregroundStyle(isWishlisted ? Theme.gold : Theme.ink)
                                .frame(width: 34, height: 34)
                                .background(.white.opacity(0.78), in: Circle())
                                .padding(8)
                        }
                        .buttonStyle(.plain)
                    }
                }

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.headline.weight(.black))
                        .foregroundStyle(Theme.ink)
                        .lineLimit(1)
                    Text("\(product.audience) • \(product.id)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.muted)
                }

                Spacer(minLength: 8)
            }

            HStack {
                Text(product.price)
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(Theme.ink)

                Spacer()

                if let badge = product.badge {
                    Text(badge)
                        .font(.caption2.weight(.black))
                        .foregroundStyle(Theme.gold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Theme.selected, in: Capsule())
                }
            }
        }
        .padding(12)
        .background(isSelected ? Theme.selected.opacity(0.82) : .white.opacity(0.62), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(isSelected ? Theme.gold.opacity(0.45) : Theme.line.opacity(0.45), lineWidth: 1.2)
        )
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onTapGesture(perform: onTap)
    }
}

private struct SellProductDetailCard: View {
    let product: SalesProduct
    let allowsClientActions: Bool
    let isWishlisted: Bool
    let onClose: () -> Void
    let onToggleWishlist: () -> Void
    let onAddToCart: (Int) -> Void

    @State private var selectedSize: String
    @State private var selectedMaterial: String
    @State private var selectedColor: String
    @State private var quantity = 1

    init(
        product: SalesProduct,
        allowsClientActions: Bool,
        isWishlisted: Bool,
        onClose: @escaping () -> Void,
        onToggleWishlist: @escaping () -> Void,
        onAddToCart: @escaping (Int) -> Void
    ) {
        self.product = product
        self.allowsClientActions = allowsClientActions
        self.isWishlisted = isWishlisted
        self.onClose = onClose
        self.onToggleWishlist = onToggleWishlist
        self.onAddToCart = onAddToCart
        _selectedSize = State(initialValue: product.sizes.first ?? "One size")
        _selectedMaterial = State(initialValue: product.materials.first ?? "Standard")
        _selectedColor = State(initialValue: product.colors.first ?? "Default")
    }

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 16) {
                ProductImageView(imageName: product.imageName)
                    .frame(height: 248)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(alignment: .topLeading) {
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                            .font(.headline.weight(.black))
                            .foregroundStyle(Theme.ink)
                            .frame(width: 42, height: 42)
                            .background(.white.opacity(0.78), in: Circle())
                            .padding(12)
                        }
                        .buttonStyle(.plain)
                    }

                VStack(alignment: .leading, spacing: 6) {
                    Text(product.name)
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.ink)
                        .lineLimit(2)

                    HStack(spacing: 10) {
                        Text(product.price)
                            .font(.title3.weight(.black))
                        if let originalPrice = product.originalPrice {
                            Text(originalPrice)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(Theme.muted)
                                .strikethrough()
                        }
                    }

                    Text(product.suggestedReason)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                ProductOptionSection(title: "Size", options: product.sizes, selectedValue: $selectedSize)
                ProductOptionSection(title: "Material", options: product.materials, selectedValue: $selectedMaterial)
                ProductOptionSection(title: "Color", options: product.colors, selectedValue: $selectedColor)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Quantity")
                            .font(.caption.weight(.black))
                            .tracking(1)
                            .foregroundStyle(Theme.muted)
                        Text("\(quantity)")
                            .font(.title2.weight(.black))
                    }

                    Spacer()

                    HStack(spacing: 10) {
                        QuantityButton(symbol: "minus") {
                            quantity = max(1, quantity - 1)
                        }
                        QuantityButton(symbol: "plus") {
                            quantity += 1
                        }
                    }
                }
                .padding(14)
                .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    Label(product.availability, systemImage: "checkmark.seal")
                        .font(.headline.weight(.black))
                        .foregroundStyle(Theme.gold)
                    Text(product.stockNote)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.muted)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.selected.opacity(0.62), in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                if allowsClientActions {
                    HStack(spacing: 12) {
                        Button(action: onToggleWishlist) {
                            Label(isWishlisted ? "Saved" : "Wishlist", systemImage: isWishlisted ? "heart.fill" : "heart")
                                .font(.headline.weight(.black))
                                .frame(maxWidth: .infinity, minHeight: 54)
                                .foregroundStyle(Theme.ink)
                                .background(.white.opacity(0.76), in: Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Theme.line.opacity(0.55), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)

                        Button {
                            onAddToCart(quantity)
                        } label: {
                            Label("Add to Cart", systemImage: "bag.badge.plus")
                                .font(.headline.weight(.black))
                                .frame(maxWidth: .infinity, minHeight: 54)
                                .foregroundStyle(.white)
                                .background(Theme.goldGradient, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct SellingCollectionPanel: View {
    let title: String
    let subtitle: String
    let emptyTitle: String
    let emptySubtitle: String
    let products: [SalesProduct]
    let itemCount: Int
    let hasCreatedProfile: Bool
    let primaryActionTitle: String
    let primaryActionIcon: String
    let quantityForProduct: (SalesProduct) -> Int?
    let onSelectProduct: (SalesProduct) -> Void
    let onBack: () -> Void
    let onDiscardClient: () -> Void
    let onProceed: () -> Void
    let onPrimaryAction: () -> Void

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .center, spacing: 12) {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.headline.weight(.black))
                            .foregroundStyle(Theme.ink)
                            .frame(width: 44, height: 44)
                            .background(.white.opacity(0.72), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Back to products")

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.title2.weight(.black))
                        Text(subtitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.muted)
                    }

                    Spacer()

                    Text("\(itemCount) item\(itemCount == 1 ? "" : "s")")
                        .font(.caption.weight(.black))
                        .foregroundStyle(Theme.gold)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 8)
                        .background(Theme.selected, in: Capsule())
                }

                if products.isEmpty {
                    EmptySellingCollection(title: emptyTitle, subtitle: emptySubtitle)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(products) { product in
                            Button {
                                onSelectProduct(product)
                            } label: {
                                SellingCollectionRow(
                                    product: product,
                                    quantity: quantityForProduct(product)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Spacer(minLength: 0)

                if hasCreatedProfile {
                    Button(action: onPrimaryAction) {
                        Label(primaryActionTitle, systemImage: primaryActionIcon)
                            .font(.headline.weight(.black))
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .foregroundStyle(.white)
                            .background(Theme.goldGradient, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(products.isEmpty)
                    .opacity(products.isEmpty ? 0.55 : 1)
                } else {
                    HStack(spacing: 12) {
                        Button(action: onDiscardClient) {
                            Label("Discard Client", systemImage: "trash")
                                .font(.headline.weight(.black))
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .foregroundStyle(Theme.ink)
                                .background(.white.opacity(0.70), in: Capsule())
                        }
                        .buttonStyle(.plain)

                        Button(action: onProceed) {
                            Label("Proceed", systemImage: "person.badge.plus")
                                .font(.headline.weight(.black))
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .foregroundStyle(.white)
                                .background(Theme.goldGradient, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 560, alignment: .topLeading)
        }
    }
}

private struct EmptySellingCollection: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "bag.badge.questionmark")
                .font(.system(size: 42, weight: .black))
                .foregroundStyle(Theme.gold)
                .frame(width: 78, height: 78)
                .background(Theme.selected, in: RoundedRectangle(cornerRadius: 24, style: .continuous))

            Text(title)
                .font(.title3.weight(.black))
                .foregroundStyle(Theme.ink)
            Text(subtitle)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.muted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 280)
        .background(.white.opacity(0.48), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct SellingCollectionRow: View {
    let product: SalesProduct
    let quantity: Int?

    var body: some View {
        HStack(spacing: 14) {
            ProductImageView(imageName: product.imageName)
                .frame(width: 84, height: 84)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(product.name)
                    .font(.headline.weight(.black))
                    .foregroundStyle(Theme.ink)
                Text("\(product.audience) • \(product.id)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.muted)
                Text(quantityText)
                    .font(.caption.weight(.black))
                    .foregroundStyle(Theme.gold)
            }

            Spacer()

            Text(product.price)
                .font(.headline.weight(.black))
                .foregroundStyle(Theme.ink)
        }
        .padding(14)
        .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Theme.line.opacity(0.45), lineWidth: 1)
        )
    }

    private var quantityText: String {
        guard let quantity, quantity > 0 else {
            return "Wishlist item"
        }
        return "Quantity: \(quantity)"
    }
}

private struct CreateClientProfilePanel: View {
    let guestID: String
    let onSave: (ClientProfile) -> Void

    @State private var fullName = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var birthday = ""
    @State private var preferredStyle = "N/A"
    @State private var budget = "N/A"
    @State private var size = "N/A"
    @State private var materialPreference = "N/A"
    @State private var colorPreference = ""
    @State private var notes = ""
    @State private var consentAccepted = false

    private let styles = ["N/A", "Minimal", "Statement", "Classic", "Bridal", "Evening"]
    private let budgets = ["N/A", "Rs. 50K+", "Rs. 1L+", "Rs. 2L+", "Rs. 5L+"]
    private let sizes = ["N/A", "EU 36", "EU 38", "EU 40", "One size"]
    private let materials = ["N/A", "Gold hardware", "Silver hardware", "Pearl", "Diamond", "Leather"]

    private var canSave: Bool {
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Create Client Profile")
                            .font(.title2.weight(.black))
                        Text("Convert \(guestID) into a saved client profile")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.muted)
                    }

                    Spacer()

                    Text("Required fields marked")
                        .font(.caption.weight(.black))
                        .foregroundStyle(Theme.gold)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 8)
                        .background(Theme.selected, in: Capsule())
                }

                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 14) {
                        ProfileFormSection(title: "Identity") {
                            ProfileTextField(title: "Full Name *", placeholder: "Client name", text: $fullName)
                            ProfileTextField(title: "Phone *", placeholder: "+91 phone number", text: $phone)
                            ProfileTextField(title: "Email", placeholder: "optional email", text: $email)
                            ProfileTextField(title: "Birthday / Occasion", placeholder: "optional date or occasion", text: $birthday)
                        }

                        ProfileFormSection(title: "Preferences") {
                            ProfileDropdown(title: "Style", options: styles, selection: $preferredStyle)
                            ProfileDropdown(title: "Budget", options: budgets, selection: $budget)
                            ProfileDropdown(title: "Size", options: sizes, selection: $size)
                            ProfileDropdown(title: "Material", options: materials, selection: $materialPreference)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 14) {
                        ProfileFormSection(title: "Selling Notes") {
                            ProfileTextField(title: "Color Preference", placeholder: "champagne, black, emerald...", text: $colorPreference)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Client Note")
                                    .font(.headline.weight(.black))
                                TextEditor(text: $notes)
                                    .scrollContentBackground(.hidden)
                                    .padding(10)
                                    .frame(minHeight: 152)
                                    .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .stroke(Theme.line.opacity(0.45), lineWidth: 1)
                                    )
                                    .overlay(alignment: .topLeading) {
                                        if notes.isEmpty {
                                            Text("Add preferences, occasion, product interest, or follow-up promise...")
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(Theme.muted.opacity(0.66))
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 18)
                                        }
                                    }
                            }

                            Toggle("Client allows saved preferences and purchase history visibility", isOn: $consentAccepted)
                                .font(.headline.weight(.bold))
                                .tint(Theme.gold)
                        }

                        Button {
                            onSave(makeProfile())
                        } label: {
                            Label("Save Profile", systemImage: "checkmark.seal")
                                .font(.headline.weight(.black))
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .foregroundStyle(.white)
                                .background(Theme.goldGradient, in: Capsule())
                        }
                        .buttonStyle(.plain)
                        .disabled(!canSave)
                        .opacity(canSave ? 1 : 0.55)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func makeProfile() -> ClientProfile {
        let name = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let capturedPreferences = [
            preferredStyle,
            materialPreference,
            colorPreference
        ]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0 != "N/A" }
        let preferenceSummary = capturedPreferences.isEmpty ? "No preferences captured" : capturedPreferences.joined(separator: ", ")
        let resolvedNote = notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? (capturedPreferences.isEmpty ? "New client profile created. Preferences pending." : "New client prefers \(preferenceSummary.lowercased()).")
            : notes
        let visibleAttributes = profileAttributes()

        return ClientProfile(
            id: "CL-\(Int.random(in: 2000...9999))",
            phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
            initials: initials(for: name),
            name: name,
            tier: "New Client",
            boutique: "Mumbai",
            lastVisit: "Today",
            status: consentAccepted ? "Preferences visible" : "Profile created - preferences hidden",
            note: resolvedNote,
            attributes: visibleAttributes,
            tasks: [
                ClientTask(
                    icon: consentAccepted ? "checkmark.shield" : "eye.slash",
                    title: consentAccepted ? "Preference consent on" : "Preference consent pending",
                    subtitle: consentAccepted ? "Preferences and history visible" : "Only identity is visible to sales associate"
                ),
                ClientTask(
                    icon: "heart",
                    title: capturedPreferences.isEmpty ? "Preferences pending" : (consentAccepted ? "Preferences saved" : "Preferences captured privately"),
                    subtitle: capturedPreferences.isEmpty ? "No optional preference data saved" : (consentAccepted ? preferenceSummary : "Hidden until client allows visibility")
                )
            ]
        )
    }

    private func profileAttributes() -> [ClientAttribute] {
        var attributes: [ClientAttribute] = []
        appendAttribute("Size", value: size, to: &attributes)
        appendAttribute("Style", value: consentAccepted ? preferredStyle : "Hidden until consent", sourceValue: preferredStyle, to: &attributes)
        appendAttribute("Budget", value: budget, to: &attributes)
        appendAttribute("Preference", value: consentAccepted ? materialPreference : "Hidden until consent", sourceValue: materialPreference, to: &attributes)
        appendAttribute("Color", value: consentAccepted ? colorPreference : "Hidden until consent", sourceValue: colorPreference, to: &attributes)
        return attributes
    }

    private func appendAttribute(
        _ title: String,
        value: String,
        sourceValue: String? = nil,
        to attributes: inout [ClientAttribute]
    ) {
        let source = (sourceValue ?? value).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !source.isEmpty && source != "N/A" else { return }
        attributes.append(ClientAttribute(title: title, value: value))
    }

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return letters.isEmpty ? "GC" : letters.map(String.init).joined().uppercased()
    }
}

private struct ProfileFormSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline.weight(.black))

            content
        }
        .padding(16)
        .background(.white.opacity(0.54), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Theme.line.opacity(0.45), lineWidth: 1)
        )
    }
}

private struct ProfileTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.caption.weight(.black))
                .foregroundStyle(Theme.muted)

            TextField(placeholder, text: $text)
                .font(.headline.weight(.bold))
                .textInputAutocapitalization(.words)
                .padding(.horizontal, 14)
                .frame(minHeight: 50)
                .background(.white.opacity(0.66), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

private struct ProfileDropdown: View {
    let title: String
    let options: [String]
    @Binding var selection: String

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(option) {
                    selection = option
                }
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title.uppercased())
                        .font(.caption.weight(.black))
                        .foregroundStyle(Theme.muted)
                    Text(selection)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Theme.ink)
                }

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(Theme.gold)
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 58)
            .background(.white.opacity(0.66), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct ProductOptionSection: View {
    let title: String
    let options: [String]
    @Binding var selectedValue: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption.weight(.black))
                .tracking(1)
                .foregroundStyle(Theme.muted)

            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            selectedValue = option
                        } label: {
                            Text(option)
                                .font(.caption.weight(.black))
                                .padding(.horizontal, 12)
                                .frame(height: 34)
                                .foregroundStyle(selectedValue == option ? .white : Theme.ink)
                                .background(
                                    selectedValue == option ? AnyShapeStyle(Theme.goldGradient) : AnyShapeStyle(.white.opacity(0.66)),
                                    in: Capsule()
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

private struct QuantityButton: View {
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.headline.weight(.black))
                .frame(width: 38, height: 38)
                .foregroundStyle(Theme.ink)
                .background(Theme.selected, in: Circle())
        }
        .buttonStyle(.plain)
    }
}

struct ProductImageView: View {
    let imageName: String

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Theme.selected

                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .scaleEffect(1.06)
                    .offset(y: -8)
            }
            .clipped()
        }
    }
}
private struct PlaceholderTabContent: View {
    let tab: SalesAssociateTab

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("9:41")
                .font(.headline.weight(.bold))
            Text(tab.rawValue)
                .font(.system(size: 44, weight: .bold, design: .rounded))
            Text("This tab will be built after the Today and Client screens are finalized.")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Theme.muted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 28)
        .padding(.vertical, 22)
    }
}

private struct MonthlyGoalCard: View {
    let goal: SalesGoal

    var body: some View {
        Card {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(goal.title.uppercased())
                        .font(.caption.weight(.black))
                        .tracking(1.4)
                        .foregroundStyle(Theme.muted)

                    Text(goal.percentageText)
                        .font(.system(size: 74, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.gold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Text(goal.detailText)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Theme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 10)
                .padding(.leading, 8)

                StoreImageView()
                    .frame(width: 235)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
            .frame(height: 216)
        }
    }
}

private struct StoreImageView: View {
    var body: some View {
        Image("StoreDisplay")
            .resizable()
            .scaledToFill()
            .overlay(alignment: .leading) {
                LinearGradient(
                    colors: [.white.opacity(0.40), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
    }
}

private struct PriorityQueueCard: View {
    let items: [PriorityItem]

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Priority Queue", badge: "\(items.count) open")

                ForEach(items) { item in
                    PriorityRow(item: item)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 150, alignment: .top)
        }
    }
}

private struct PriorityRow: View {
    let item: PriorityItem

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: item.icon)
                .font(.headline.weight(.semibold))
                .foregroundStyle(Theme.gold)
                .frame(width: 44, height: 44)
                .background(Theme.selected, in: RoundedRectangle(cornerRadius: 15, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.headline.weight(.bold))
                Text(item.subtitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.muted)
            }

            Spacer()

            if let badge = item.badge {
                Text(badge)
                    .font(.caption.weight(.black))
                    .foregroundStyle(Theme.gold)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 8)
                    .background(Theme.selected, in: Capsule())
            } else {
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Theme.muted.opacity(0.72))
            }
        }
        .padding(.vertical, 2)
    }
}

private struct WeeklySalesCard: View {
    let summary: WeeklySalesSummary

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Weekly Sales", badge: summary.total)

                HStack(spacing: 12) {
                    SummaryTile(value: summary.change, label: summary.comparison)
                    SummaryTile(value: summary.bestDay, label: summary.bestDayLabel)
                }

                HStack(alignment: .bottom, spacing: 14) {
                    ForEach(summary.days) { day in
                        BarColumn(day: day)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 12)
                .frame(maxWidth: .infinity, minHeight: 196, alignment: .bottom)
                .background(.white.opacity(0.40), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
            .frame(height: 342)
        }
    }
}

private struct SummaryTile: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(value)
                .font(.title2.weight(.black))
            Text(label)
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.muted)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Theme.line.opacity(0.65), lineWidth: 1)
        )
    }
}

private struct BarColumn: View {
    let day: DailySales

    var body: some View {
        VStack(spacing: 6) {
            GeometryReader { proxy in
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(day.isBest ? Theme.bestBar : Theme.goldGradient)
                        .frame(height: max(28, proxy.size.height * day.progress))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 132)

            Text(day.day)
                .font(.caption2.weight(.bold))
                .foregroundStyle(Theme.muted)
            Text(day.amount)
                .font(.caption2.weight(.black))
                .foregroundStyle(Theme.gold)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(day.day), \(day.amount) sales")
    }
}

private struct QuickActionsCard: View {
    let actions: [QuickAction]
    let metrics: [DashboardMetric]
    let onStartClient: () -> Void

    private let actionColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 16) {
                Text("Quick Actions")
                    .font(.title2.weight(.black))

                LazyVGrid(columns: actionColumns, spacing: 12) {
                    ForEach(actions) { action in
                        ActionButton(action: action) {
                            if action.title == "Start Client" {
                                onStartClient()
                            }
                        }
                    }
                }

                LazyVGrid(columns: actionColumns, spacing: 12) {
                    ForEach(metrics) { metric in
                        MetricTile(metric: metric)
                    }
                }

                Spacer(minLength: 0)
            }
            .frame(height: 436)
        }
    }
}

private struct ActionButton: View {
    let action: QuickAction
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 7) {
                Image(systemName: action.icon)
                    .font(.title3.weight(.semibold))
                Text(action.title)
                    .font(.subheadline.weight(.bold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
            }
            .frame(maxWidth: .infinity, minHeight: 78)
            .padding(.horizontal, 8)
            .foregroundStyle(action.isPrimary ? .white : Theme.ink)
            .background(
                action.isPrimary ? AnyShapeStyle(Theme.goldGradient) : AnyShapeStyle(.white.opacity(0.68)),
                in: RoundedRectangle(cornerRadius: 21, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct MetricTile: View {
    let metric: DashboardMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(metric.title.uppercased())
                .font(.caption.weight(.black))
                .tracking(1.1)
                .foregroundStyle(Theme.muted)
            Text(metric.value)
                .font(.system(size: 32, weight: .black, design: .rounded))
        }
        .frame(maxWidth: .infinity, minHeight: 94, alignment: .leading)
        .padding(.horizontal, 16)
        .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 19, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 19, style: .continuous)
                .stroke(Theme.line.opacity(0.55), lineWidth: 1)
        )
    }
}

struct Card<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(20)
            .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Theme.line.opacity(0.65), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 18, x: 0, y: 10)
    }
}

private struct SectionHeader: View {
    let title: String
    let badge: String

    var body: some View {
        HStack {
            Text(title)
                .font(.title2.weight(.black))
            Spacer()
            Text(badge)
                .font(.caption.weight(.black))
                .foregroundStyle(Theme.gold)
                .padding(.horizontal, 13)
                .padding(.vertical, 8)
                .background(Theme.selected, in: Capsule())
        }
    }
}

enum Theme {
    static let ink = Color(red: 0.14, green: 0.12, blue: 0.10)
    static let muted = Color(red: 0.46, green: 0.42, blue: 0.36)
    static let gold = Color(red: 0.66, green: 0.47, blue: 0.22)
    static let line = Color(red: 0.74, green: 0.61, blue: 0.40).opacity(0.28)
    static let selected = Color(red: 0.95, green: 0.90, blue: 0.82)

    static let background = LinearGradient(
        colors: [
            Color(red: 0.98, green: 0.96, blue: 0.92),
            Color(red: 0.95, green: 0.91, blue: 0.85),
            Color(red: 0.90, green: 0.85, blue: 0.78)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let goldGradient = LinearGradient(
        colors: [
            Color(red: 0.63, green: 0.46, blue: 0.23),
            Color(red: 0.79, green: 0.62, blue: 0.34)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let bestBar = LinearGradient(
        colors: [
            Color(red: 0.16, green: 0.14, blue: 0.12),
            Color(red: 0.58, green: 0.42, blue: 0.21)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

#Preview("iPad Today", traits: .landscapeLeft) {
    ContentView()
}
