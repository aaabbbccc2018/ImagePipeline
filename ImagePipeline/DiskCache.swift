import Foundation

public protocol DataCaching {
    func store(_ data: CacheEntry, for url: URL)
    func load(for url: URL) -> CacheEntry?
    func remove(for url: URL)
    func removeAll()
}

public final class DiskCache: DataCaching {
    let storage: Storage

    public init(storage: Storage = SQLiteStorage()) {
        self.storage = storage
    }

    public func store(_ entry: CacheEntry, for url: URL) {
        storage.store(entry, for: url)
    }

    public func load(for url: URL) -> CacheEntry? {
        return storage.load(for: url)
    }
    
    public func remove(for url: URL) {
        storage.remove(for: url)
    }

    public func removeAll() {
        storage.removeAll()
    }
}
