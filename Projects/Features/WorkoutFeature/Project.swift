import ProjectDescription
import ProjectDescriptionHelpers

let project = ProjectHelper.module(
    name: "WorkoutFeature",
    dependencies: [
        .project(target: "CoreKit", path: "../../Core/CoreKit"),
        .project(target: "DesignSystem", path: "../../Core/DesignSystem"),
    ]
)
