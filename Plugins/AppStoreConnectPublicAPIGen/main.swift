import AppStoreConnectPublicAPIGenCore

let arguments = Array(CommandLine.arguments.dropFirst())
let output: String?

if arguments.first == "generate-openapi-swift" {
    output = try OpenAPISwiftGenerationCommand().run(arguments: Array(arguments.dropFirst()))
} else {
    output = try GeneratorCommand().run(arguments: arguments)
}

if let output {
    print(output)
}
