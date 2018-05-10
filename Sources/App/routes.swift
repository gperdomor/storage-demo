import Routing
import LocalStorage
import MinioStorage
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    // Example of configuring a controller
    try  router.register(collection: StorageController(path: "local", adadperIdentifier: .local))
    try  router.register(collection: StorageController(path: "minio", adadperIdentifier: .minio))
}
