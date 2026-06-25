import SwiftUI

enum IssueWorkspaceMode: String, CaseIterable, Identifiable, Equatable {
    case returnExchange = "Return / Exchange"
    case repair = "Repair"
    case services = "Services"
    case history = "History"

    var id: String { rawValue }
}

struct IssueContent: View {
    let dashboard: IssueDashboard
    let products: [SalesProduct]

    @State private var selectedMode: IssueWorkspaceMode = .returnExchange
    @State private var selectedReturnExchangeType: String
    @State private var returnReason = ""
    @State private var repairIssue = ""
    @State private var repairCharge = "Rs. 2,500"
    @State private var repairStatus: String
    @State private var selectedServiceType: String
    @State private var serviceIssue = ""

    init(dashboard: IssueDashboard, products: [SalesProduct]) {
        self.dashboard = dashboard
        self.products = products
        _selectedReturnExchangeType = State(initialValue: dashboard.returnExchangeTypes.first ?? "Exchange")
        _repairStatus = State(initialValue: dashboard.repairStatuses.first ?? "Assessment pending")
        _selectedServiceType = State(initialValue: dashboard.serviceTypes.first ?? "Cleaning")
    }

    private var repairProduct: SalesProduct? {
        products.first(where: { $0.id == "HB-224" }) ?? products.first
    }

    private var serviceProduct: SalesProduct? {
        products.first(where: { $0.id == "JW-311" }) ?? products.first
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                IssueHeader()

                Card {
                    VStack(alignment: .leading, spacing: 18) {
                        IssueModePicker(selectedMode: $selectedMode)

                        switch selectedMode {
                        case .returnExchange:
                            ReturnExchangePane(
                                types: dashboard.returnExchangeTypes,
                                selectedType: $selectedReturnExchangeType,
                                reason: $returnReason
                            )
                        case .repair:
                            RepairPane(
                                product: repairProduct,
                                statusOptions: dashboard.repairStatuses,
                                issue: $repairIssue,
                                charge: $repairCharge,
                                status: $repairStatus
                            )
                        case .services:
                            ServicesPane(
                                product: serviceProduct,
                                serviceTypes: dashboard.serviceTypes,
                                selectedServiceType: $selectedServiceType,
                                serviceIssue: $serviceIssue
                            )
                        case .history:
                            IssueHistoryPane(items: dashboard.historyItems)
                        }
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 22)
        }
        .scrollIndicators(.hidden)
        .animation(.snappy(duration: 0.24), value: selectedMode)
    }
}

private struct IssueHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("9:41")
                .font(.headline.weight(.bold))
            Text("Issue")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct IssueModePicker: View {
    @Binding var selectedMode: IssueWorkspaceMode

    var body: some View {
        HStack(spacing: 6) {
            ForEach(IssueWorkspaceMode.allCases) { mode in
                Button {
                    selectedMode = mode
                } label: {
                    Text(mode.rawValue)
                        .font(.subheadline.weight(.black))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .foregroundStyle(selectedMode == mode ? .white : Theme.muted)
                        .background(
                            selectedMode == mode ? AnyShapeStyle(Theme.bestBar) : AnyShapeStyle(.clear),
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(.white.opacity(0.76), in: Capsule())
        .overlay(
            Capsule()
                .stroke(Theme.line.opacity(0.55), lineWidth: 1)
        )
    }
}

private struct ReturnExchangePane: View {
    let types: [String]
    @Binding var selectedType: String
    @Binding var reason: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            IssuePaneTitle(
                title: "Return / Exchange Request",
                subtitle: "Capture details and send exception request to Store Manager",
                badge: "SM route"
            )

            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 14) {
                    IssueDropdownMenu(
                        title: "Type",
                        options: types,
                        selection: $selectedType
                    )

                    IssueTextArea(
                        title: "Reason",
                        placeholder: "Write the reason for return, exchange, or cancellation review...",
                        text: $reason,
                        minHeight: 184
                    )
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 12) {
                    IssueEvidenceButton(title: "Photo", subtitle: "Add product proof", icon: "camera")
                    IssueEvidenceButton(title: "Receipt", subtitle: "Attach purchase receipt", icon: "doc.text")
                }
                .frame(width: 270)
            }

            IssueGuidanceBanner(
                icon: "person.badge.shield.checkmark",
                title: "\(selectedType) request ready for Store Manager",
                subtitle: "Sales Associate records the client reason and evidence. Store Manager approves or rejects the request."
            )

            IssuePrimaryButton(title: "Send Request to Store Manager", icon: "paperplane")
        }
    }
}

