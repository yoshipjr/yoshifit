import ProjectDescription
import ProjectDescriptionHelpers

let project = ProjectHelper.module(
    name: "SettingsFeature",
    dependencies: [
        .project(target: "CoreKit", path: "../../Core/CoreKit"),
        .project(target: "DesignSystem", path: "../../Core/DesignSystem"),
    ]
)
