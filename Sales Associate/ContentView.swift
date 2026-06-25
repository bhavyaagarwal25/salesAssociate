import SwiftUI

struct ContentView: View {
    @State private var selectedTab: SalesAssociateTab = .today
    @State private var navigationMode: SalesNavigationMode = .sidebar

    private let dashboard = SalesAssociateDashboard.sample
    private let clientProfiles = ClientProfile.sampleProfiles
    private let categories = ProductCategory.sampleCategories
    private let products = SalesProduct.sampleProducts
    private let stockDashboard = StockDashboard.sample
    private let issueDashboard = IssueDashboard.sample

    var body: some View {
        TodayDashboardView(
            dashboard: dashboard,
            clientProfiles: clientProfiles,
            categories: categories,
            products: products,
            stockDashboard: stockDashboard,
            issueDashboard: issueDashboard,
            selectedTab: $selectedTab,
            navigationMode: $navigationMode
        )
    }
}

enum SalesNavigationMode: Equatable {
    case sidebar
    case top
}

struct TodayDashboardView: View {
    let dashboard: SalesAssociateDashboard
    let clientProfiles: [ClientProfile]
    let categories: [ProductCategory]
    let products: [SalesProduct]
    let stockDashboard: StockDashboard
    let issueDashboard: IssueDashboard

    @Binding var selectedTab: SalesAssociateTab
    @Binding var navigationMode: SalesNavigationMode

