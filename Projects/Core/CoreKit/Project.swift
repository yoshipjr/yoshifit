import ProjectDescription
import ProjectDescriptionHelpers

let project = ProjectHelper.module(
    name: "CoreKit",
    dependencies: [.sdk(name: "HealthKit", type: .framework)]
)
