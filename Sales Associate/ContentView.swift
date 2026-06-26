import SwiftUI
import MapKit
import Combine

struct ContentView: View {
    @State private var loggedInDashboard: SalesAssociateDashboard? = nil
    @State private var selectedTab: SalesAssociateTab = .today
    @State private var navigationMode: SalesNavigationMode = .sidebar
    @State private var recentlyViewedClients: [ClientProfile] = []
    @State private var clientProfiles = ClientProfileJSONStore.loadProfiles()
    @State private var sellingSession = SellingSessionState()

    private let categories = ProductCategory.sampleCategories
    private let products = SalesProduct.sampleProducts
    private let stockDashboard = StockDashboard.sample
    private let issueDashboard = IssueDashboard.sample

//Dashboard Navigation Controller
    var body: some View {
        if let currentDashboard = loggedInDashboard {
            TodayDashboardView(
                dashboard: currentDashboard,
                clientProfiles: $clientProfiles,
                categories: categories,
                products: products,
                stockDashboard: stockDashboard,
                issueDashboard: issueDashboard,
                selectedTab: $selectedTab,
                navigationMode: $navigationMode,
                recentlyViewedClients: $recentlyViewedClients,
                sellingSession: $sellingSession,
                onLogout: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        loggedInDashboard = nil
                        selectedTab = .today
                        sellingSession = SellingSessionState()
                    }
                }
            )
            .transition(.opacity)
        } else {
            LoginView { dashboard in
                withAnimation(.easeInOut(duration: 0.25)) {
                    loggedInDashboard = dashboard
                }
            }
            .transition(.opacity)
        }
    }
}

struct LoginView: View {
    let onLoginSuccess: (SalesAssociateDashboard) -> Void

    @State private var email: String = ""
    @State private var passcode: String = ""
    @State private var errorMessage: String? = nil
    @State private var isPasscodeVisible: Bool = false
    @State private var isAuthenticating: Bool = false

    // Password change states
    @State private var changePasswordMode: Bool = false
    @State private var newPassword: String = ""
    @State private var confirmNewPassword: String = ""
    @State private var currentAccessToken: String = ""
    @State private var tempUserEmail: String = ""
    @State private var tempUserMetadata: UserMetadata? = nil
    @State private var isNewPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false

