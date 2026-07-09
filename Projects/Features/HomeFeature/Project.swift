import ProjectDescription
import ProjectDescriptionHelpers

let project = ProjectHelper.module(
    name: "HomeFeature",
    dependencies: [
        .project(target: "CoreKit", path: "../../Core/CoreKit"),
        .project(target: "DesignSystem", path: "../../Core/DesignSystem"),
    ]
)
