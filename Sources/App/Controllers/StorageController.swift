import Foundation
import Vapor
import StorageKit

final class StorageController<T: Adapter>: RouteCollection {
    let path: String
    let adadperIdentifier: AdapterIdentifier<T>

    init(path: String, adadperIdentifier: AdapterIdentifier<T>) {
        self.path = path
        self.adadperIdentifier = adadperIdentifier
    }

    func boot(router: Router) throws {
        let buckets = router.grouped(self.path, "buckets")

        buckets.get("", use: self.listBuckets)
        buckets.post(String.parameter, use: self.createBucket)
        buckets.delete(String.parameter, use: self.deleteBucket)
        //buckets.on(.HEAD, nil, at: String.parameter, use: self.infoBucket)

        buckets.get(String.parameter, use: self.listObjects)
        buckets.post(String.parameter, String.parameter, use: self.createObject)
        buckets.delete(String.parameter, String.parameter, use: self.deleteObject)
        buckets.get(String.parameter, String.parameter, use: self.getObject)
        buckets.post(String.parameter, String.parameter, "copy", use: self.copyObject)
    }

    func createBucket(_ req: Request) throws -> Future<HTTPStatus> {
        let bucket = try req.parameters.next(String.self)

        return req.withStorage(to: adadperIdentifier) { storage in
            return try storage.create(bucket: bucket, metadata: nil, on: req).transform(to: HTTPStatus.ok)
        }
    }

    func createObject(_ req: Request) throws -> Future<ObjectInfo> {
        let bucket = try req.parameters.next(String.self)
        let object = try req.parameters.next(String.self)

        guard let data = req.http.body.data else {
            throw Abort(.badRequest, reason: "body data is missing")
        }

        return req.withStorage(to: adadperIdentifier) { storage in
            return try storage.create(object: object, in: bucket, with: data, metadata: nil, on: req)
        }
    }

    func deleteBucket(_ req: Request) throws -> Future<HTTPStatus> {
        let name: String = try req.parameters.next()

        return req.withStorage(to: adadperIdentifier) { storage in
            return try storage.delete(bucket: name, on: req).transform(to: HTTPStatus.ok)
        }
    }

    func deleteObject(_ req: Request) throws -> Future<HTTPStatus> {
        let bucket: String = try req.parameters.next()
        let object: String = try req.parameters.next()

        return req.withStorage(to: adadperIdentifier) { storage in
            return try storage.delete(object: object, in: bucket, on: req).transform(to: HTTPStatus.ok)
        }
    }

    func getObject(_ req: Request) throws -> Future<Response> {
        let bucket: String = try req.parameters.next()
        let object: String = try req.parameters.next()

        return req.withStorage(to: adadperIdentifier) { storage in
            return try storage.get(object: object, in: bucket, on: req).map(to: Response.self) { data in
                return req.makeResponse(data)
            }
        }
    }

    func copyObject(_ req: Request) throws -> Future<ObjectInfo> {
        let bucket: String = try req.parameters.next()
        let object: String = try req.parameters.next()

        guard let targetBucket = req.query[String.self, at: "bucket"] else {
            throw Abort(.badRequest, reason: "'target' query param is missing")
        }

        guard let targetObject = req.query[String.self, at: "object"] else {
            throw Abort(.badRequest, reason: "'object' query param is missing")
        }

        return req.withStorage(to: adadperIdentifier) { storage in
            return try storage.copy(object: object, from: bucket, as: targetObject, to: targetBucket, on: req)
        }
    }

    func infoBucket(_ req: Request) throws -> Future<BucketInfo> {
        let name: String = try req.parameters.next()

        return req.withStorage(to: adadperIdentifier) { storage in
            return try storage.get(bucket: name, on: req).map(to: BucketInfo.self) { bucket in
                guard let b = bucket else {
                    throw Abort(.notFound)
                }

                return b
            }
        }
    }

    func listBuckets(_ req: Request) throws -> Future<[BucketInfo]> {
        return req.withStorage(to: adadperIdentifier) { storage in
            return try storage.list(on: req).map(to: [BucketInfo].self) { buckets in
                return buckets
            }
        }
    }

    func listObjects(_ req: Request) throws -> Future<[ObjectInfo]> {
        return req.withStorage(to: adadperIdentifier) { storage in
            let bucket = try req.parameters.next(String.self)

            return try storage.listObjects(in: bucket, prefix: nil, on: req)
        }
    }
}