    var body: some View {
        ZStack {
            // Elegant background matching theme
            Theme.background
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Top branding / logo
                VStack(spacing: 8) {
                    Text("R S M S")
                        .font(.system(size: 38, weight: .black, design: .serif))
                        .tracking(12)
                        .foregroundStyle(Theme.ink)
                    
                    Text("BOUTIQUE PORTAL")
                        .font(.system(size: 14, weight: .bold))
                        .tracking(4)
                        .foregroundStyle(Theme.gold)

                    Rectangle()
                        .fill(Theme.goldGradient)
                        .frame(width: 80, height: 2)
                        .padding(.top, 8)
                }

                if changePasswordMode {
                    // Password Change Card
                    VStack(spacing: 24) {
                        Text("Secure Your Account")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(Theme.ink)

                        Text("This is your first time logging in. Please set a new security password to access the boutique portal.")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.muted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)

                        VStack(alignment: .leading, spacing: 18) {
                            // New Password Field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("NEW PASSWORD")
                                    .font(.caption.weight(.black))
                                    .tracking(1.1)
                                    .foregroundStyle(Theme.muted)

                                HStack(spacing: 12) {
                                    Image(systemName: "lock.fill")
                                        .font(.headline)
                                        .foregroundStyle(Theme.gold)

                                    if isNewPasswordVisible {
                                        TextField("Minimum 6 characters", text: $newPassword)
                                            .textFieldStyle(.plain)
                                            .disableAutocorrection(true)
                                            .textInputAutocapitalization(.never)
                                    } else {
                                        SecureField("Minimum 6 characters", text: $newPassword)
                                            .textFieldStyle(.plain)
                                            .disableAutocorrection(true)
                                            .textInputAutocapitalization(.never)
                                    }

                                    Button {
                                        isNewPasswordVisible.toggle()
                                    } label: {
                                        Image(systemName: isNewPasswordVisible ? "eye.slash" : "eye")
                                            .foregroundStyle(Theme.muted)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(14)
                                .background(.white.opacity(0.6), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Theme.line.opacity(0.5), lineWidth: 1)
                                )
                            }

                            // Confirm Password Field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("CONFIRM NEW PASSWORD")
                                    .font(.caption.weight(.black))
                                    .tracking(1.1)
                                    .foregroundStyle(Theme.muted)

                                HStack(spacing: 12) {
                                    Image(systemName: "lock.fill")
                                        .font(.headline)
                                        .foregroundStyle(Theme.gold)

                                    if isConfirmPasswordVisible {
                                        TextField("Confirm password", text: $confirmNewPassword)
                                            .textFieldStyle(.plain)
                                            .disableAutocorrection(true)
                                            .textInputAutocapitalization(.never)
                                    } else {
                                        SecureField("Confirm password", text: $confirmNewPassword)
                                            .textFieldStyle(.plain)
                                            .disableAutocorrection(true)
                                            .textInputAutocapitalization(.never)
                                    }

                                    Button {
                                        isConfirmPasswordVisible.toggle()
                                    } label: {
                                        Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
                                            .foregroundStyle(Theme.muted)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(14)
                                .background(.white.opacity(0.6), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Theme.line.opacity(0.5), lineWidth: 1)
                                )
                            }
                        }

                        // Error Message
                        if let errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.red)
                                Text(errorMessage)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.red)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.vertical, 4)
                            .transition(.opacity)
                        }

                        // Submit Button
                        Button(action: handlePasswordChange) {
                            HStack {
                                if isAuthenticating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Update Password & Sign In")
                                        .font(.headline.weight(.black))
                                        .tracking(1)
                                    Image(systemName: "checkmark")
                                        .font(.headline.weight(.black))
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(Theme.goldGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: Theme.gold.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .buttonStyle(.plain)
                        .disabled(isAuthenticating)

                        // Cancel Button
                        Button {
                            withAnimation {
                                changePasswordMode = false
                                passcode = ""
                                newPassword = ""
                                confirmNewPassword = ""
                                errorMessage = nil
                            }
                        } label: {
                            Text("Back to Sign In")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(Theme.gold)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(32)
                    .frame(width: 440)
                    .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(Theme.line.opacity(0.6), lineWidth: 1)
                    )
                    .shadow(color: Theme.ink.opacity(0.04), radius: 24, x: 0, y: 12)
                } else {
                    // Login Card
                    VStack(spacing: 24) {
                        Text("Associate Sign In")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(Theme.ink)

                        VStack(alignment: .leading, spacing: 18) {
                            // Email Field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("ENTERPRISE EMAIL")
                                    .font(.caption.weight(.black))
                                    .tracking(1.1)
                                    .foregroundStyle(Theme.muted)

                                HStack(spacing: 12) {
                                    Image(systemName: "envelope")
                                        .font(.headline)
                                        .foregroundStyle(Theme.gold)
                                    
                                    TextField("name@rsms.in", text: $email)
                                        .textInputAutocapitalization(.never)
                                        .keyboardType(.emailAddress)
                                        .disableAutocorrection(true)
                                        .textFieldStyle(.plain)
                                }
                                .padding(14)
                                .background(.white.opacity(0.6), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Theme.line.opacity(0.5), lineWidth: 1)
                                )
                            }

                            // Passcode Field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("SECURITY PASSCODE")
                                    .font(.caption.weight(.black))
                                    .tracking(1.1)
                                    .foregroundStyle(Theme.muted)

                                HStack(spacing: 12) {
                                    Image(systemName: "lock")
                                        .font(.headline)
                                        .foregroundStyle(Theme.gold)

                                    if isPasscodeVisible {
                                        TextField("Password or PIN", text: $passcode)
                                            .textFieldStyle(.plain)
                                            .disableAutocorrection(true)
                                            .textInputAutocapitalization(.never)
                                    } else {
                                        SecureField("Password or PIN", text: $passcode)
                                            .textFieldStyle(.plain)
                                            .disableAutocorrection(true)
                                            .textInputAutocapitalization(.never)
                                    }

                                    Button {
                                        isPasscodeVisible.toggle()
                                    } label: {
                                        Image(systemName: isPasscodeVisible ? "eye.slash" : "eye")
                                            .foregroundStyle(Theme.muted)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(14)
                                .background(.white.opacity(0.6), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Theme.line.opacity(0.5), lineWidth: 1)
                                )
                            }
                        }

                        // Error Message
                        if let errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.red)
                                Text(errorMessage)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.red)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.vertical, 4)
                            .transition(.opacity)
                        }

                        // Sign In Button
                        Button(action: handleLogin) {
                            HStack {
                                if isAuthenticating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Sign In to Account")
                                        .font(.headline.weight(.black))
                                        .tracking(1)
                                    Image(systemName: "arrow.right")
                                        .font(.headline.weight(.black))
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(Theme.goldGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: Theme.gold.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .buttonStyle(.plain)
                        .disabled(isAuthenticating)
                    }
                    .padding(32)
                    .frame(width: 440)
                    .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(Theme.line.opacity(0.6), lineWidth: 1)
                    )
                    .shadow(color: Theme.ink.opacity(0.04), radius: 24, x: 0, y: 12)
                }

                Spacer()

                if !changePasswordMode {
                    // Demo Accounts / Quick Login Section
                    VStack(spacing: 16) {
                        HStack(spacing: 8) {
                            Rectangle()
                                .fill(Theme.line)
                                .frame(height: 1)
                            
                            Text("QUICK ACCESS DEMO ACCOUNTS")
                                .font(.caption.weight(.black))
                                .tracking(1.5)
                                .foregroundStyle(Theme.muted)
                                .padding(.horizontal, 8)

                            Rectangle()
                                .fill(Theme.line)
                                .frame(height: 1)
                        }
                        .frame(width: 520)

                        HStack(spacing: 16) {
                            ForEach(SalesAssociateDashboard.samples, id: \.associate.employeeID) { sampleDashboard in
                                Button {
                                    quickLogin(with: sampleDashboard)
                                } label: {
                                    VStack(spacing: 10) {
                                        Text(sampleDashboard.associate.initials)
                                            .font(.headline.weight(.black))
                                            .foregroundStyle(.white)
                                            .frame(width: 50, height: 50)
                                            .background(Theme.goldGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                                        VStack(spacing: 3) {
                                            Text(sampleDashboard.associate.name)
                                                .font(.headline.weight(.bold))
                                                .foregroundStyle(Theme.ink)
                                                .lineLimit(1)
                                            
                                            Text(sampleDashboard.associate.boutique)
                                                .font(.caption2.weight(.bold))
                                                .foregroundStyle(Theme.muted)
                                                .lineLimit(1)
                                        }
                                    }
                                    .padding(16)
                                    .frame(width: 160)
                                    .background(.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .stroke(Theme.line.opacity(0.55), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .padding(.vertical, 30)
        }
    }

    private func handleLogin() {
        errorMessage = nil
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanPasscode = passcode.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanEmail.isEmpty else {
            errorMessage = "Please enter your enterprise email."
            return
        }

        guard !cleanPasscode.isEmpty else {
            errorMessage = "Please enter your password."
            return
        }

        isAuthenticating = true

        Task {
            do {
                // local check for demo profiles with testing passcode '1234'
                let demoEmails = SalesAssociateDashboard.samples.map { $0.associate.email.lowercased() }
                if demoEmails.contains(cleanEmail) && cleanPasscode == "1234" {
                    try await Task.sleep(nanoseconds: 600_000_000)
                    let matchedDashboard = SalesAssociateDashboard.samples.first(where: { $0.associate.email.lowercased() == cleanEmail })!
                    await MainActor.run {
                        isAuthenticating = false
                        onLoginSuccess(matchedDashboard)
                    }
                    return
                }

                // Supabase Auth call
                let session = try await SupabaseAuthService.shared.login(email: cleanEmail, password: cleanPasscode)
                
                await MainActor.run {
                    isAuthenticating = false
                    
                    // Check user_metadata.password_changed to enforce password change on first login
                    let passwordChanged = session.user.userMetadata?.passwordChanged ?? false
                    if !passwordChanged {
                        currentAccessToken = session.accessToken
                        tempUserEmail = cleanEmail
                        tempUserMetadata = session.user.userMetadata
                        withAnimation {
                            changePasswordMode = true
                            errorMessage = nil
                        }
                    } else {
                        let dashboard = getDashboard(for: cleanEmail, metadata: session.user.userMetadata)
                        onLoginSuccess(dashboard)
                    }
                }
            } catch {
                await MainActor.run {
                    isAuthenticating = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func handlePasswordChange() {
        errorMessage = nil
        let cleanPassword = newPassword.trimmingCharacters(in: .whitespaces)
        let cleanConfirm = confirmNewPassword.trimmingCharacters(in: .whitespaces)

        guard cleanPassword.count >= 6 else {
            errorMessage = "Password must be at least 6 characters long."
            return
        }

        guard cleanPassword == cleanConfirm else {
            errorMessage = "Passwords do not match."
            return
        }

        isAuthenticating = true

        Task {
            do {
                let _ = try await SupabaseAuthService.shared.changePassword(accessToken: currentAccessToken, newPassword: cleanPassword)
                
                await MainActor.run {
                    isAuthenticating = false
                    var updatedMetadata = tempUserMetadata ?? UserMetadata()
                    updatedMetadata.passwordChanged = true
                    
                    let dashboard = getDashboard(for: tempUserEmail, metadata: updatedMetadata)
                    withAnimation {
                        changePasswordMode = false
                    }
                    onLoginSuccess(dashboard)
                }
            } catch {
                await MainActor.run {
                    isAuthenticating = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func quickLogin(with dashboard: SalesAssociateDashboard) {
        email = dashboard.associate.email
        passcode = "1234"
        errorMessage = nil
        isAuthenticating = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            isAuthenticating = false
            onLoginSuccess(dashboard)
        }
    }

    private func getDashboard(for email: String, metadata: UserMetadata?) -> SalesAssociateDashboard {
        let lowercasedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let sample = SalesAssociateDashboard.samples.first(where: { $0.associate.email.lowercased() == lowercasedEmail }) {
            return sample
        }
        
        let name = metadata?.name ?? email.components(separatedBy: "@").first?.capitalized ?? "Sales Associate"
        let initials = metadata?.initials ?? String(name.split(separator: " ").compactMap { $0.first }.map { String($0) }.joined().prefix(2)).uppercased()
        
        let associate = AssociateProfile(
            initials: initials.isEmpty ? "SA" : initials,
            name: name,
            role: metadata?.role ?? "Sales Associate",
            boutique: metadata?.boutique ?? "South Mumbai",
            email: email,
            phone: metadata?.phone ?? "+91 98765 43210",
            employeeID: metadata?.employeeID ?? "SA-\(Int.random(in: 1000...9999))",
            shift: metadata?.shift ?? "Morning shift"
        )
        
        return SalesAssociateDashboard(
            associate: associate,
            monthlyGoal: SalesGoal(
                title: "Monthly Sales Goal",
                progress: 0.50,
                achieved: "Rs. 3.5L",
                target: "Rs. 7.0L"
            ),
            priorityItems: [
                PriorityItem(
                    icon: "crown",
                    title: "Welcome Appointment",
                    subtitle: "First client visit scheduled",
                    badge: "Today"
                ),
                PriorityItem(
                    icon: "sparkles",
                    title: "Onboarding completed",
                    subtitle: "Setup your profile details",
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
                DashboardMetric(title: "Open Carts", value: "0"),
                DashboardMetric(title: "Follow-ups", value: "0"),
                DashboardMetric(title: "VIP Today", value: "0")
            ],
            weeklySales: WeeklySalesSummary(
                total: "Rs. 0L",
                change: "0%",
                comparison: "Compared with last week",
                bestDay: "Mon",
                bestDayLabel: "Best sales day",
                days: [
                    DailySales(day: "Mon", amount: "0k", progress: 0.0, isBest: false),
                    DailySales(day: "Tue", amount: "0k", progress: 0.0, isBest: false),
                    DailySales(day: "Wed", amount: "0k", progress: 0.0, isBest: false),
                    DailySales(day: "Thu", amount: "0k", progress: 0.0, isBest: false),
                    DailySales(day: "Fri", amount: "0k", progress: 0.0, isBest: false),
                    DailySales(day: "Sat", amount: "0k", progress: 0.0, isBest: false),
                    DailySales(day: "Sun", amount: "0k", progress: 0.0, isBest: false)
                ]
            )
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
    let onLogout: () -> Void

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
                AssociateProfileSheet(associate: dashboard.associate, onLogout: onLogout)
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
                clientProfiles: $clientProfiles,
                products: products,
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
        .padding(.top, 10)
        .padding(.bottom, 4)
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
    let onLogout: () -> Void
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

            Spacer(minLength: 16)

            Button {
                dismiss()
                onLogout()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "power")
                        .font(.headline.weight(.black))
                    Text("LOG OUT")
                        .font(.headline.weight(.black))
                        .tracking(1.2)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.48, green: 0.14, blue: 0.14), Color(red: 0.68, green: 0.22, blue: 0.22)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(26)
        .frame(minWidth: 420, minHeight: 510)
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
    @Binding var clientProfiles: [ClientProfile]
    let products: [SalesProduct]
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
                            products: products,
                            onBuildCuratedCart: {
                                onBuildCuratedCart(selectedClient)
                            },
                            onUpdateClient: { updatedClient in
                                updateClientProfile(updatedClient)
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

        guard let match = clientProfiles.first(where: { $0.matches(searchTerm) }) else {
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

    private func updateClientProfile(_ updatedClient: ClientProfile) {
        clientProfiles.removeAll { $0.id == updatedClient.id }
        clientProfiles.insert(updatedClient, at: 0)
        ClientProfileJSONStore.saveProfiles(clientProfiles)
        rememberRecentlyViewed(updatedClient)
        selectedClient = updatedClient
    }
}

private struct ClientHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
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
    let products: [SalesProduct]
    let onBuildCuratedCart: () -> Void
    let onUpdateClient: (ClientProfile) -> Void

    @State private var activeTaskPanel: ClientTaskPanel?

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var hasInsightConsent: Bool {
        client.hasClientInsightConsent
    }

    private var visibleAttributes: [ClientAttribute] {
        client.allowsPreferenceVisibility ? client.visiblePreferenceAttributes : []
    }

    private var wishlistProducts: [SalesProduct] {
        let wishlistIDs = Set(client.wishlistProductIDs)
        return products.filter { wishlistIDs.contains($0.id) }
    }

    var body: some View {
        Card {
            Group {
                switch activeTaskPanel {
                case .consentApproval:
                    ClientConsentApprovalPanel(
                        client: client,
                        onBack: {
                            activeTaskPanel = nil
                        },
                        onSave: updateConsent
                    )
                case .preferences:
                    ClientPreferenceEditPanel(
                        client: client,
                        onBack: {
                            activeTaskPanel = nil
                        },
                        onSave: updatePreferences
                    )
                case nil:
                    overviewContent
                }
            }
            .animation(.snappy(duration: 0.24), value: activeTaskPanel)
        }
    }

    private func updateConsent(
        preferenceVisibilityAllowed: Bool,
        purchaseHistoryAllowed: Bool,
        approvalNote _: String
    ) {
        let updatedTasks = client.tasks.map { task in
            guard task.title.lowercased().contains("consent") else {
                return task
            }

            return ClientTask(
                icon: "checkmark.shield",
                title: "Client insight consent on",
                subtitle: consentSubtitle(
                    preferenceVisibilityAllowed: preferenceVisibilityAllowed,
                    purchaseHistoryAllowed: purchaseHistoryAllowed
                )
            )
        }

        onUpdateClient(
            ClientProfile(
                id: client.id,
                phone: client.phone,
                initials: client.initials,
                name: client.name,
                tier: client.tier,
                lifetimePurchaseAmount: client.lifetimePurchaseAmount,
                boutique: client.boutique,
                lastVisit: client.lastVisit,
                status: consentStatus(
                    preferenceVisibilityAllowed: preferenceVisibilityAllowed,
                    purchaseHistoryAllowed: purchaseHistoryAllowed
                ),
                note: client.note,
                attributes: client.attributes,
                tasks: updatedTasks,
                purchaseHistory: client.purchaseHistory,
                wishlistProductIDs: client.wishlistProductIDs,
                defaultDeliveryAddress: client.defaultDeliveryAddress,
                deliveryAddressDetail: client.deliveryAddressDetail
            )
        )
    }

    private func consentSubtitle(
        preferenceVisibilityAllowed: Bool,
        purchaseHistoryAllowed: Bool
    ) -> String {
        switch (preferenceVisibilityAllowed, purchaseHistoryAllowed) {
        case (true, true):
            return "Preferences and purchase history visible"
        case (true, false):
            return "Preferences visible"
        case (false, true):
            return "Purchase history visible"
        case (false, false):
            return "Only identity is visible to sales associate"
        }
    }

    private func consentStatus(
        preferenceVisibilityAllowed: Bool,
        purchaseHistoryAllowed: Bool
    ) -> String {
        switch (preferenceVisibilityAllowed, purchaseHistoryAllowed) {
        case (true, true), (true, false):
            return "Preferences visible"
        case (false, true):
            return "Purchase history visible"
        case (false, false):
            return "Profile created - preferences hidden"
        }
    }

    private func updatePreferences(
        preferredStyle: String,
        budget: String,
        size: String,
        materialPreference: String,
        colorPreference: String,
        preferenceNote: String
    ) {
        let preferenceAttributes = makePreferenceAttributes(
            preferredStyle: preferredStyle,
            budget: budget,
            size: size,
            materialPreference: materialPreference,
            colorPreference: colorPreference
        )

        let replacedTitles = Set(["Size", "Style", "Budget", "Preference", "Color"])
        let retainedAttributes = client.attributes.filter { !replacedTitles.contains($0.title) }
        let note = preferenceNote.trimmingCharacters(in: .whitespacesAndNewlines)
        let summary = preferenceAttributes.map(\.value).joined(separator: ", ")
        let updatedTasks = client.tasks.map { task in
            guard task.title.lowercased().contains("preference") && !task.title.lowercased().contains("consent") else {
                return task
            }

            return ClientTask(
                icon: "heart.fill",
                title: "Preferences saved",
                subtitle: summary.isEmpty ? "Preference details updated" : summary
            )
        }

        onUpdateClient(
            ClientProfile(
                id: client.id,
                phone: client.phone,
                initials: client.initials,
                name: client.name,
                tier: client.tier,
                lifetimePurchaseAmount: client.lifetimePurchaseAmount,
                boutique: client.boutique,
                lastVisit: client.lastVisit,
                status: client.status,
                note: note,
                attributes: retainedAttributes + preferenceAttributes,
                tasks: updatedTasks,
                purchaseHistory: client.purchaseHistory,
                wishlistProductIDs: client.wishlistProductIDs,
                defaultDeliveryAddress: client.defaultDeliveryAddress,
                deliveryAddressDetail: client.deliveryAddressDetail
            )
        )
    }

    private func makePreferenceAttributes(
        preferredStyle: String,
        budget: String,
        size: String,
        materialPreference: String,
        colorPreference: String
    ) -> [ClientAttribute] {
        var attributes: [ClientAttribute] = []
        appendAttribute("Size", value: size, to: &attributes)
        appendAttribute("Style", value: preferredStyle, to: &attributes)
        appendAttribute("Budget", value: budget, to: &attributes)
        appendAttribute("Preference", value: materialPreference, to: &attributes)
        appendAttribute("Color", value: colorPreference, to: &attributes)
        return attributes
    }

    private func appendAttribute(_ title: String, value: String, to attributes: inout [ClientAttribute]) {
        let resolvedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !resolvedValue.isEmpty && resolvedValue != "N/A" else { return }
        attributes.append(ClientAttribute(title: title, value: resolvedValue))
    }

    private var visibleClientNote: String? {
        let note = client.note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !note.isEmpty else { return nil }

        let generatedNotes = [
            "New client profile created. Preferences pending."
        ]
        let isGeneratedPreferenceNote = note.lowercased().hasPrefix("new client prefers ")

        guard !generatedNotes.contains(note) && !isGeneratedPreferenceNote else {
            return nil
        }

        return note
    }

    private var overviewContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                ClientAvatar(initials: client.initials, size: 74)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(client.tier.uppercased())
                            .font(.caption.weight(.black))
                            .tracking(1.2)
                            .foregroundStyle(Theme.gold)
                        if client.tier != "Normal" {
                            Text("VIP")
                                .font(.caption.weight(.black))
                                .foregroundStyle(Theme.gold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Theme.selected, in: Capsule())
                        }
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

            ClientLoyaltySummary(client: client)

            if !visibleAttributes.isEmpty {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(visibleAttributes) { attribute in
                        ClientAttributeTile(attribute: attribute)
                    }
                }
            } else if !hasInsightConsent {
                ClientRestrictedInsightNotice()
            }

            if hasInsightConsent, let visibleClientNote {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Client Note")
                        .font(.headline.weight(.black))
                    Text(visibleClientNote)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Theme.selected.opacity(0.65), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }

            if client.allowsPurchaseHistoryVisibility {
                ClientPurchaseHistorySection(purchases: client.purchaseHistory)
                ClientWishlistInsightSection(products: wishlistProducts)
            }

            VStack(alignment: .leading, spacing: 16) {
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
                    ClientTaskRow(
                        task: task,
                        isActionable: taskPanel(for: task) != nil
                    ) {
                        activeTaskPanel = taskPanel(for: task)
                    }
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

    private func taskPanel(for task: ClientTask) -> ClientTaskPanel? {
        let title = task.title.lowercased()

        if title.contains("consent") {
            return .consentApproval
        }

        if title.contains("preference") {
            return .preferences
        }

        return nil
    }
}

private enum ClientTaskPanel: Equatable {
    case consentApproval
    case preferences
}

private struct ClientLoyaltySummary: View {
    let client: ClientProfile

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ClientLoyaltyTile(title: "Tier", value: client.tier, icon: "crown")
            ClientLoyaltyTile(title: "Reward Points", value: client.rewardPointsText, icon: "sparkles")
            ClientLoyaltyTile(title: "Lifetime Purchase", value: client.lifetimePurchaseText, icon: "creditcard")
        }
    }
}

private struct ClientLoyaltyTile: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.headline.weight(.black))
                .foregroundStyle(Theme.gold)
                .frame(width: 42, height: 42)
                .background(Theme.selected, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(title.uppercased())
                    .font(.caption.weight(.black))
                    .tracking(1.1)
                    .foregroundStyle(Theme.muted)
                Text(value)
                    .font(.title3.weight(.black))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 82, alignment: .leading)
        .background(.white.opacity(0.60), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Theme.line.opacity(0.45), lineWidth: 1)
        )
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

private struct ClientRestrictedInsightNotice: View {
    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 4) {
                Text("Other preferences are hidden until clients consent")
                    .font(.headline.weight(.black))
                    .foregroundStyle(Theme.ink)
                Text("Purchase history, wishlist, style notes, and detailed preferences will appear after consent is captured.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.muted)
            }
        } icon: {
            Image(systemName: "eye.slash")
                .font(.headline.weight(.black))
                .foregroundStyle(Theme.gold)
                .frame(width: 44, height: 44)
                .background(Theme.selected, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Theme.line.opacity(0.45), lineWidth: 1)
        )
    }
}

private struct ClientPurchaseHistorySection: View {
    let purchases: [ClientPurchase]

    var body: some View {
        if !purchases.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Purchase History")
                        .font(.title3.weight(.black))
                    Spacer()
                    Text("\(purchases.count) items")
                        .font(.caption.weight(.black))
                        .foregroundStyle(Theme.gold)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 7)
                        .background(Theme.selected, in: Capsule())
                }

                ForEach(purchases) { purchase in
                    ClientPurchaseRow(purchase: purchase)
                }
            }
            .padding(16)
            .background(.white.opacity(0.56), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Theme.line.opacity(0.45), lineWidth: 1)
            )
        }
    }
}

private struct ClientPurchaseRow: View {
    let purchase: ClientPurchase

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bag.badge.checkmark")
                .font(.headline.weight(.black))
                .foregroundStyle(Theme.gold)
                .frame(width: 42, height: 42)
                .background(Theme.selected, in: RoundedRectangle(cornerRadius: 15, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(purchase.productName)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Theme.ink)
                Text("\(purchase.purchasedOn) • \(purchase.boutique)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.muted)
            }

            Spacer()

            Text(purchase.price)
                .font(.headline.weight(.black))
                .foregroundStyle(Theme.ink)
        }
        .padding(12)
        .background(.white.opacity(0.54), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct ClientWishlistInsightSection: View {
    let products: [SalesProduct]

    var body: some View {
        if !products.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Wishlist")
                        .font(.title3.weight(.black))
                    Spacer()
                    Text("\(products.count) saved")
                        .font(.caption.weight(.black))
                        .foregroundStyle(Theme.gold)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 7)
                        .background(Theme.selected, in: Capsule())
                }

                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(products) { product in
                            ClientWishlistProductCard(product: product)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .scrollIndicators(.hidden)
            }
            .padding(16)
            .background(.white.opacity(0.56), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Theme.line.opacity(0.45), lineWidth: 1)
            )
        }
    }
}

private struct ClientWishlistProductCard: View {
    let product: SalesProduct

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ProductImageView(imageName: product.imageName)
                .frame(width: 126, height: 92)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Text(product.name)
                .font(.subheadline.weight(.black))
                .foregroundStyle(Theme.ink)
                .lineLimit(1)

            Text(product.price)
                .font(.caption.weight(.black))
                .foregroundStyle(Theme.muted)
        }
        .frame(width: 140, alignment: .leading)
        .padding(10)
        .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Theme.line.opacity(0.45), lineWidth: 1)
        )
    }
}

