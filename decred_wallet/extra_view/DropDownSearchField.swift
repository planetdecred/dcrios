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
    private var dropDownTable: UITableView?
    var searchResult: DropDownResultsListProtocol?
    var vertPosition: CGFloat = 0.0
    
    var onSelect:((Int, String)->Void)?{
        get{
            return searchResult?.onSelect
        }
        set{
            searchResult?.onSelect = newValue
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        searchResult = DropDownListDataSource()
        searchResult?.cellIdentifier = "dropDownCell"
        searchResult?.onSelect = self.onSelect
        self.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        setupDropdownTable()
    }
    
    func setupDropdownTable() {
        dropDownTable = UITableView(frame: CGRect(x: 0, y: 0, width: (dropDownListPlaceholder?.frame.size.width) ?? 0, height: 40 * 5), style: .plain)
        dropDownTable?.register(UITableViewCell.self, forCellReuseIdentifier: (searchResult?.cellIdentifier)!)
        dropDownTable?.dataSource = searchResult
        dropDownTable?.delegate = searchResult
        dropDownTable?.isHidden = true
        dropDownTable?.allowsSelection = true
        dropDownTable?.isUserInteractionEnabled = true
        dropDownTable?.backgroundColor = #colorLiteral(red: 0.8104764819, green: 0.8344743252, blue: 0.8571521044, alpha: 1)
        dropDownTable?.separatorStyle = .none
        dropDownListPlaceholder?.addSubview(dropDownTable!)
    }
    
    func clean() {
        dropDownListPlaceholder?.isHidden = false
        searchResult?.items = []
        text = ""
        dropDownTable?.isHidden = true
    }
    
    func updatePlaceholder(position:Int){
        vertPosition = CGFloat(position)
        dropDownListPlaceholder?.frame = CGRect(x: 100, y: position, width: 200, height: 40 * 5)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        dropDownListPlaceholder?.isHidden = false
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        searchResult?.items = itemsToSearch?.filter({ return ($0.lowercased().hasPrefix(textField.text!.lowercased()) && (textField.text?.count)! > 2) })
        dropDownTable?.frame.size.height = CGFloat((searchResult?.items?.count)!) * CGFloat(30.0);
        dropDownTable?.isHidden = (searchResult?.items?.count)! == 0
        dropDownTable?.reloadData()
    }
}
