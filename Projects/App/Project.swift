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
                ]
            ),
            buildableFolders: [
                "Sources",
                "Resources",
            ],
            dependencies: [
                .project(target: "CoreKit", path: "../Core/CoreKit"),
                .project(target: "DesignSystem", path: "../Core/DesignSystem"),
                .project(target: "HomeFeature", path: "../Features/HomeFeature"),
                .project(target: "CalendarFeature", path: "../Features/CalendarFeature"),
                .project(target: "WorkoutFeature", path: "../Features/WorkoutFeature"),
                .project(target: "MenuFeature", path: "../Features/MenuFeature"),
                .project(target: "SettingsFeature", path: "../Features/SettingsFeature"),
            ]
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