private struct ClientTaskRow: View {
    let task: ClientTask
    let isActionable: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
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
                    .foregroundStyle(isActionable ? Theme.muted.opacity(0.72) : Theme.muted.opacity(0.24))
            }
        }
        .buttonStyle(.plain)
        .disabled(!isActionable)
        .accessibilityLabel(task.title)
    }
}

private struct ClientPanelBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.headline.weight(.black))
                .foregroundStyle(Theme.ink)
                .frame(width: 44, height: 44)
                .background(.white.opacity(0.72), in: Circle())
                .overlay(
                    Circle()
                        .stroke(Theme.line.opacity(0.45), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }
}

private struct ClientConsentApprovalPanel: View {
    let client: ClientProfile
    let onBack: () -> Void
    let onSave: (Bool, Bool, String) -> Void

    @State private var preferenceVisibilityAllowed = false
    @State private var purchaseHistoryAllowed = false
    @State private var isSaved = false

    init(
        client: ClientProfile,
        onBack: @escaping () -> Void,
        onSave: @escaping (Bool, Bool, String) -> Void
    ) {
        self.client = client
        self.onBack = onBack
        self.onSave = onSave
        _preferenceVisibilityAllowed = State(initialValue: client.hasClientInsightConsent)
        _purchaseHistoryAllowed = State(initialValue: client.hasClientInsightConsent)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 14) {
                ClientPanelBackButton(action: onBack)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Preference Consent")
                        .font(.title2.weight(.black))
                        .foregroundStyle(Theme.ink)
                    Text("Take approval before showing preferences and purchase history to Sales Associate.")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.muted)
                }

                Spacer()

                Text(isSaved ? "Saved" : "Pending")
                    .font(.caption.weight(.black))
                    .foregroundStyle(Theme.gold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Theme.selected, in: Capsule())
            }

            HStack(spacing: 14) {
                ClientAvatar(initials: client.initials, size: 58)

                VStack(alignment: .leading, spacing: 4) {
                    Text(client.name)
                        .font(.title3.weight(.black))
                    Text("\(client.phone) • \(client.boutique)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.muted)
                }

                Spacer()
            }
            .padding(16)
            .background(Theme.selected.opacity(0.65), in: RoundedRectangle(cornerRadius: 22, style: .continuous))

            VStack(spacing: 12) {
                ConsentToggleRow(
                    title: "Client allows preference visibility",
                    subtitle: "Style, size, material and budget can be visible in clienteling.",
                    icon: "eye",
                    isOn: $preferenceVisibilityAllowed
                )

                ConsentToggleRow(
                    title: "Client allows purchase history visibility",
                    subtitle: "Past purchases can be used for recommendations and follow-up.",
                    icon: "bag.badge.checkmark",
                    isOn: $purchaseHistoryAllowed
                )
            }

            Button {
                onSave(preferenceVisibilityAllowed, purchaseHistoryAllowed, "")
                isSaved = true
            } label: {
                Label(isSaved ? "Consent Captured" : "Capture Consent", systemImage: isSaved ? "checkmark.seal.fill" : "checkmark.shield")
                    .font(.headline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .foregroundStyle(.white)
                    .background(Theme.goldGradient, in: Capsule())
            }
            .buttonStyle(.plain)
            .disabled(!preferenceVisibilityAllowed && !purchaseHistoryAllowed)
            .opacity((preferenceVisibilityAllowed || purchaseHistoryAllowed) ? 1 : 0.55)
        }
    }
}