private struct RepairPane: View {
    let product: SalesProduct?
    let statusOptions: [String]
    @Binding var issue: String
    @Binding var charge: String
    @Binding var status: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            IssuePaneTitle(
                title: "Repair Request",
                subtitle: "Record repair issue, estimated charge, and SA status before receipt generation",
                badge: "Receipt"
            )

            HStack(alignment: .top, spacing: 16) {
                IssueProductSummaryCard(product: product, title: "Product")
                    .frame(width: 292)

                VStack(alignment: .leading, spacing: 14) {
                    IssueTextArea(
                        title: "Issue",
                        placeholder: "Describe repair issue, visible damage, or client concern...",
                        text: $issue,
                        minHeight: 150
                    )

                    HStack(spacing: 12) {
                        IssueTextField(title: "Charge", placeholder: "Estimated charge", text: $charge)
                        IssueDropdownMenu(title: "Status by Sales Associate", options: statusOptions, selection: $status)
                    }

                    IssueGuidanceBanner(
                        icon: "wrench.adjustable",
                        title: "Repair note will be attached to the receipt",
                        subtitle: "Use this after Store Manager confirms whether the repair can be accepted."
                    )

                    IssuePrimaryButton(title: "Generate Receipt", icon: "receipt")
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct ServicesPane: View {
    let product: SalesProduct?
    let serviceTypes: [String]
    @Binding var selectedServiceType: String
    @Binding var serviceIssue: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            IssuePaneTitle(
                title: "Service Request",
                subtitle: "Capture service evidence and send request to Store Manager",
                badge: "SM route"
            )

            HStack(alignment: .top, spacing: 16) {
                VStack(spacing: 14) {
                    IssueProductSummaryCard(product: product, title: "Product")
                    IssueEvidenceButton(title: "Receipt", subtitle: "Attach service receipt", icon: "doc.text")
                }
                .frame(width: 292)

                VStack(alignment: .leading, spacing: 14) {
                    IssueDropdownMenu(
                        title: "Type of Service Issue",
                        options: serviceTypes,
                        selection: $selectedServiceType
                    )

                    IssueTextArea(
                        title: "Service Issue",
                        placeholder: "Write service issue, client request, and any visible proof...",
                        text: $serviceIssue,
                        minHeight: 214
                    )

                    IssuePrimaryButton(title: "Submit to Store Manager", icon: "paperplane")
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct IssueHistoryPane: View {
    let items: [IssueHistoryItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            IssuePaneTitle(
                title: "Request History",
                subtitle: "Past requests sent to Store Manager with approval or rejection status",
                badge: "\(items.count) updates"
            )

            LazyVStack(spacing: 12) {
                ForEach(items) { item in
                    IssueHistoryRow(item: item)
                }
            }
        }
    }
}

private struct IssuePaneTitle: View {
    let title: String
    let subtitle: String
    let badge: String

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2.weight(.black))
                Text(subtitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }

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

private struct IssueDropdownMenu: View {
    let title: String
    let options: [String]
    @Binding var selection: String

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button {
                    selection = option
                } label: {
                    Text(option)
                }
            }
        } label: {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title.uppercased())
                        .font(.caption.weight(.black))
                        .tracking(1.1)
                        .foregroundStyle(Theme.muted)
                    Text(selection)
                        .font(.headline.weight(.black))
                        .foregroundStyle(Theme.ink)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Theme.gold)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
            .background(.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Theme.line.opacity(0.55), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct IssueTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title.uppercased())
                .font(.caption.weight(.black))
                .tracking(1.1)
                .foregroundStyle(Theme.muted)

            TextField(placeholder, text: $text)
                .font(.headline.weight(.black))
                .textInputAutocapitalization(.words)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
        .background(.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Theme.line.opacity(0.55), lineWidth: 1)
        )
    }
}

