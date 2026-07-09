import SwiftUI
import SwiftData
import CoreKit
import DesignSystem

public struct MenuView: View {
    @Query(sort: \Exercise.sortOrder) private var exercises: [Exercise]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = MenuViewModel()
    @State private var selectedTab: MenuTab?
    @State private var searchText = ""
    @State private var sort: MenuSort = .default
    @State private var isPresentingAddExercise = false
    @State private var infoExercise: Exercise?

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                tabBar
                filterBar
                exerciseList
            }
            .background(AppColor.screenBackground)
            .navigationTitle("トレーニング作成")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(alignment: .bottomTrailing) {
                Button {
                    isPresentingAddExercise = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(AppColor.brand, in: Circle())
                        .shadow(radius: 4)
                }
                .padding(AppSpacing.large)
            }
            .sheet(isPresented: $isPresentingAddExercise) {
                AddExerciseSheet { name, group in
                    let exercise = Exercise(name: name, muscleGroup: group, sortOrder: exercises.count)
                    modelContext.insert(exercise)
                }
            }
            .alert(
                infoExercise?.name ?? "",
                isPresented: Binding(get: { infoExercise != nil }, set: { if !$0 { infoExercise = nil } }),
                presenting: infoExercise
            ) { _ in
                Button("OK") { infoExercise = nil }
            } message: { exercise in
                Text("部位: \(exercise.muscleGroup.displayName)")
            }
        }
        .task { await viewModel.onAppear() }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundStyle(AppColor.secondaryText)
            TextField("メニューを検索", text: $searchText)
        }
        .padding(AppSpacing.small)
        .background(AppColor.cardBackground, in: RoundedRectangle(cornerRadius: 12))
        .padding(AppSpacing.medium)
    }

    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.large) {
                ForEach(MenuViewModel.tabs, id: \.self) { tab in
                    Button {
                        selectedTab = (selectedTab == tab) ? nil : tab
                    } label: {
                        VStack(spacing: 4) {
                            Text(tab.title)
                                .font(.subheadline)
                                .fontWeight(selectedTab == tab ? .bold : .regular)
                                .foregroundStyle(selectedTab == tab ? .primary : AppColor.secondaryText)
                            Rectangle()
                                .fill(selectedTab == tab ? AppColor.brand : .clear)
                                .frame(height: 2)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppSpacing.medium)
        }
    }

    private var filterBar: some View {
        HStack(spacing: AppSpacing.small) {
            Menu {
                ForEach(MenuSort.allCases) { option in
                    Button(option.title) { sort = option }
                }
            } label: {
                HStack(spacing: 4) {
                    Text("並び替え")
                    Image(systemName: "chevron.down")
                }
            }
            .buttonStyle(.bordered)
            .clipShape(Capsule())

            Spacer()
        }
        .font(.footnote)
        .padding(.horizontal, AppSpacing.medium)
        .padding(.vertical, AppSpacing.small)
    }

    private var exerciseList: some View {
        let items = viewModel.filteredExercises(exercises, tab: selectedTab, searchText: searchText, sort: sort)
        return ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(items) { exercise in
                    exerciseRow(exercise)
                    Divider().padding(.leading, 72)
                }
                if items.isEmpty {
                    Text("種目がありません")
                        .foregroundStyle(AppColor.secondaryText)
                        .padding(.top, AppSpacing.large)
                }
            }
            .background(AppColor.cardBackground)
        }
    }

    private func exerciseRow(_ exercise: Exercise) -> some View {
        HStack(spacing: AppSpacing.medium) {
            Circle()
                .fill(exercise.muscleGroup.color.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .foregroundStyle(exercise.muscleGroup.color)
                }

            Text(exercise.name)

            Spacer()

            Button {
                exercise.isFavorite.toggle()
            } label: {
                Image(systemName: exercise.isFavorite ? "star.fill" : "star")
                    .foregroundStyle(exercise.isFavorite ? .yellow : AppColor.secondaryText)
            }
            .buttonStyle(.plain)

            Button {
                infoExercise = exercise
            } label: {
                Image(systemName: "info.circle")
                    .foregroundStyle(AppColor.secondaryText)
            }
            .buttonStyle(.plain)
        }
        .padding(AppSpacing.medium)
    }
}

#Preview {
    MenuView()
        .modelContainer(PersistenceController.makeContainer(inMemory: true))
}