private struct ConsentToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.headline.weight(.black))
                .foregroundStyle(Theme.gold)
                .frame(width: 44, height: 44)
                .background(Theme.selected, in: RoundedRectangle(cornerRadius: 15, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(Theme.ink)
                Text(subtitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Theme.gold)
        }
        .padding(14)
        .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Theme.line.opacity(0.45), lineWidth: 1)
        )
    }
}

private struct ClientPreferenceEditPanel: View {
    let client: ClientProfile
    let onBack: () -> Void
    let onSave: (String, String, String, String, String, String) -> Void

    @State private var preferredStyle: String
    @State private var budget: String
    @State private var size: String
    @State private var materialPreference: String
    @State private var colorPreference: String
    @State private var preferenceNote: String
    @State private var savedSummary: String?

    private let styles = ["N/A", "Minimal", "Statement", "Classic", "Bridal", "Evening"]
    private let budgets = ["N/A", "Rs. 50K+", "Rs. 1L+", "Rs. 2L+", "Rs. 5L+"]
    private let sizes = ["N/A", "EU 36", "EU 38", "EU 40", "One size"]
    private let materials = ["N/A", "Gold hardware", "Silver hardware", "Pearl", "Diamond", "Leather"]

    init(
        client: ClientProfile,
        onBack: @escaping () -> Void,
        onSave: @escaping (String, String, String, String, String, String) -> Void
    ) {
        self.client = client
        self.onBack = onBack
        self.onSave = onSave
        _preferredStyle = State(initialValue: Self.savedAttribute("Style", in: client))
        _budget = State(initialValue: Self.savedAttribute("Budget", in: client))
        _size = State(initialValue: Self.savedAttribute("Size", in: client))
        _materialPreference = State(initialValue: Self.savedAttribute("Preference", in: client))
        _colorPreference = State(initialValue: Self.savedAttribute("Color", in: client, fallback: ""))
        _preferenceNote = State(initialValue: Self.savedNote(in: client))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 14) {
                ClientPanelBackButton(action: onBack)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Add Preferences")
                        .font(.title2.weight(.black))
                        .foregroundStyle(Theme.ink)
                    Text("Capture optional preferences only when client shares them.")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.muted)
                }

                Spacer()

                Text(client.name)
                    .font(.caption.weight(.black))
                    .foregroundStyle(Theme.gold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Theme.selected, in: Capsule())
            }

            HStack(alignment: .top, spacing: 14) {
                ProfileDropdown(title: "Style", options: styles, selection: $preferredStyle)
                ProfileDropdown(title: "Budget", options: budgets, selection: $budget)
            }

            HStack(alignment: .top, spacing: 14) {
                ProfileDropdown(title: "Size", options: sizes, selection: $size)
                ProfileDropdown(title: "Material", options: materials, selection: $materialPreference)
            }

            ProfileTextField(title: "Color Preference", placeholder: "champagne, black, emerald...", text: $colorPreference)

            VStack(alignment: .leading, spacing: 8) {
                Text("Preference Note")
                    .font(.headline.weight(.black))
                TextEditor(text: $preferenceNote)
                    .scrollContentBackground(.hidden)
                    .padding(10)
                    .frame(minHeight: 130)
                    .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Theme.line.opacity(0.45), lineWidth: 1)
                    )
                    .overlay(alignment: .topLeading) {
                        if preferenceNote.isEmpty {
                            Text("Add occasion, product interest, dislikes, or follow-up preference...")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.muted.opacity(0.66))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 18)
                        }
                    }
            }

            if let savedSummary {
                Label(savedSummary, systemImage: "checkmark.seal")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(Theme.gold)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.selected.opacity(0.62), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }

            Button {
                let summary = preferenceSummary
                onSave(preferredStyle, budget, size, materialPreference, colorPreference, preferenceNote)
                savedSummary = summary
            } label: {
                Label("Save Preferences", systemImage: "heart.text.square")
                    .font(.headline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .foregroundStyle(.white)
                    .background(Theme.goldGradient, in: Capsule())
            }
            .buttonStyle(.plain)
            .disabled(preferenceSummary == "No preference selected")
            .opacity(preferenceSummary == "No preference selected" ? 0.55 : 1)
        }
    }

    private var preferenceSummary: String {
        let values = [
            preferredStyle,
            budget,
            size,
            materialPreference,
            colorPreference,
            preferenceNote
        ]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0 != "N/A" }

        guard !values.isEmpty else {
            return "No preference selected"
        }

        return "Saved: \(values.prefix(3).joined(separator: ", "))"
    }

    private static func savedAttribute(_ title: String, in client: ClientProfile, fallback: String = "N/A") -> String {
        guard let rawValue = client.attributes.first(where: { $0.title.caseInsensitiveCompare(title) == .orderedSame })?.value else {
            return fallback
        }

        let value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            !value.isEmpty,
            value != "N/A",
            value != "Hidden until consent"
        else {
            return fallback
        }

        return value
    }

    private static func savedNote(in client: ClientProfile) -> String {
        let note = client.note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !note.isEmpty,
              note != "New client profile created. Preferences pending.",
              !note.lowercased().hasPrefix("new client prefers ")
        else {
            return ""
        }

        return note
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
    @State private var isFilterPresented = false
    @State private var audienceFilter = SellAudienceFilter.all
    @State private var availabilityFilter = SellAvailabilityFilter.all
    @State private var priceFilter = SellPriceFilter.all
    @State private var showsDiscountedOnly = false
    @State private var expandedCategoryIDs: Set<String> = []
    @State private var isTopSuggestionsExpanded = false

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

    private var browserTitle: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? activeCategoryTitle : "Search Results"
    }

    private var filteredProducts: [SalesProduct] {
        let searchTerm = query.trimmingCharacters(in: .whitespacesAndNewlines)

        let baseProducts: [SalesProduct]
        if !searchTerm.isEmpty {
            baseProducts = products.filter { $0.matches(searchTerm) }
        } else {
            baseProducts = products.filter { $0.categoryID == selectedCategoryID }
        }

        return applyActiveFilters(to: baseProducts)
    }

    private var suggestedProducts: [SalesProduct] {
        let categoryMatches = applyActiveFilters(to: products.filter { $0.categoryID == selectedCategoryID })
        return categoryMatches.isEmpty ? applyActiveFilters(to: products) : categoryMatches
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

    private var isCategoryExpanded: Bool {
        expandedCategoryIDs.contains(selectedCategoryID)
    }

    private func applyActiveFilters(to sourceProducts: [SalesProduct]) -> [SalesProduct] {
        sourceProducts.filter { product in
            audienceFilter.matches(product)
                && availabilityFilter.matches(product)
                && priceFilter.matches(product)
                && (!showsDiscountedOnly || product.originalPrice != nil)
        }
    }

    private func toggleCurrentCategoryViewAll() {
        if expandedCategoryIDs.contains(selectedCategoryID) {
            expandedCategoryIDs.remove(selectedCategoryID)
        } else {
            expandedCategoryIDs.insert(selectedCategoryID)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                SellHeader(session: session)

                if session.activePanel == nil {
                    SellSearchRow(
                        query: $query,
                        showsClientActions: session.hasActiveClient,
                        cartCount: session.cartItemCount,
                        onOpenFilters: {
                            isFilterPresented = true
                        },
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
                        isTopSuggestionsExpanded = false
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
                        primaryActionTitle: "Proceed",
                        primaryActionIcon: "arrow.right.circle",
                        quantityForProduct: { product in
                            session.quantity(for: product)
                        },
                        onPrimaryAction: {
                            selectedProduct = nil
                            session.activePanel = .fulfillment
                        }
                    )
                } else if session.activePanel == .fulfillment {
                    CheckoutFulfillmentPanel(
                        client: session.createdClient,
                        onBack: {
                            session.activePanel = .cart
                        },
                        onSaveDefaultAddress: { updatedClient in
                            session.createdClient = updatedClient
                            onCreateProfile(updatedClient)
                        }
                    )
                } else if session.activePanel == .createProfile {
                    CreateClientProfilePanel(
                        guestID: session.guestID ?? "Guest",
                        onBack: {
                            session.activePanel = returnPanelAfterProfile
                        },
                        onSave: { profile in
                            session.createdClient = profile
                            session.activePanel = returnPanelAfterProfile
                            onCreateProfile(profile)
                        }
                    )
                } else if let selectedProduct {
                    HStack(alignment: .top, spacing: 18) {
                        SellProductBrowser(
                            title: browserTitle,
                            products: filteredProducts,
                            suggestedProducts: suggestedProducts,
                            selectedProduct: selectedProduct,
                            allowsWishlist: session.hasActiveClient,
                            isExpanded: isCategoryExpanded,
                            isTopSuggestionsExpanded: isTopSuggestionsExpanded,
                            isWishlisted: { product in
                                session.isWishlisted(product)
                            },
                            onToggleWishlist: { product in
                                session.toggleWishlist(product)
                            },
                            onToggleTopSuggestions: {
                                isTopSuggestionsExpanded.toggle()
                            },
                            onToggleViewAll: {
                                toggleCurrentCategoryViewAll()
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
                        title: browserTitle,
                        products: filteredProducts,
                        suggestedProducts: suggestedProducts,
                        selectedProduct: nil,
                        allowsWishlist: session.hasActiveClient,
                        isExpanded: isCategoryExpanded,
                        isTopSuggestionsExpanded: isTopSuggestionsExpanded,
                        isWishlisted: { product in
                            session.isWishlisted(product)
                        },
                        onToggleWishlist: { product in
                            session.toggleWishlist(product)
                        },
                        onToggleTopSuggestions: {
                            isTopSuggestionsExpanded.toggle()
                        },
                        onToggleViewAll: {
                            toggleCurrentCategoryViewAll()
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
        .sheet(isPresented: $isFilterPresented) {
            SellFilterPanel(
                audienceFilter: $audienceFilter,
                availabilityFilter: $availabilityFilter,
                priceFilter: $priceFilter,
                showsDiscountedOnly: $showsDiscountedOnly
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
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
    let cartCount: Int
    let onOpenFilters: () -> Void
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

            ToolbarPillButton(title: "Filters", icon: "slider.horizontal.3", action: onOpenFilters)
            if showsClientActions {
                ToolbarPillButton(
                    title: "Wishlist",
                    icon: "heart",
                    action: onOpenWishlist
                )
                ToolbarPillButton(
                    title: "View Cart",
                    icon: "bag",
                    count: cartCount,
                    showsCount: true,
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
    var showsCount: Bool = false
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2.weight(.black))
                    .foregroundStyle(Theme.ink)
                    .frame(width: 30, height: 54)

                if showsCount, count > 0 {
                    Text("\(count)")
                        .font(.headline.weight(.black))
                        .foregroundStyle(Theme.gold)
                        .accessibilityHidden(true)
                }
            }
            .frame(minWidth: 54, minHeight: 54)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(showsCount && count > 0 ? "\(title), \(count) items" : title)
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

private enum SellAudienceFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case women = "Women"
    case men = "Men"

    var id: String { rawValue }

    func matches(_ product: SalesProduct) -> Bool {
        switch self {
        case .all:
            return true
        case .women, .men:
            return product.audience.localizedCaseInsensitiveContains(rawValue)
        }
    }
}

private enum SellAvailabilityFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case inBoutique = "In Boutique"
    case transfer = "Transfer"
    case limited = "Limited"

    var id: String { rawValue }

    func matches(_ product: SalesProduct) -> Bool {
        switch self {
        case .all:
            return true
        case .inBoutique:
            return product.availability.localizedCaseInsensitiveContains("boutique")
        case .transfer:
            return product.availability.localizedCaseInsensitiveContains("transfer")
                || product.stockNote.localizedCaseInsensitiveContains("transfer")
                || product.availability.localizedCaseInsensitiveContains("store manager")
        case .limited:
            return product.badge?.localizedCaseInsensitiveContains("limited") == true
                || product.stockNote.localizedCaseInsensitiveContains("limited")
        }
    }
}

private enum SellPriceFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case underOnePointFive = "Under Rs. 1.5L"
    case onePointFiveToThree = "Rs. 1.5L - 3L"
    case aboveThree = "Above Rs. 3L"

    var id: String { rawValue }

    func matches(_ product: SalesProduct) -> Bool {
        guard let price = product.priceInLakhs else {
            return self == .all
        }

        switch self {
        case .all:
            return true
        case .underOnePointFive:
            return price < 1.5
        case .onePointFiveToThree:
            return price >= 1.5 && price <= 3
        case .aboveThree:
            return price > 3
        }
    }
}

private extension SalesProduct {
    var priceInLakhs: Double? {
        let normalized = price
            .replacingOccurrences(of: "Rs.", with: "")
            .replacingOccurrences(of: "₹", with: "")
            .replacingOccurrences(of: "L", with: "")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return Double(normalized)
    }
}

private struct SellFilterPanel: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var audienceFilter: SellAudienceFilter
    @Binding var availabilityFilter: SellAvailabilityFilter
    @Binding var priceFilter: SellPriceFilter
    @Binding var showsDiscountedOnly: Bool

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 22) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Filters")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundStyle(Theme.ink)
                        Text("Refine the visible catalogue for this client conversation.")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.muted)
                    }

                    Spacer()

                    Button {
                        resetFilters()
                    } label: {
                        Text("Reset")
                            .font(.headline.weight(.black))
                            .foregroundStyle(Theme.gold)
                            .padding(.horizontal, 16)
                            .frame(height: 44)
                            .background(Theme.selected, in: Capsule())
                    }
                    .buttonStyle(.plain)

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline.weight(.black))
                            .foregroundStyle(Theme.ink)
                            .frame(width: 44, height: 44)
                            .background(.white.opacity(0.72), in: Circle())
                    }
                    .buttonStyle(.plain)
                }

                HStack(alignment: .top, spacing: 16) {
                    FilterSection(title: "Audience") {
                        FilterChipWrap {
                            ForEach(SellAudienceFilter.allCases) { option in
                                SellFilterChip(
                                    title: option.rawValue,
                                    isSelected: audienceFilter == option
                                ) {
                                    audienceFilter = option
                                }
                            }
                        }
                    }

                    FilterSection(title: "Availability") {
                        FilterChipWrap {
                            ForEach(SellAvailabilityFilter.allCases) { option in
                                SellFilterChip(
                                    title: option.rawValue,
                                    isSelected: availabilityFilter == option
                                ) {
                                    availabilityFilter = option
                                }
                            }
                        }
                    }
                }

                HStack(alignment: .top, spacing: 16) {
                    FilterSection(title: "Price Range") {
                        FilterChipWrap {
                            ForEach(SellPriceFilter.allCases) { option in
                                SellFilterChip(
                                    title: option.rawValue,
                                    isSelected: priceFilter == option
                                ) {
                                    priceFilter = option
                                }
                            }
                        }
                    }

                    FilterSection(title: "Offers") {
                        Toggle(isOn: $showsDiscountedOnly) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Discounted pieces only")
                                    .font(.headline.weight(.black))
                                    .foregroundStyle(Theme.ink)
                                Text("Show products that have a listed original price.")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Theme.muted)
                            }
                        }
                        .toggleStyle(.switch)
                        .tint(Theme.gold)
                        .padding(16)
                        .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                }

                Spacer(minLength: 0)

                Button {
                    dismiss()
                } label: {
                    Label("Apply Filters", systemImage: "checkmark")
                        .font(.headline.weight(.black))
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .foregroundStyle(.white)
                        .background(Theme.goldGradient, in: Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(28)
        }
    }

    private func resetFilters() {
        audienceFilter = .all
        availabilityFilter = .all
        priceFilter = .all
        showsDiscountedOnly = false
    }
}

