import ProjectDescription
import ProjectDescriptionHelpers

let project = ProjectHelper.module(
    name: "DesignSystem",
    dependencies: [
        .project(target: "CoreKit", path: "../CoreKit"),
    ]
)
