//
//  CoreDataProvider.swift
//
//  Copyright © 2016 Favio Mobile. All rights reserved.
//

import UIKit
import Groot
import CoreData

func setDateTransformer(withName name: String, dateFormat: String) {
    let formatter = DateFormatter()
    ValueTransformer.grt_setValueTransformer(withName: name, transform: { value -> Any? in
        formatter.dateFormat = dateFormat
        let date = formatter.date(from: value as! String) as NSDate?
        return date
    })
}

public protocol ItemsConsumer: NSObjectProtocol {
    func reloadItems()
    func reloadItemsAnimated()
}

public class ItemsProvider: NSObject {
    
    public weak var masterObject: NSObject?
    
    public var filterString: String?
    public var filterFormat: String?
    public weak var itemsConsumer: ItemsConsumer?
    
    public var sectionsCount: Int {
        return 0
    }
    public func itemsCountInSection(_ section: Int) -> Int {
        return 0
    }
    public func totalCount() -> Int {
        return 0
    }
    public var allItems: [NSObject] {
        return []
    }
    public func item(at indexPath: IndexPath) -> NSObject? {
        return nil
    }
    public func items(at indexPaths: [IndexPath]) -> [NSObject] {
        var result = [NSObject]()
        for indexPath in indexPaths {
            result.append(item(at: indexPath)!)
        }
        return result
    }
    public func first() -> Any? {
        return nil
    }
    public func last() -> Any? {
        return nil
    }
    public func fetch() {
        //
    }
}

public class CoreDataProvider: ItemsProvider, NSFetchedResultsControllerDelegate {
    
    @IBOutlet public var coreDataManager: CoreDataManager!

    public var dbName: String?
    public var entityName: String?
    public var sortByFields: String?
    public var sortDescending = false
    public var groupByField: String?
    public var cacheName: String?
    public var predicateFormat: String?

    var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    public var managedObjectContext: NSManagedObjectContext {
        return coreDataManager.managedObjectContext!
    }
    
    public override var sectionsCount: Int {
        if _fetchedResultsController == nil {
            fetch()
        }
        return _fetchedResultsController.sections!.count
    }
    
    public override func itemsCountInSection(_ section: Int) -> Int {
        return _fetchedResultsController.sections![section].numberOfObjects
    }
    
    public override var allItems: [NSObject] {
        return _fetchedResultsController.fetchedObjects!.map({ $0 as! NSObject })
    }
    
    public override func item(at indexPath: IndexPath) -> NSObject? {
        return _fetchedResultsController.object(at: indexPath) as? NSObject
    }
    
    public override func totalCount() -> Int {
        guard _fetchedResultsController.sections != nil else { return 0 }
        var count = 0
        for section: NSFetchedResultsSectionInfo in _fetchedResultsController.sections! {
            count += section.numberOfObjects
        }
        return count
    }

    public override func first() -> Any? {
        guard _fetchedResultsController.sections != nil else { return nil }
        let firstSection = _fetchedResultsController.sections!.first!
        let numberOfObjects = firstSection.numberOfObjects
        return numberOfObjects > 0 ? _fetchedResultsController.object(at: IndexPath(row: 0, section: 0)) : nil
    }
    
    public override func last() -> Any? {
        guard _fetchedResultsController.sections != nil else { return nil }
        let lastSection = _fetchedResultsController.sections!.last!
        let numberOfObjects = lastSection.numberOfObjects
        return numberOfObjects > 0 ? _fetchedResultsController.object(at: IndexPath(row: numberOfObjects - 1, section: _fetchedResultsController.sections!.count - 1)) : nil
    }
    
    public func reset() {
        _fetchedResultsController = nil
    }
    
    func predicateFromPredicateFormat() -> NSPredicate? {
        return self.predicateFormat != nil ? NSPredicate(format: predicateFormat!) : nil
    }
    
    func predicate() -> NSPredicate? {
        var predicates = [NSPredicate]()
        let mainPredicate = self.predicateFromPredicateFormat()
        if mainPredicate != nil {
            predicates.append(mainPredicate!)
        }
        if self.filterFormat != nil && self.filterString != nil && self.filterString!.characters.count > 0 {
            let filterPredicate = NSPredicate(format: self.filterFormat!.replacingOccurrences(of: "%@", with: self.filterString!))
            predicates.append(filterPredicate)
        }
        return NSCompoundPredicate.init(andPredicateWithSubpredicates: predicates)
    }
    
    public override func fetch() {
        var sortDescriptors = [NSSortDescriptor]()
        if self.sortByFields != nil {
            var sortDescriptorsStrings = self.sortByFields!.components(separatedBy: ",")
            if self.groupByField != nil && self.groupByField!.characters.count > 0 {
                sortDescriptorsStrings.insert(self.groupByField!, at: 0)
            }
            for fieldName: String in sortDescriptorsStrings {
                sortDescriptors.append(NSSortDescriptor(key: fieldName.trimmingCharacters(in: CharacterSet.whitespaces), ascending: !self.sortDescending))
            }
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: self.entityName!, in: self.managedObjectContext)!
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = self.predicate()
        _fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: self.groupByField, cacheName: self.cacheName)
        _fetchedResultsController.delegate = self
        do {
            try _fetchedResultsController.performFetch()
        }
        catch let error {
            print(error)
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.itemsConsumer?.reloadItems()
    }
}