private struct FilterSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 14) {
                Text(title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(Theme.ink)
                content
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
}

private struct FilterChipWrap<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                content
            }
            .padding(.vertical, 1)
        }
        .scrollIndicators(.hidden)
    }
}

private struct SellFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.black))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .padding(.horizontal, 14)
                .frame(height: 42)
                .foregroundStyle(isSelected ? .white : Theme.ink)
                .background(
                    isSelected ? AnyShapeStyle(Theme.goldGradient) : AnyShapeStyle(.white.opacity(0.68)),
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

private struct SellProductBrowser: View {
    let title: String
    let products: [SalesProduct]
    let suggestedProducts: [SalesProduct]
    let selectedProduct: SalesProduct?
    let allowsWishlist: Bool
    let isExpanded: Bool
    let isTopSuggestionsExpanded: Bool
    let isWishlisted: (SalesProduct) -> Bool
    let onToggleWishlist: (SalesProduct) -> Void
    let onToggleTopSuggestions: () -> Void
    let onToggleViewAll: () -> Void
    let onSelect: (SalesProduct) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 176), spacing: 14)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SuggestedProductsRow(
                products: suggestedProducts,
                allowsWishlist: allowsWishlist,
                isExpanded: isTopSuggestionsExpanded,
                isWishlisted: isWishlisted,
                onToggleWishlist: onToggleWishlist,
                onToggleViewAll: onToggleTopSuggestions,
                onSelect: onSelect
            )

            Card {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(title)
                            .font(.title2.weight(.black))

                        Spacer()

                        if !products.isEmpty {
                            Button(action: onToggleViewAll) {
                                Text(isExpanded ? "Show Less" : "View All")
                                    .font(.caption.weight(.black))
                                    .foregroundStyle(Theme.gold)
                                    .padding(.horizontal, 13)
                                    .padding(.vertical, 8)
                                    .background(Theme.selected, in: Capsule())
                            }
                            .buttonStyle(.plain)
                        }
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
                    } else if isExpanded {
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
                                .frame(height: 288)
                            }
                        }
                    } else {
                        ScrollView(.horizontal) {
                            HStack(spacing: 14) {
                                ForEach(Array(products.prefix(10))) { product in
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
                                    .frame(width: 176, height: 288)
                                }
                            }
                        }
                        .scrollIndicators(.hidden)
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
    let isExpanded: Bool
    let isWishlisted: (SalesProduct) -> Bool
    let onToggleWishlist: (SalesProduct) -> Void
    let onToggleViewAll: () -> Void
    let onSelect: (SalesProduct) -> Void

    private let visibleLimit = 10
    private let columns = [
        GridItem(.adaptive(minimum: 170), spacing: 12)
    ]

    private var visibleProducts: [SalesProduct] {
        isExpanded ? products : Array(products.prefix(visibleLimit))
    }

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Top Suggestions")
                        .font(.title2.weight(.black))
                    Spacer()

                    if products.count > visibleLimit {
                        Button(action: onToggleViewAll) {
                            Text(isExpanded ? "Show Less" : "View All")
                                .font(.caption.weight(.black))
                                .foregroundStyle(Theme.gold)
                                .padding(.horizontal, 13)
                                .padding(.vertical, 8)
                                .background(Theme.selected, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }

                if isExpanded {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(visibleProducts) { product in
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
                            .frame(height: 202)
                        }
                    }
                } else {
                    ScrollView(.horizontal) {
                        HStack(spacing: 12) {
                            ForEach(visibleProducts) { product in
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
                                .frame(width: 170, height: 202)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
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
                .frame(height: 18, alignment: .leading)

            Text(product.price)
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
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
                        .minimumScaleFactor(0.78)
                    Text("\(product.audience) • \(product.id)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.muted)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)
            }

            HStack {
                Text(product.price)
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Spacer()

                if let badge = product.badge {
                    Text(badge)
                        .font(.caption2.weight(.black))
                        .foregroundStyle(Theme.gold)
                        .lineLimit(1)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Theme.selected, in: Capsule())
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 288, maxHeight: 288, alignment: .topLeading)
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

private enum CheckoutFulfillmentMethod: String, CaseIterable, Identifiable {
    case pickup
    case delivery

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pickup:
            return "Take from Store"
        case .delivery:
            return "Deliver to Address"
        }
    }

    var subtitle: String {
        switch self {
        case .pickup:
            return "Client will take products from the boutique now."
        case .delivery:
            return "Search the delivery address before payment."
        }
    }

    var icon: String {
        switch self {
        case .pickup:
            return "bag.fill"
        case .delivery:
            return "shippingbox.fill"
        }
    }
}

private struct AddressSuggestion: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let subtitle: String

    var displayText: String {
        let cleanSubtitle = subtitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanSubtitle.isEmpty else { return title }
        return "\(title), \(cleanSubtitle)"
    }
}

private final class AddressSearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var query = "" {
        didSet {
            let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmedQuery.count >= 2 else {
                suggestions = []
                completer.queryFragment = ""
                return
            }

            completer.queryFragment = trimmedQuery
        }
    }

    @Published var suggestions: [AddressSuggestion] = []

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
        completer.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 19.0760, longitude: 72.8777),
            span: MKCoordinateSpan(latitudeDelta: 0.70, longitudeDelta: 0.70)
        )
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let updatedSuggestions = completer.results.prefix(6).map {
            AddressSuggestion(title: $0.title, subtitle: $0.subtitle)
        }

        DispatchQueue.main.async {
            self.suggestions = updatedSuggestions
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.suggestions = []
        }
    }
}

