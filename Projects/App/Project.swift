import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Workout",
    organizationName: ProjectHelper.organizationName,
    targets: [
        .target(
            name: "Workout",
            destinations: ProjectHelper.destinations,
            product: .app,
            bundleId: ProjectHelper.bundleIdPrefix,
            deploymentTargets: ProjectHelper.deploymentTargets,
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "YOSHIFIT",
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "NSHealthUpdateUsageDescription": "トレーニング記録(消費カロリー・時間)をヘルスケアに書き込むために使用します。",
                ]
            ),
            buildableFolders: [
                "Sources",
                "Resources",
            ],
            entitlements: .dictionary([
                "com.apple.developer.healthkit": .boolean(true),
                "com.apple.developer.healthkit.access": .array([]),
            ]),
            dependencies: [
                .project(target: "CoreKit", path: "../Core/CoreKit"),
                .project(target: "DesignSystem", path: "../Core/DesignSystem"),
                .project(target: "HomeFeature", path: "../Features/HomeFeature"),
                .project(target: "CalendarFeature", path: "../Features/CalendarFeature"),
                .project(target: "WorkoutFeature", path: "../Features/WorkoutFeature"),
                .project(target: "MenuFeature", path: "../Features/MenuFeature"),
                .project(target: "SettingsFeature", path: "../Features/SettingsFeature"),
            ],
            // DEVELOPMENT_TEAM is read from the gitignored Signing.xcconfig at generate-time
            // (see ProjectHelper.developmentTeam). Copy Signing.xcconfig.example to
            // Signing.xcconfig and fill in your team ID.
            settings: .settings(base: [
                "CODE_SIGN_STYLE": "Automatic",
                "DEVELOPMENT_TEAM": SettingValue(stringLiteral: ProjectHelper.developmentTeam),
            ])
        ),
        .target(
            name: "WorkoutTests",
            destinations: ProjectHelper.destinations,
            product: .unitTests,
            bundleId: "\(ProjectHelper.bundleIdPrefix).Tests",
            deploymentTargets: ProjectHelper.deploymentTargets,
            infoPlist: .default,
            buildableFolders: ["Tests"],
            dependencies: [.target(name: "Workout")]
        ),
    ]
)
