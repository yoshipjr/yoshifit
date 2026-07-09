import ProjectDescription
import ProjectDescriptionHelpers

let project = ProjectHelper.module(
    name: "CalendarFeature",
    dependencies: [
        .project(target: "CoreKit", path: "../../Core/CoreKit"),
        .project(target: "DesignSystem", path: "../../Core/DesignSystem"),
        .project(target: "WorkoutFeature", path: "../WorkoutFeature"),
    ]
)
