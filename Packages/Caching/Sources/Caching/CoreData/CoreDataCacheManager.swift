import CoreData
import Foundation

public final class CoreDataCacheManager: CacheStorageProtocol {
    private let context: NSManagedObjectContext

    public init(storeURL: URL? = nil, inMemory: Bool = false) throws {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: Self.model)
        if inMemory {
            try coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil)
        } else {
            let url = try storeURL ?? Self.defaultStoreURL()
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url)
        }

        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        self.context = context
    }

    private static let model: NSManagedObjectModel = {
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "CachedRecord"
        entity.managedObjectClassName = NSStringFromClass(CachedRecord.self)

        let key = NSAttributeDescription()
        key.name = "key"
        key.attributeType = .stringAttributeType
        key.isOptional = false

        let payload = NSAttributeDescription()
        payload.name = "payload"
        payload.attributeType = .binaryDataAttributeType
        payload.isOptional = false

        entity.properties = [key, payload]
        entity.uniquenessConstraints = [["key"]]
        model.entities = [entity]
        return model
    }()

    public func save(_ data: Data, forKey key: String) throws {
        try validate(key)
        try context.performAndWait {
            let record = try record(forKey: key) ?? CachedRecord(context: context)
            record.key = key
            record.payload = data
            try context.save()
        }
    }

    public func data(forKey key: String) throws -> Data? {
        try validate(key)
        return try context.performAndWait {
            try record(forKey: key)?.payload
        }
    }

    public func remove(forKey key: String) throws {
        try validate(key)
        try context.performAndWait {
            guard let record = try record(forKey: key) else { return }
            context.delete(record)
            try context.save()
        }
    }

    public func removeAll() throws {
        try context.performAndWait {
            let request = NSFetchRequest<CachedRecord>(entityName: "CachedRecord")
            for record in try context.fetch(request) {
                context.delete(record)
            }
            if context.hasChanges {
                try context.save()
            }
        }
    }

    private func record(forKey key: String) throws -> CachedRecord? {
        let request = NSFetchRequest<CachedRecord>(entityName: "CachedRecord")
        request.predicate = NSPredicate(format: "key == %@", key)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    private func validate(_ key: String) throws {
        guard !key.isEmpty else { throw CacheError.invalidKey }
    }

    private static func defaultStoreURL() throws -> URL {
        let directory = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return directory.appendingPathComponent("Caching.sqlite")
    }
}

@objc(CachedRecord)
private final class CachedRecord: NSManagedObject {
    @NSManaged var key: String
    @NSManaged var payload: Data
}
