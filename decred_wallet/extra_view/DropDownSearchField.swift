//
//  DropDownSearchField.swift
//  Decred Wallet
//
// Copyright (c) 2018, The Decred developers
// See LICENSE for details.
//

import UIKit

protocol DropDownResultsListProtocol : UITableViewDataSource, UITableViewDelegate {
    var items: [String]?{get set}
    var cellIdentifier: String{get set}
    var onSelect:((Int, String)->Void)? {get set}
}

protocol SearchDataSourceProtocol: class {
    var itemsToSearch:[String]?{get set}
    var dropDownListPlaceholder: UIView? {get set}
    func clean()
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
        cell.textLabel?.isUserInteractionEnabled = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let item = items?[index] ?? ""
        onSelect?(index, item)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}

class DropDownSearchField: UITextField, UITextFieldDelegate, SearchDataSourceProtocol {

    
    var dropDownListPlaceholder: UIView?
    var itemsToSearch: [String]?
    var dropDownTable: UITableView?
    var searchResult: DropDownResultsListProtocol?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        searchResult = DropDownListDataSource()
        searchResult?.cellIdentifier = "dropDownCell"
        self.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        setupDropdownTable()
    }
    
    fileprivate func setupDropdownTable() {
        dropDownTable = UITableView(frame: CGRect(x: frame.origin.x, y: frame.size.height + frame.origin.y, width: frame.size.width, height: 150), style: .plain)
        dropDownTable?.register(UITableViewCell.self, forCellReuseIdentifier: (searchResult?.cellIdentifier)!)
        dropDownTable?.dataSource = searchResult
        dropDownTable?.delegate = searchResult
        dropDownTable?.isHidden = true
        dropDownTable?.allowsSelection = true
        dropDownTable?.isUserInteractionEnabled = true
    }
    
    func clean() {
        searchResult?.items = []
        text = ""
        dropDownTable?.isHidden = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        dropDownListPlaceholder?.addSubview(dropDownTable!)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        searchResult?.items = itemsToSearch?.filter({ return ($0.hasPrefix(textField.text!) && (textField.text?.count)! > 2) })
        dropDownTable?.frame.size.height = CGFloat((searchResult?.items?.count)!) * CGFloat(44.0);
        dropDownTable?.isHidden = (searchResult?.items?.count)! == 0
        dropDownTable?.reloadData()
    }
}
