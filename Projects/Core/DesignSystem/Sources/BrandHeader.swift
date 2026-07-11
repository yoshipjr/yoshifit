import SwiftUI

public struct BrandHeader: View {
    private let notificationCount: Int
    private let onTapNotifications: (() -> Void)?
    private let onTapProfile: (() -> Void)?

    public init(
        notificationCount: Int = 0,
        onTapNotifications: (() -> Void)? = nil,
        onTapProfile: (() -> Void)? = nil
    ) {
        self.notificationCount = notificationCount
        self.onTapNotifications = onTapNotifications
        self.onTapProfile = onTapProfile
    }

    public var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image("BrandMark", bundle: .main)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
                Text(AppBrand.displayName)
                    .font(.title2.bold().italic())
                    .foregroundStyle(.white)
            }

            Spacer()

            Button(action: { onTapNotifications?() }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(.white)
                        .font(.title3)
                    if notificationCount > 0 {
                        Text("\(notificationCount)")
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                            .padding(4)
                            .background(AppColor.danger, in: Circle())
                            .offset(x: 10, y: -8)
                    }
                }
            }
            .padding(.trailing, AppSpacing.small)

            Button(action: { onTapProfile?() }) {
                Image(systemName: "person.circle")
                    .foregroundStyle(.white)
                    .font(.title2)
            }
        }
        .padding(.horizontal, AppSpacing.medium)
        .padding(.vertical, AppSpacing.small)
    }
}

#Preview {
    BrandHeader(notificationCount: 6)
        .background(AppColor.brand)
}
