import SwiftUI
import CoreKit
import DesignSystem
import HomeFeature
import CalendarFeature
import WorkoutFeature
import MenuFeature
import SettingsFeature

struct RootTabView: View {
    @Bindable private var router = AppRouter.shared

    var body: some View {
        TabView(selection: $router.selectedTab) {
            HomeView()
                .tabItem { Label("ホーム", systemImage: "house.fill") }
                .tag(RootTab.home)

            CalendarView()
                .tabItem { Label("カレンダー", systemImage: "calendar") }
                .tag(RootTab.calendar)

            WorkoutView()
                .tabItem { Label("ワークアウト", systemImage: "figure.strengthtraining.traditional") }
                .tag(RootTab.workout)

            MenuView()
                .tabItem { Label("メニュー", systemImage: "list.bullet.rectangle") }
                .tag(RootTab.menu)

            SettingsView()
                .tabItem { Label("設定", systemImage: "gearshape.fill") }
                .tag(RootTab.settings)
        }
        .tint(AppColor.brand)
    }
}

#Preview {
    RootTabView()
}
