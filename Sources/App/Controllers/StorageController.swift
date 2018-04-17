import Foundation
import Vapor
import LocalStorage

final class StorageController: RouteCollection {
    func boot(router: Router) throws {
        router.group("buckets") { buckets in
            buckets.get("", use: self.list)
            buckets.post(BucketRequest.self, at: "", use: self.create)
            buckets.delete(String.parameter, use: self.delete)
            buckets.get(String.parameter, use: self.info)
        }
    }

    func create(_ req: Request, body: BucketRequest) throws -> Future<HTTPStatus> {
        let name = body.name

        return req.withStorage(to: .local) { storage in
            return try storage.create(bucket: name, on: req).transform(to: HTTPStatus.ok)
        }
    }

    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let name: String = try req.parameters.next()

        return req.withStorage(to: .local) { storage in
            return try storage.delete(bucket: name, on: req).transform(to: HTTPStatus.ok)
        }
    }

    func info(_ req: Request) throws -> Future<BucketInfo> {
        let name: String = try req.parameters.next()

        return req.withStorage(to: .local) { storage in
            return try storage.get(bucket: name, on: req).map(to: BucketInfo.self) { bucket in
                guard let b = bucket else {
                    throw Abort(.notFound)
                }

                return b
            }
        }
    }

    func list(_ req: Request) throws -> Future<[BucketInfo]> {
        return req.withStorage(to: .local) { storage in
            return try storage.list(on: req).map(to: [BucketInfo].self) { buckets in
                return buckets
            }
        }
    }
}

struct BucketRequest: Content {
    let name: String
}
