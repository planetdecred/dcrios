//
//  DropMenuButton.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

typealias CallBack = ((Int, String) -> Void) // callback function
typealias TapListener = ()->()

struct DropMenuButtonItem {
    var text: String
    var isSeparate: Bool = false
    var textLabel: String = ""
    
    init(_ text: String, isSeparate: Bool = false, textLabel: String = "") {
        self.text = text
        self.isSeparate = isSeparate
        self.textLabel = textLabel
    }
    
    init(_ text: String) {
        self.text = text
    }
}

class DropMenuButton: UIButton, UITableViewDelegate, UITableViewDataSource
{
    var items = [DropMenuButtonItem]()
    var selectedItemIndex: Int = -1
    var selectedItem: String?
    
    var table = UITableView()
    var act: CallBack?
    var listener: TapListener?
    private var widthCell: CGFloat = 300
    private var widthText: CGFloat = 0
    private var labelBGColor: UIColor = UIColor.appColors.lightBlue
    private var labelColor: UIColor = UIColor.white
    private var separateColor: UIColor = UIColor.appColors.gray
    
    var superSuperView = UIView()
    var containerView = UIView()
    var minTableWidth: CGFloat = 0 {
        didSet {
            self.layoutIfNeeded()
        }
    }
    
    var isDropDownOpen: Bool {
        return self.containerView.alpha == 1
    }
    
    @objc func showItems()
    {
        listener?()
        fixLayout()
        
        if self.isDropDownOpen {
            self.hideDropDown()
        } else {
            self.showDropDown()
        }
    }
    
    func showDropDown() {
        self.alpha = 0
        layer.zPosition = 1
        containerView.alpha = 1
    }
    
    func hideDropDown() {
        self.alpha = 1
        containerView.alpha = 0
        layer.zPosition = 0
    }
    
    func initMenu(_ items: [String], actions: CallBack? = nil) {
        let _items = items.map{DropMenuButtonItem($0)}
        self.initMenu(_items, actions: actions)
    }
    
