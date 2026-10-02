import Foundation
import ProjectDescription

public enum ProjectHelper {
    public static let organizationName = "Workout"
    public static let bundleIdPrefix = "com.kitahara.workout"
    public static let deploymentTargets: DeploymentTargets = .iOS("17.0")
    public static let destinations: Destinations = .iOS

    /// Reads DEVELOPMENT_TEAM from the gitignored Projects/App/Signing.xcconfig (not committed).
    /// Returning a concrete value here (instead of attaching the xcconfig as a baseConfigurationReference)
    /// matters: Tuist auto-resolves its own DEVELOPMENT_TEAM and bakes it directly into buildSettings
    /// whenever it doesn't see one in the manifest, and a direct buildSettings value always wins over
    /// an xcconfig-inherited one — so only passing it through the manifest like this actually sticks.
    public static var developmentTeam: String {
        let path = FileManager.default.currentDirectoryPath + "/Projects/App/Signing.xcconfig"
        guard let contents = try? String(contentsOfFile: path, encoding: .utf8) else { return "" }
        for rawLine in contents.split(separator: "\n") {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            guard line.hasPrefix("DEVELOPMENT_TEAM") else { continue }
            let parts = line.split(separator: "=", maxSplits: 1)
            if parts.count == 2 {
                return parts[1].trimmingCharacters(in: .whitespaces)
            }
        }
        return ""
    }

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
