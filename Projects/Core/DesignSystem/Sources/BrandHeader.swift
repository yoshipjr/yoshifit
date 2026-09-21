import SwiftUI

public struct BrandHeader: View {
    public init() {}

    public var body: some View {
        HStack(spacing: 8) {
            Image("BrandMark", bundle: .main)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)
            Text(AppBrand.displayName)
                .font(.title2.bold().italic())
                .foregroundStyle(.white)

            Spacer()
        }
        .padding(.horizontal, AppSpacing.medium)
        .padding(.vertical, AppSpacing.small)
    }
}

#Preview {
    BrandHeader()
        .background(AppColor.brand)
}
