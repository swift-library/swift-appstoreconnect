import Foundation

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

@main
enum AppStoreConnectCommandLineMain {
    static func main() async {
        let result = await AppStoreConnectCommand.run(
            arguments: Array(CommandLine.arguments.dropFirst())
        )

        if !result.stdout.isEmpty {
            print(result.stdout, terminator: "")
        }

        if !result.stderr.isEmpty {
            FileHandle.standardError.write(Data(result.stderr.utf8))
        }

        exit(result.exitCode)
    }
}
