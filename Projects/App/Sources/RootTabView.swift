import SwiftUI
import DesignSystem
import HomeFeature
import CalendarFeature
import WorkoutFeature
import MenuFeature
import SettingsFeature

struct RootTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("ホーム", systemImage: "house.fill") }

            CalendarView()
                .tabItem { Label("カレンダー", systemImage: "calendar") }

            WorkoutView()
                .tabItem { Label("ワークアウト", systemImage: "figure.strengthtraining.traditional") }

            MenuView()
                .tabItem { Label("メニュー", systemImage: "list.bullet.rectangle") }

            SettingsView()
                .tabItem { Label("設定", systemImage: "gearshape.fill") }
        }
        .tint(AppColor.brand)
    }
}

#Preview {
    RootTabView()
}