    func initMenu(_ items: [DropMenuButtonItem], actions: CallBack? = nil)
    {
        self.items = items
        act = actions
        self.caculateWidthCell()

        if containerView.superview != superSuperView {
            var resp = self as UIResponder
            
            while !(resp.isKind(of: UIViewController.self) || (resp.isKind(of: UITableViewCell.self))) && resp.next != nil
            {
                resp = resp.next!
            }
            // backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)

            if let vc = resp as? UIViewController
            {
                superSuperView = vc.view
            }
            else if let vc = resp as? UITableViewCell
            {
                superSuperView = vc
            }

            table = UITableView()

            table.rowHeight = frame.height
            table.delegate = self
            table.dataSource = self
            table.isUserInteractionEnabled = true
            table.bounces = false
            containerView.alpha = 0
            table.separatorColor = UIColor.clear

            containerView.addSubview(table)
            superSuperView.addSubview(containerView)

            containerView.clipsToBounds = false
            containerView.layer.shadowOffset = CGSize(width: -2, height: 5)
            containerView.layer.shadowRadius = 6
            containerView.layer.shadowOpacity = 0.8
            containerView.layer.shadowColor = UIColor.lightGray.cgColor

            addTarget(self, action: #selector(DropMenuButton.showItems), for: .touchUpInside)
        }

        // set automatically the selected item index to 0
        self.selectedItemIndex = 0
        self.selectedItem = self.items[self.selectedItemIndex].text
        self.setTitle(self.selectedItem!, for: .normal)
        self.setTitle(self.selectedItem!, for: .selected)
        self.setTitle(self.selectedItem!, for: .highlighted)

        table.reloadData()
    }
    
    func caculateWidthCell() {
        self.items.forEach { (item) in
            let widthText = item.text.width(withConstrainedHeight: 20, font: UIFont(name: "SourceSansPro-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17))
            let widthtextLabel = item.textLabel.width(withConstrainedHeight: 20, font: UIFont(name: "SourceSansPro-Bold", size: 13) ?? UIFont.systemFont(ofSize: 13)) + 10
            if ((widthText + widthtextLabel + 30) > self.minTableWidth) {
                self.minTableWidth = max(self.minTableWidth, (widthText + widthtextLabel + 30))
                self.widthCell = (widthText + widthtextLabel + 30)
            }
            if (widthText > self.widthText) {
                self.widthText = widthText
            }
        }
    }
    
    func fixLayout()
    {
        let auxPoint2 = superSuperView.convert(frame.origin, from: superview)
        
        var tableFrameHeight = CGFloat()
        
        tableFrameHeight = frame.height * CGFloat(items.count)
        containerView.frame = CGRect(x: auxPoint2.x, y: auxPoint2.y, width: 300, height: tableFrameHeight)
        table.frame = CGRect(x: 0, y: 0, width: max(minTableWidth, frame.width), height: tableFrameHeight)
        table.rowHeight = frame.height
        table.separatorColor = UIColor.clear
        
        table.reloadData()
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        setNeedsDisplay()
        fixLayout()
    }
    
    func setSelectedItemIndex(_ index: Int) {
        if index >= 0 && index < self.items.count {
            self.selectedItemIndex = index
            self.selectedItem = self.items[self.selectedItemIndex].text
            self.setTitle(self.selectedItem!, for: .normal)
        } else {
            self.selectedItemIndex = -1
            self.selectedItem = nil
            self.setTitle("", for: .normal)
        }

        act?(self.selectedItemIndex, self.selectedItem ?? "")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        setTitle(items[(indexPath as NSIndexPath).row].text, for: UIControl.State())
        setTitle(items[(indexPath as NSIndexPath).row].text, for: UIControl.State.highlighted)
        setTitle(items[(indexPath as NSIndexPath).row].text, for: UIControl.State.selected)
        
        self.setSelectedItemIndex(indexPath.row)
        self.showItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: self.widthCell, height: frame.height))
        
        let separateView = UIView()
        cell.addSubview(separateView)
        separateView.backgroundColor = self.separateColor
        separateView.translatesAutoresizingMaskIntoConstraints = false
        
        let itemLabel = UILabel()
        itemLabel.textAlignment = NSTextAlignment.left
        itemLabel.text = items[(indexPath as NSIndexPath).row].text
        itemLabel.font = UIFont(name: "SourceSansPro-Regular", size: 17)
        itemLabel.textColor = UIColor.black
        cell.addSubview(itemLabel)
        
        itemLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.textAlignment = NSTextAlignment.center
        label.text = items[(indexPath as NSIndexPath).row].textLabel
        label.font = UIFont(name: "SourceSansPro-Bold", size: 13)
        label.textColor = self.labelColor
        label.backgroundColor = self.labelBGColor
        cell.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false

        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.lightGray
        
        cell.backgroundColor = UIColor.white
        cell.selectedBackgroundView = bgColorView
        cell.separatorInset = UIEdgeInsets(top: 0, left: frame.width, bottom: 0, right: frame.width)
        
        let labelTextWidth = items[(indexPath as NSIndexPath).row].textLabel.width(withConstrainedHeight: 20, font: UIFont(name: "SourceSansPro-Bold", size: 13) ?? UIFont.systemFont(ofSize: 13)) + 10
        
        let isShowSeparateView = items[(indexPath as NSIndexPath).row].isSeparate
        
        let constraints = [
            separateView.heightAnchor.constraint(equalToConstant: isShowSeparateView ? 0.5 : 0),
            separateView.leadingAnchor.constraint(equalTo: separateView.superview!.leadingAnchor),
            separateView.topAnchor.constraint(equalTo: separateView.superview!.topAnchor),
            separateView.trailingAnchor.constraint(equalTo: separateView.superview!.trailingAnchor),
            
            itemLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
            itemLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            itemLabel.widthAnchor.constraint(equalToConstant: self.widthText),
            
            label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: itemLabel.trailingAnchor, constant: 10),
            label.widthAnchor.constraint(equalToConstant: labelTextWidth)
        ]
        NSLayoutConstraint.activate(constraints)
        self.layoutIfNeeded()
        
        return cell
    }
    
    func setTapListener(tapListener: @escaping TapListener){
        self.listener = tapListener
    }
}
