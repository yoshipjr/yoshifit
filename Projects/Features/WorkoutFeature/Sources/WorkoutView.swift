import SwiftUI
import CoreKit

public struct WorkoutView: View {
    @State private var viewModel = WorkoutViewModel()

    public init() {}

    public var body: some View {
        NavigationStack {
            RecordEntryView()
        }
        .task { await viewModel.onAppear() }
    }
}

#Preview {
    WorkoutView()
        .modelContainer(PersistenceController.makeContainer(inMemory: true))
}
