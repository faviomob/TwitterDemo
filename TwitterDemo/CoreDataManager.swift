//
//  CoreDataManager.swift
//
//  Copyright © 2016 Favio Mobile. All rights reserved.
//

import CoreData

public class CoreDataManager: NSObject {

    static var _allInstances = NSMutableDictionary()
    var _managedObjectContext: NSManagedObjectContext?
    
    public var managedObjectContext: NSManagedObjectContext? {
        if _managedObjectContext == nil {
            self.setup(withName: self.name, fileName: self.fileName, inMemory: self.inMemory)
        }
        return _managedObjectContext
    }

    public var name = "default"
    public var fileName = "Model"
    public var inMemory: Bool = false
    
    func createManagedContext(withName name: String, fileName: String, inMemory: Bool) -> NSManagedObjectContext {

        var moc: NSManagedObjectContext
        let modelUrl = Bundle.main.url(forResource: fileName, withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelUrl)!
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            if (inMemory) {
                try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
            }
            else {
                let storageDirUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let storageUrl = storageDirUrl.appendingPathComponent("\(name).sqlite")
                try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storageUrl, options: nil)
            }
            moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            moc.persistentStoreCoordinator = persistentStoreCoordinator
        }
        catch {
            fatalError("Couldn't create local database for fileName '\(fileName)'")
        }
        return moc
    }

    func setup(withName name: String, fileName: String, inMemory: Bool) {
        let existingManager = CoreDataManager.instanceNamed(name)
        if existingManager != nil {
            _managedObjectContext = existingManager!.managedObjectContext
        }
        else {
            _managedObjectContext = createManagedContext(withName: name, fileName: fileName, inMemory: inMemory)
            CoreDataManager._allInstances.setObject(self, forKey: name as NSCopying)
        }
    }
    
    public class func defaultInstance() -> CoreDataManager? {
        var defaultManager = _allInstances.object(forKey: "default") as? CoreDataManager
        if defaultManager == nil {
            defaultManager = CoreDataManager()
            defaultManager!.setup(withName: "default", fileName: "Model", inMemory: false)
        }
        return defaultManager
    }
    
    public class func instanceNamed(_ name: String) -> CoreDataManager? {
        return _allInstances.object(forKey: name) as? CoreDataManager
    }
}

public extension NSManagedObject {
    
    public class func objects(ofEntity named: String, with predicate: NSPredicate?, in context: NSManagedObjectContext) -> [NSManagedObject]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: named, in: context)
        fetchRequest.predicate = predicate
        let objects = try? context.fetch(fetchRequest) as! [NSManagedObject]
        return objects
    }

    public class func all(ofEntity named: String, in context: NSManagedObjectContext) -> [NSManagedObject]? {
        return self.objects(ofEntity: named, with: nil, in: context)
    }
    
    public class func clear(entity named: String, in context: NSManagedObjectContext) {
        if let allObjects = self.all(ofEntity: named, in: context) {
            for obj in allObjects {
                obj.managedObjectContext?.delete(obj)
            }
        }
    }
}