private struct CheckoutFulfillmentPanel: View {
    let client: ClientProfile?
    let onBack: () -> Void
    let onSaveDefaultAddress: (ClientProfile) -> Void

    @State private var method: CheckoutFulfillmentMethod = .pickup
    @StateObject private var addressCompleter = AddressSearchCompleter()
    @State private var buildingDetail = ""
    @State private var shouldSaveDefaultAddress = false
    @State private var showsAddressSuggestions = false
    @State private var didContinueToPayment = false
    @State private var didPrepareDefaultAddress = false

    private var resolvedAddress: String {
        addressCompleter.query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var resolvedBuildingDetail: String {
        buildingDetail.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canProceedToPay: Bool {
        method == .pickup || !resolvedAddress.isEmpty
    }

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 14) {
                    ClientPanelBackButton(action: onBack)

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Fulfillment")
                            .font(.title2.weight(.black))
                            .foregroundStyle(Theme.ink)
                        Text("Choose how the client wants to take the products.")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.muted)
                    }

                    Spacer()

                    Text(client?.name ?? "Guest")
                        .font(.caption.weight(.black))
                        .foregroundStyle(Theme.gold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Theme.selected, in: Capsule())
                }

                HStack(spacing: 14) {
                    ForEach(CheckoutFulfillmentMethod.allCases) { option in
                        FulfillmentMethodButton(
                            option: option,
                            isSelected: method == option
                        ) {
                            method = option
                            didContinueToPayment = false
                        }
                    }
                }

                if method == .pickup {
                    PickupSummaryCard()
                        .transition(.opacity.combined(with: .move(edge: .top)))
                } else {
                    DeliveryAddressSection(
                        query: Binding(
                            get: { addressCompleter.query },
                            set: { newValue in
                                addressCompleter.query = newValue
                                showsAddressSuggestions = true
                                didContinueToPayment = false
                            }
                        ),
                        buildingDetail: $buildingDetail,
                        shouldSaveDefaultAddress: $shouldSaveDefaultAddress,
                        suggestions: addressCompleter.suggestions,
                        showsSuggestions: showsAddressSuggestions,
                        defaultAddress: client?.defaultDeliveryAddress,
                        onUseDefaultAddress: useDefaultAddress,
                        onSelectSuggestion: selectAddressSuggestion
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Spacer(minLength: 0)

                if didContinueToPayment {
                    Label("Ready to continue payment at POS", systemImage: "checkmark.seal.fill")
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(Theme.gold)
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.selected.opacity(0.66), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }

                Button {
                    saveDefaultAddressIfNeeded()
                    didContinueToPayment = true
                } label: {
                    Label("Proceed to Pay", systemImage: "creditcard")
                        .font(.headline.weight(.black))
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .foregroundStyle(.white)
                        .background(Theme.goldGradient, in: Capsule())
                }
                .buttonStyle(.plain)
                .disabled(!canProceedToPay)
                .opacity(canProceedToPay ? 1 : 0.55)
            }
            .frame(maxWidth: .infinity, minHeight: 560, alignment: .topLeading)
            .animation(.snappy(duration: 0.24), value: method)
            .onAppear(perform: prepareDefaultAddress)
        }
    }

    private func prepareDefaultAddress() {
        guard !didPrepareDefaultAddress else { return }
        didPrepareDefaultAddress = true

        guard let client else { return }
        if let defaultAddress = client.defaultDeliveryAddress, !defaultAddress.isEmpty {
            addressCompleter.query = defaultAddress
        }
        buildingDetail = client.deliveryAddressDetail ?? ""
    }

    private func useDefaultAddress() {
        guard let client, let defaultAddress = client.defaultDeliveryAddress else { return }
        addressCompleter.query = defaultAddress
        buildingDetail = client.deliveryAddressDetail ?? ""
        shouldSaveDefaultAddress = false
        showsAddressSuggestions = false
        didContinueToPayment = false
    }

    private func selectAddressSuggestion(_ suggestion: AddressSuggestion) {
        addressCompleter.query = suggestion.displayText
        showsAddressSuggestions = false
        didContinueToPayment = false
    }

    private func saveDefaultAddressIfNeeded() {
        guard method == .delivery,
              shouldSaveDefaultAddress,
              let client,
              !resolvedAddress.isEmpty
        else {
            return
        }

        onSaveDefaultAddress(
            ClientProfile(
                id: client.id,
                phone: client.phone,
                initials: client.initials,
                name: client.name,
                tier: client.tier,
                lifetimePurchaseAmount: client.lifetimePurchaseAmount,
                boutique: client.boutique,
                lastVisit: client.lastVisit,
                status: client.status,
                note: client.note,
                attributes: client.attributes,
                tasks: client.tasks,
                purchaseHistory: client.purchaseHistory,
                wishlistProductIDs: client.wishlistProductIDs,
                defaultDeliveryAddress: resolvedAddress,
                deliveryAddressDetail: resolvedBuildingDetail.isEmpty ? nil : resolvedBuildingDetail
            )
        )
    }
}

