//
//  TableViewController.swift
//
//  Copyright © 2016 Favio Mobile. All rights reserved.
//

import UIKit
import CoreData

public class TableViewController: NSObject, ItemsConsumer, UITableViewDataSource, UITableViewDelegate {
    
    var _itemsProvider: ItemsProvider?
    weak var _tableView: UITableView?
    
    static var defaultCellIdentifier = "Cell"
    
    public var infiniteScrollEnabled = false
    
    public var configureCell: ((_ cell: UITableViewCell, _ object: NSManagedObject, _ indexPath: IndexPath) -> Void)?
    public var infiniteScroll: ((_ first: Any?, _ last: Any?) -> Void)?
    
    @IBOutlet public var emptyDataView: UIView!
    
    @IBOutlet public var itemsProvider: ItemsProvider! {
        get {
            return _itemsProvider
        }
        set {
            _itemsProvider = newValue
            _itemsProvider!.itemsConsumer = self
        }
    }
    
    @IBOutlet public var tableView: UITableView? {
        get {
            return _tableView
        }
        set {
            _tableView = newValue
            _tableView!.dataSource = self
            _tableView!.estimatedRowHeight = _tableView!.rowHeight
            _tableView!.rowHeight = UITableViewAutomaticDimension
            _tableView!.backgroundView = self.emptyDataView
        }
    }
    
    // MARK: - Data Source
    
    public func reloadItems() {
        self.tableView?.reloadData()
        let count = self.itemsProvider.totalCount()
        if count == 0 {
            _tableView!.backgroundView = self.emptyDataView
        }
    }
    
    public func reloadItemsAnimated() {
        if _itemsProvider != nil && _itemsProvider!.sectionsCount > 0 {
            self.tableView?.reloadSections(IndexSet(integersIn: 0..._itemsProvider!.sectionsCount - 1), with: .automatic)
        }
        let count = self.itemsProvider.totalCount()
        if count == 0 {
            _tableView!.backgroundView = self.emptyDataView
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.itemsProvider.sectionsCount
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemsProvider.itemsCountInSection(section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = self.itemsProvider.item(at: indexPath) as! NSManagedObject
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewController.defaultCellIdentifier, for: indexPath)
        self.configureCell!(cell, object, indexPath)
        return cell
    }
    
    // MARK: - Delegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.infiniteScrollEnabled && self.infiniteScroll != nil && _itemsProvider != nil && (self.tableView!.isDragging || self.tableView!.isDecelerating) {
            let offset = self.tableView!.contentSize.height - self.tableView!.bounds.size.height
            if self.tableView!.contentOffset.y > offset {
                self.infiniteScroll!(_itemsProvider!.first(), _itemsProvider!.last())
            }
        }
    }
}

public extension UIViewController {
    
    public func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
}