private struct IssueTextArea: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let minHeight: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline.weight(.black))

            TextEditor(text: $text)
                .font(.subheadline.weight(.semibold))
                .scrollContentBackground(.hidden)
                .padding(10)
                .frame(minHeight: minHeight)
                .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Theme.line.opacity(0.45), lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.muted.opacity(0.66))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 18)
                    }
                }
        }
    }
}

private struct IssueEvidenceButton: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        Button {
        } label: {
            VStack(spacing: 11) {
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .black))
                    .foregroundStyle(Theme.gold)
                    .frame(width: 66, height: 66)
                    .background(Theme.selected, in: RoundedRectangle(cornerRadius: 22, style: .continuous))

                VStack(spacing: 4) {
                    Text(title)
                        .font(.title3.weight(.black))
                        .foregroundStyle(Theme.ink)
                    Text(subtitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.muted)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 152)
            .padding(.horizontal, 14)
            .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Theme.line.opacity(0.48), style: StrokeStyle(lineWidth: 1, dash: [8, 7]))
            )
        }
        .buttonStyle(.plain)
    }
}

private struct IssueProductSummaryCard: View {
    let product: SalesProduct?
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title.uppercased())
                .font(.caption.weight(.black))
                .tracking(1.1)
                .foregroundStyle(Theme.muted)

            if let product {
                ProductImageView(imageName: product.imageName)
                    .frame(height: 176)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    Text(product.name)
                        .font(.title3.weight(.black))
                        .foregroundStyle(Theme.ink)
                        .lineLimit(1)
                    Text("\(product.id) • \(product.price)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.muted)
                    Text(product.availability)
                        .font(.caption.weight(.black))
                        .foregroundStyle(Theme.gold)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 7)
                        .background(Theme.selected, in: Capsule())
                }
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "photo")
                        .font(.title.weight(.bold))
                        .foregroundStyle(Theme.gold)
                    Text("No product selected")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Theme.ink)
                }
                .frame(maxWidth: .infinity, minHeight: 232)
            }
        }
        .padding(14)
        .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Theme.line.opacity(0.45), lineWidth: 1)
        )
    }
}

private struct IssueGuidanceBanner: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3.weight(.black))
                .foregroundStyle(Theme.gold)
                .frame(width: 48, height: 48)
                .background(Theme.selected, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(Theme.ink)
                Text(subtitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(14)
        .background(Theme.selected.opacity(0.55), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct IssuePrimaryButton: View {
    let title: String
    let icon: String

    var body: some View {
        Button {
        } label: {
            Label(title, systemImage: icon)
                .font(.headline.weight(.black))
                .frame(maxWidth: .infinity, minHeight: 56)
                .foregroundStyle(.white)
                .background(Theme.goldGradient, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct IssueHistoryRow: View {
    let item: IssueHistoryItem

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: item.icon)
                .font(.headline.weight(.black))
                .foregroundStyle(item.status.tint)
                .frame(width: 50, height: 50)
                .background(item.status.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline) {
                    Text(item.title)
                        .font(.headline.weight(.black))
                        .foregroundStyle(Theme.ink)
                    Spacer()
                    Text(item.time)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.muted)
                }

                HStack(spacing: 8) {
                    Text(item.requestType)
                        .font(.caption.weight(.black))
                        .foregroundStyle(Theme.muted)
                    Text(item.status.rawValue)
                        .font(.caption.weight(.black))
                        .foregroundStyle(item.status.tint)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(item.status.background, in: Capsule())
                }

                Text(item.note)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Theme.line.opacity(0.45), lineWidth: 1)
        )
    }
}

private extension IssueApprovalStatus {
    var tint: Color {
        switch self {
        case .approved:
            return Theme.gold
        case .rejected:
            return Color(red: 0.68, green: 0.28, blue: 0.24)
        case .pending:
            return Theme.muted
        }
    }

    var background: Color {
        switch self {
        case .approved:
            return Theme.selected
        case .rejected:
            return Color(red: 0.98, green: 0.88, blue: 0.84)
        case .pending:
            return .white.opacity(0.66)
        }
    }
}