private struct FulfillmentMethodButton: View {
    let option: CheckoutFulfillmentMethod
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: option.icon)
                    .font(.headline.weight(.black))
                    .foregroundStyle(isSelected ? .white : Theme.gold)
                    .frame(width: 44, height: 44)
                    .background(isSelected ? .white.opacity(0.20) : Theme.selected, in: RoundedRectangle(cornerRadius: 15, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(option.title)
                        .font(.headline.weight(.black))
                    Text(option.subtitle)
                        .font(.subheadline.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                        .opacity(0.78)
                }

                Spacer()
            }
            .padding(15)
            .frame(maxWidth: .infinity, minHeight: 102)
            .foregroundStyle(isSelected ? .white : Theme.ink)
            .background(isSelected ? AnyShapeStyle(Theme.goldGradient) : AnyShapeStyle(.white.opacity(0.58)), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(isSelected ? .white.opacity(0.22) : Theme.line.opacity(0.45), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct PickupSummaryCard: View {
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "storefront.fill")
                .font(.title2.weight(.black))
                .foregroundStyle(Theme.gold)
                .frame(width: 58, height: 58)
                .background(Theme.selected, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text("Store pickup selected")
                    .font(.title3.weight(.black))
                    .foregroundStyle(Theme.ink)
                Text("The client can take the confirmed products from South Mumbai boutique after payment.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Theme.line.opacity(0.45), lineWidth: 1)
        )
    }
}

private struct DeliveryAddressSection: View {
    @Binding var query: String
    @Binding var buildingDetail: String
    @Binding var shouldSaveDefaultAddress: Bool

    let suggestions: [AddressSuggestion]
    let showsSuggestions: Bool
    let defaultAddress: String?
    let onUseDefaultAddress: () -> Void
    let onSelectSuggestion: (AddressSuggestion) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("Delivery Details")
                    .font(.title3.weight(.black))
                    .foregroundStyle(Theme.ink)

                Spacer()

                if let defaultAddress, !defaultAddress.isEmpty {
                    Button(action: onUseDefaultAddress) {
                        Label("Use saved address", systemImage: "location.fill")
                            .font(.caption.weight(.black))
                            .foregroundStyle(Theme.gold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Theme.selected, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Address".uppercased())
                    .font(.caption.weight(.black))
                    .foregroundStyle(Theme.muted)

                HStack(spacing: 10) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.headline.weight(.black))
                        .foregroundStyle(Theme.gold)
                    TextField("Search delivery address", text: $query)
                        .font(.headline.weight(.bold))
                        .textInputAutocapitalization(.words)
                }
                .padding(.horizontal, 14)
                .frame(minHeight: 52)
                .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                if showsSuggestions && !suggestions.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(suggestions) { suggestion in
                            Button {
                                onSelectSuggestion(suggestion)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "location")
                                        .font(.subheadline.weight(.black))
                                        .foregroundStyle(Theme.gold)
                                        .frame(width: 34, height: 34)
                                        .background(Theme.selected, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(suggestion.title)
                                            .font(.subheadline.weight(.black))
                                            .foregroundStyle(Theme.ink)
                                            .lineLimit(1)
                                        if !suggestion.subtitle.isEmpty {
                                            Text(suggestion.subtitle)
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(Theme.muted)
                                                .lineLimit(1)
                                        }
                                    }

                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                            }
                            .buttonStyle(.plain)

                            if suggestion.id != suggestions.last?.id {
                                Divider()
                                    .overlay(Theme.line.opacity(0.36))
                            }
                        }
                    }
                    .background(.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Theme.line.opacity(0.45), lineWidth: 1)
                    )
                }
            }

            ProfileTextField(
                title: "Building / Flat / Floor",
                placeholder: "optional",
                text: $buildingDetail
            )

            Button {
                shouldSaveDefaultAddress.toggle()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: shouldSaveDefaultAddress ? "checkmark.square.fill" : "square")
                        .font(.title3.weight(.black))
                        .foregroundStyle(shouldSaveDefaultAddress ? Theme.gold : Theme.muted)

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Set as default delivery address")
                            .font(.headline.weight(.black))
                            .foregroundStyle(Theme.ink)
                        Text("Save this address to the client's profile for future orders.")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.muted)
                    }

                    Spacer()
                }
                .padding(14)
                .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Theme.line.opacity(0.45), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(.white.opacity(0.48), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Theme.line.opacity(0.45), lineWidth: 1)
        )
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
    let onBack: () -> Void
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
                HStack(alignment: .top, spacing: 14) {
                    ClientPanelBackButton(action: onBack)

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
        let resolvedNote = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let visibleAttributes = profileAttributes()

        return ClientProfile(
            id: "CL-\(Int.random(in: 2000...9999))",
            phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
            initials: initials(for: name),
            name: name,
            tier: "Normal",
            lifetimePurchaseAmount: 0,
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
                    subtitle: capturedPreferences.isEmpty ? "No optional preference data saved" : (consentAccepted ? preferenceSummary : "Other preferences require client consent")
                )
            ]
        )
    }

    private func profileAttributes() -> [ClientAttribute] {
        var attributes: [ClientAttribute] = []
        appendAttribute("Size", value: size, to: &attributes)
        appendAttribute("Style", value: preferredStyle, to: &attributes)
        appendAttribute("Budget", value: budget, to: &attributes)
        appendAttribute("Preference", value: materialPreference, to: &attributes)
        appendAttribute("Color", value: colorPreference, to: &attributes)
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

// MARK: - Supabase Auth Integration

struct UserMetadata: Codable {
    var passwordChanged: Bool?
    var initials: String?
    var name: String?
    var role: String?
    var boutique: String?
    var phone: String?
    var employeeID: String?
    var shift: String?

    enum CodingKeys: String, CodingKey {
        case passwordChanged = "password_changed"
        case initials
        case name
        case role
        case boutique
        case phone
        case employeeID = "employee_id"
        case shift
    }
}

struct SupabaseUser: Codable {
    let id: UUID
    let email: String?
    let userMetadata: UserMetadata?
    let createdAt: String?
    let lastSignInAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case userMetadata = "user_metadata"
        case createdAt = "created_at"
        case lastSignInAt = "last_sign_in_at"
    }
}

