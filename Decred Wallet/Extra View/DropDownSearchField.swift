//
//  DropDownSearchField.swift
//  Decred Wallet
//
//  Created by Philipp Maluta on 25.04.18.
//  Copyright © 2018 Macsleven. All rights reserved.
//

import UIKit

protocol DropDownResultsListProtocol : UITableViewDataSource, UITableViewDelegate {
    var items: [String]?{get set}
    var cellIdentifier: String{get set}
    var onSelect:((Int, String)->Void)? {get set}
}

protocol SearchDataSourceProtocol {
    var itemsToSearch:[String]?{get set}
}

class DropDownListDataSource: NSObject,  DropDownResultsListProtocol {
    var onSelect: ((Int, String) -> Void)?
    var items: [String]?
    var cellIdentifier: String = ""
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = items?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let item = items?[index] ?? ""
        onSelect?(index, item)
    }
}

class DropDownSearchField: UITextField, UITextFieldDelegate, SearchDataSourceProtocol {
    var itemsToSearch: [String]?
    var dropDownTable: UITableView?
    var searchResult: DropDownResultsListProtocol?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        searchResult = DropDownListDataSource()
        setupDropdownTable()
    }
    
    fileprivate func setupDropdownTable() {
        dropDownTable = UITableView(frame: CGRect(x: 0, y: frame.size.height, width: frame.size.width, height: 50))
        dropDownTable?.delegate = searchResult
        dropDownTable?.dataSource = searchResult
        dropDownTable?.isHidden = true
        self.addSubview(dropDownTable!)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        searchResult?.items = itemsToSearch?.filter({ return $0.hasPrefix(textField.text!) })
        dropDownTable?.isHidden = (searchResult?.items?.count)! == 0
        dropDownTable?.reloadData()
    }
    
}
