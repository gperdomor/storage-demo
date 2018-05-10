import LocalStorage
import MinioStorage
import SwiftyBeaverProvider
import Vapor

/// Called before your application initializes.
///
/// https://docs.vapor.codes/3.0/getting-started/structure/#configureswift
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    /// Register providers first
    try services.register(SwiftyBeaverProvider())

    try services.register(LocalStorageProvider())
    try services.register(MinioStorageProvider())

    config.prefer(SwiftyBeaverLogger.self, for: Logger.self)

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    let rootDirectory = DirectoryConfig.detect().workDir

    var adapters = AdapterConfig()
    adapters.add(adapter: try LocalAdapter(rootDirectory: URL(fileURLWithPath: "\(rootDirectory)Public/buckets"), create: true), as: .local)
    adapters.add(adapter: try MinioAdapter(host: "http://localhost:9000", accessKey: "", secretKey: "", region: .usEast1, securityToken: nil), as: .minio)
    services.register(adapters)
}
