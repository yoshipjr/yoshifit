import ProjectDescription

public enum ProjectHelper {
    public static let organizationName = "Workout"
    public static let bundleIdPrefix = "com.kitahara.workout"
    public static let deploymentTargets: DeploymentTargets = .iOS("17.0")
    public static let destinations: Destinations = .iOS

    /// A local Swift module (feature or core layer) with its own unit test target.
    public static func module(
        name: String,
        dependencies: [TargetDependency] = []
    ) -> Project {
        Project(
            name: name,
            organizationName: organizationName,
            targets: [
                .target(
                    name: name,
                    destinations: destinations,
                    product: .staticFramework,
                    bundleId: "\(bundleIdPrefix).\(name)",
                    deploymentTargets: deploymentTargets,
                    infoPlist: .default,
                    buildableFolders: ["Sources"],
                    dependencies: dependencies
                ),
                .target(
                    name: "\(name)Tests",
                    destinations: destinations,
                    product: .unitTests,
                    bundleId: "\(bundleIdPrefix).\(name)Tests",
                    deploymentTargets: deploymentTargets,
                    infoPlist: .default,
                    buildableFolders: ["Tests"],
                    dependencies: [.target(name: name)]
                ),
            ]
        )
    }
}