struct SupabaseSession: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let refreshToken: String
    let user: SupabaseUser

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case user
    }
}

enum AuthError: Error, LocalizedError {
    case invalidResponse
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response received from authentication server."
        case .serverError(let message):
            return message
        }
    }
}

class SupabaseAuthService {
    static let shared = SupabaseAuthService()

    private let baseURL = "https://zfengirsvsjikrhxrfit.supabase.co/auth/v1"
    private let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpmZW5naXJzdnNqaWtyaHhyZml0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI0MTg5NTIsImV4cCI6MjA5Nzk5NDk1Mn0.rk57GzYVJDkHtEH649eXekzqox0s3O3nH3u8f5KHY5M"

    func login(email: String, password: String) async throws -> SupabaseSession {
        guard let url = URL(string: "\(baseURL)/token?grant_type=password") else {
            throw AuthError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["email": email, "password": password]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }

        if httpResponse.statusCode != 200 {
            if let errorObj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = errorObj["error_description"] as? String ?? errorObj["msg"] as? String {
                throw AuthError.serverError(message)
            }
            throw AuthError.serverError("Authentication failed (Status code: \(httpResponse.statusCode))")
        }

        return try JSONDecoder().decode(SupabaseSession.self, from: data)
    }

    func changePassword(accessToken: String, newPassword: String) async throws -> SupabaseUser {
        guard let url = URL(string: "\(baseURL)/user") else {
            throw AuthError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "password": newPassword,
            "data": [
                "password_changed": true
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }

        if httpResponse.statusCode != 200 {
            if let errorObj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = errorObj["msg"] as? String ?? errorObj["error_description"] as? String {
                throw AuthError.serverError(message)
            }
            throw AuthError.serverError("Password change failed (Status code: \(httpResponse.statusCode))")
        }

        return try JSONDecoder().decode(SupabaseUser.self, from: data)
    }
}

#Preview("iPad Today", traits: .landscapeLeft) {
    ContentView()
}