    var body: some View {
        GeometryReader { proxy in
            Group {
                switch navigationMode {
                case .sidebar:
                    HStack(spacing: 0) {
                        SidebarView(
                            associate: dashboard.associate,
                            selectedTab: $selectedTab,
                            navigationMode: $navigationMode
                        )
                        .frame(width: sidebarWidth(for: proxy.size.width))

                        content
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                case .top:
                    VStack(spacing: 0) {
                        TopNavigationBar(
                            associate: dashboard.associate,
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
        }
    }

    @ViewBuilder
    private var content: some View {
        switch selectedTab {
        case .today:
            DashboardContent(dashboard: dashboard)
        case .client:
            ClientelingContent(availableClients: clientProfiles)
        case .sell:
            SellContent(categories: categories, products: products)
        case .stock:
            StockContent(dashboard: stockDashboard, products: products)
        case .issue:
            IssueContent(dashboard: issueDashboard, products: products)
        }
    }

    private func sidebarWidth(for width: CGFloat) -> CGFloat {
        width > 900 ? 210 : 150
    }
}

enum SalesAssociateTab: String, CaseIterable, Identifiable {
    case today = "Today"
    case client = "Client"
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

private struct DashboardContent: View {
    let dashboard: SalesAssociateDashboard

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
                        QuickActionsCard(actions: dashboard.quickActions, metrics: dashboard.metrics)
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

            HStack(spacing: 12) {
                Label("Search", systemImage: "magnifyingglass")
                    .font(.headline.weight(.semibold))
                    .padding(.horizontal, 22)
                    .frame(height: 54)
                    .background(.white.opacity(0.72), in: Capsule())

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
}

private struct SidebarView: View {
    let associate: AssociateProfile

    @Binding var selectedTab: SalesAssociateTab
    @Binding var navigationMode: SalesNavigationMode

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            HStack(spacing: 12) {
                Text(associate.initials)
                    .font(.title3.weight(.black))
                    .foregroundStyle(.white)
                    .frame(width: 54, height: 54)
                    .background(Theme.goldGradient, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(associate.role)
                        .font(.headline.weight(.bold))
                    Text(associate.boutique)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.muted)
                }
                .minimumScaleFactor(0.75)
            }
            .padding(.top, 26)

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

            Spacer()
        }
        .padding(.horizontal, 18)
        .background(.white.opacity(0.55))
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(Theme.line)
                .frame(width: 1)
        }
        .contentShape(Rectangle())
        .gesture(sidebarCollapseGesture)
        .accessibilityAction(named: "Show Top Tabs") {
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
    let associate: AssociateProfile

    @Binding var selectedTab: SalesAssociateTab
    @Binding var navigationMode: SalesNavigationMode

    var body: some View {
        HStack(spacing: 18) {
            HStack(spacing: 12) {
                Text(associate.initials)
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(Theme.goldGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(associate.role)
                        .font(.headline.weight(.bold))
                    Text(associate.boutique)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.muted)
                }
            }
            .frame(width: 214, alignment: .leading)

            NavigationModeButton(title: "", symbol: "sidebar.left") {
                navigationMode = .sidebar
            }
            .frame(width: 48)

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

            Spacer(minLength: 12)
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

private struct TopNavigationItem: View {
    let tab: SalesAssociateTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(tab.rawValue, systemImage: tab.symbol)
                .font(.subheadline.weight(.black))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .padding(.horizontal, 14)
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
    let title: String
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ViewThatFits(in: .horizontal) {
                if !title.isEmpty {
                    Label(title, systemImage: symbol)
                        .font(.subheadline.weight(.black))
                        .lineLimit(1)
                }

                Image(systemName: symbol)
                    .font(.headline.weight(.black))
            }
            .frame(maxWidth: .infinity, minHeight: 42)
            .padding(.horizontal, 12)
            .foregroundStyle(Theme.gold)
            .background(.white.opacity(0.70), in: Capsule())
            .overlay(
                Capsule()
                    .stroke(Theme.line.opacity(0.62), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title.isEmpty ? "Show Sidebar" : title)
    }
}

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

private struct ClientelingContent: View {
    let availableClients: [ClientProfile]

    @State private var query = ""
    @State private var searchedClients: [ClientProfile] = []
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
                            clients: searchedClients,
                            selectedClient: $selectedClient,
                            missedSearchTerm: $missedSearchTerm,
                            onSearch: searchExistingClient
                        )
                        .frame(width: 318)

                        ClientDetailCard(client: selectedClient)
                            .frame(maxWidth: .infinity)
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                    } else {
                        ClientSearchPanel(
                            query: $query,
                            clients: searchedClients,
                            selectedClient: $selectedClient,
                            missedSearchTerm: $missedSearchTerm,
                            onSearch: searchExistingClient
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

        if !searchedClients.contains(match) {
            searchedClients.insert(match, at: 0)
        }

        query = ""
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
                    NoProfileFoundCard(searchTerm: missedSearchTerm)
                }

                if !clients.isEmpty {
                    VStack(spacing: 10) {
                        ForEach(clients) { client in
                            Button {
                                selectedClient = client
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

private struct NoProfileFoundCard: View {
    let searchTerm: String

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

            Button {
            } label: {
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

                    Button {
                    } label: {
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

    @State private var query = ""
    @State private var selectedCategoryID: String
    @State private var selectedProduct: SalesProduct?

    init(categories: [ProductCategory], products: [SalesProduct]) {
        self.categories = categories
        self.products = products
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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                SellHeader()

                SellSearchRow(query: $query)

                CategoryStrip(
                    categories: categories,
                    selectedCategoryID: selectedCategoryID
                ) { category in
                    selectedCategoryID = category.id
                    selectedProduct = nil
                    query = ""
                }

                if let selectedProduct {
                    HStack(alignment: .top, spacing: 18) {
                        SellProductBrowser(
                            title: activeCategoryTitle,
                            products: filteredProducts,
                            suggestedProducts: suggestedProducts,
                            selectedProduct: selectedProduct
                        ) { product in
                            self.selectedProduct = product
                        }
                        .frame(maxWidth: .infinity)

                        SellProductDetailCard(product: selectedProduct)
                            .id(selectedProduct.id)
                            .frame(width: 390)
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                    }
                } else {
                    SellProductBrowser(
                        title: activeCategoryTitle,
                        products: filteredProducts,
                        suggestedProducts: suggestedProducts,
                        selectedProduct: nil
                    ) { product in
                        selectedProduct = product
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 22)
        }
        .scrollIndicators(.hidden)
        .animation(.snappy(duration: 0.28), value: selectedProduct)
    }
}

private struct SellHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("9:41")
                .font(.headline.weight(.bold))
            Text("Sell")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SellSearchRow: View {
    @Binding var query: String

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
            ToolbarPillButton(title: "Wishlist", icon: "heart")
            ToolbarPillButton(title: "View Cart", icon: "bag")
        }
    }
}

private struct ToolbarPillButton: View {
    let title: String
    let icon: String

    var body: some View {
        Button {
        } label: {
            Label(title, systemImage: icon)
                .font(.headline.weight(.bold))
                .lineLimit(1)
                .padding(.horizontal, 18)
                .frame(height: 56)
                .foregroundStyle(Theme.ink)
                .background(.white.opacity(0.74), in: Capsule())
        }
        .buttonStyle(.plain)
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
    let onSelect: (SalesProduct) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 158), spacing: 14)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SuggestedProductsRow(products: suggestedProducts, onSelect: onSelect)

            Card {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(title)
                            .font(.title2.weight(.black))

                        Spacer()

                        Label("Filters", systemImage: "slider.horizontal.3")
                            .font(.caption.weight(.black))
                            .foregroundStyle(Theme.gold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Theme.selected, in: Capsule())
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
                                    isSelected: selectedProduct == product
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
                            SuggestedProductCard(product: product) {
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
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                ProductImageView(imageName: product.imageName)
                    .frame(height: 118)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

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
        }
        .buttonStyle(.plain)
    }
}

private struct ProductGridCard: View {
    let product: SalesProduct
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                ProductImageView(imageName: product.imageName)
                    .frame(height: 142)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: product.isWishlisted ? "heart.fill" : "heart")
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(product.isWishlisted ? Theme.gold : Theme.ink)
                            .frame(width: 34, height: 34)
                            .background(.white.opacity(0.78), in: Circle())
                            .padding(8)
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
        }
        .buttonStyle(.plain)
    }
}

private struct SellProductDetailCard: View {
    let product: SalesProduct

    @State private var selectedSize: String
    @State private var selectedMaterial: String
    @State private var selectedColor: String
    @State private var quantity = 1

    init(product: SalesProduct) {
        self.product = product
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
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: product.isWishlisted ? "heart.fill" : "heart")
                            .font(.headline.weight(.black))
                            .foregroundStyle(product.isWishlisted ? Theme.gold : Theme.ink)
                            .frame(width: 42, height: 42)
                            .background(.white.opacity(0.78), in: Circle())
                            .padding(12)
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

                HStack(spacing: 12) {
                    Button {
                    } label: {
                        Image(systemName: "heart")
                            .font(.headline.weight(.black))
                            .frame(width: 54, height: 54)
                            .foregroundStyle(Theme.ink)
                            .background(.white.opacity(0.68), in: Circle())
                    }
                    .buttonStyle(.plain)

                    Button {
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
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .background(Theme.selected)
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
                        ActionButton(action: action)
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

    var body: some View {
        Button {
        } label: {
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
