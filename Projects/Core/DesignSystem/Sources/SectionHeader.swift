import SwiftUI

public struct SectionHeader: View {
    private let title: String

    public init(title: String) {
        self.title = title
    }

    public var body: some View {
        Text(title)
            .font(.title2.bold())
    }
}

#Preview {
    SectionHeader(title: "プレビュー")
}
