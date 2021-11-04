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

protocol DropMenuButtonDelegate {
    func onOpenDrop()
}

enum DropDownAlign {
    case left
    case right
}

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
    var delegate: DropMenuButtonDelegate?
    
    var table = UITableView()
    var act: CallBack?
    var listener: TapListener?
    private var widthCell: CGFloat = 300
    private var widthSuperView: CGFloat = 300
    private var heightSuperView: CGFloat = 300
    private var marginHorizontal: CGFloat = 0
    private var isDissmissOutside: Bool = false
    private var alignment: DropDownAlign = .left
    private var widthText: CGFloat = 0
    private var labelBGColor: UIColor = UIColor.appColors.primary
    private var labelColor: UIColor = UIColor.white
    private var separateColor: UIColor = UIColor.appColors.surfaceRipple
    private var isShowCurrentValue: Bool = false
    
    var superSuperView = UIView()
    var containerView = UIView()
    var viewGesture = UIView()
    var minTableWidth: CGFloat = 100 {
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
        if !self.isShowCurrentValue {
            self.alpha = 0
        }
        layer.zPosition = 1
        containerView.alpha = 1
        self.delegate?.onOpenDrop()
    }
    
    func hideDropDown() {
        if !self.isShowCurrentValue {
            self.alpha = 1
        }
        containerView.alpha = 0
        layer.zPosition = 0
    }
    
    func initMenu(_ items: [String], actions: CallBack? = nil) {
        let _items = items.map{DropMenuButtonItem($0)}
        self.initMenu(_items, align: .left, marginHorizontal: 0, isDissmissOutside: false , superView: nil, isShowCurrentValue: false, actions: actions)
    }
    
    func initMenu(_ items: [DropMenuButtonItem], align: DropDownAlign = .left, marginHorizontal: CGFloat, isDissmissOutside: Bool, superView: UIView?, isShowCurrentValue: Bool, actions: CallBack? = nil)
    {
        self.isShowCurrentValue = isShowCurrentValue
        self.marginHorizontal = marginHorizontal
        self.isDissmissOutside = isDissmissOutside
        self.items = items
        self.alignment = align
        act = actions
        self.caculateWidthCell()

        if containerView.superview != superSuperView {
            var resp = self as UIResponder
            
            while !(resp.isKind(of: UIViewController.self) || (resp.isKind(of: UITableViewCell.self))) && resp.next != nil
            {
                resp = resp.next!
            }

            if let vc = resp as? UIViewController
            {
                self.superSuperView = vc.view
            }
            else if let vc = resp as? UITableViewCell
            {
                self.superSuperView = vc
            }
            if let supView = superView {
                self.superSuperView = supView
            }

            table = UITableView()

            table.rowHeight = frame.height
            table.delegate = self
            table.dataSource = self
            table.isUserInteractionEnabled = true
            table.bounces = false
            table.layer.cornerRadius = 5
            table.clipsToBounds = true
            containerView.alpha = 0
            table.separatorColor = UIColor.clear

            containerView.addSubview(table)
            superSuperView.addSubview(containerView)

            containerView.clipsToBounds = false
            containerView.layer.cornerRadius = 5
            containerView.layer.shadowOffset = CGSize(width: -2, height: 5)
            containerView.layer.shadowRadius = 6
            containerView.layer.shadowOpacity = 0.8
            containerView.layer.shadowColor = UIColor.appColors.shadowColor2.cgColor

            addTarget(self, action: #selector(DropMenuButton.showItems), for: .touchUpInside)
            containerView.addSubview(self.viewGesture)
            let containerGes = UITapGestureRecognizer(target: self, action: #selector(DropMenuButton.showItems))
            self.viewGesture.addGestureRecognizer(containerGes)
            self.containerView.bringSubviewToFront(table)
            
        }
        self.widthSuperView = self.superSuperView.frame.width
        self.heightSuperView = self.superSuperView.frame.height
        
        // set automatically the selected item index to 0
        self.selectedItemIndex = 0
        self.selectedItem = self.items[self.selectedItemIndex].text
        self.setTitle(self.selectedItem!, for: .normal)
        self.setTitle(self.selectedItem!, for: .selected)
        self.setTitle(self.selectedItem!, for: .highlighted)

        table.reloadData()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        containerView.layer.shadowColor = UIColor.appColors.shadowColor2.cgColor
        self.setNeedsDisplay()
    }
    
    func caculateWidthCell() {
        self.items.forEach { (item) in
            let widthText = item.text.width(withConstrainedHeight: 20, font: UIFont(name: "SourceSansPro-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17))
            let widthtextLabel = item.textLabel.width(withConstrainedHeight: 20, font: UIFont(name: "SourceSansPro-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)) + 10
            if (widthText > self.widthText) {
                self.widthText = widthText
            }
            if ((self.widthText + widthtextLabel + 30) > self.minTableWidth) {
                self.minTableWidth = max(self.minTableWidth, (self.widthText + widthtextLabel + 30))
                self.widthCell = (widthText + widthtextLabel + 30)
            }
        }
    }
    
    func fixLayout()
    {
        let auxPoint2 = superSuperView.convert(frame.origin, from: superview)
        
        let tableFrameHeight = 40 * CGFloat(items.count)
        let containerWith = self.isDissmissOutside ? self.widthSuperView : max(minTableWidth, frame.width)
        let containerHeight = self.isDissmissOutside ? self.heightSuperView : max(tableFrameHeight, frame.height)
        self.viewGesture.frame = CGRect(x: 0, y: 0, width: containerWith, height: containerHeight)
        containerView.frame = CGRect(x: self.isDissmissOutside ? 0 : auxPoint2.x, y: self.isDissmissOutside ? 0 : auxPoint2.y, width: containerWith, height: containerHeight)
        var tableFrameX = CGFloat(auxPoint2.x + self.marginHorizontal)
        if (self.alignment == .right) {
            tableFrameX = containerWith - max(minTableWidth, frame.width) - self.marginHorizontal
        }
        table.frame = CGRect(x: tableFrameX, y: self.isDissmissOutside ? (auxPoint2.y + 30): 0, width: max(minTableWidth, frame.width), height: tableFrameHeight)
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
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
        itemLabel.textColor = UIColor.appColors.text1
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
        bgColorView.backgroundColor = UIColor.appColors.text5
        
        cell.backgroundColor = UIColor.appColors.surface
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
