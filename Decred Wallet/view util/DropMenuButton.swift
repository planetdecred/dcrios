//
//  DropMenuButton.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import UIKit

typealias CallBack = ((Int,String) -> Void) // callback function

class DropMenuButton: UIButton, UITableViewDelegate, UITableViewDataSource
{
    var items = [String]()
    var table = UITableView()
    var act : CallBack?
    
    var superSuperView = UIView()
    var containerView = UIView()
    
    @objc func showItems()
    {
        
        fixLayout()
        
        if(containerView.alpha == 0)
        {
            self.layer.zPosition = 1
            self.containerView.alpha = 1;
        } else {
            
            self.containerView.alpha = 0;
            self.layer.zPosition = 0
        }
        
    }
    
    
    func initMenu(_ items: [String], actions: CallBack?)
    {
        self.items = items
        self.act = actions
 
        var resp = self as UIResponder
        
        while !(resp.isKind(of: UIViewController.self) || (resp.isKind(of: UITableViewCell.self))) && resp.next != nil
        {
            resp = resp.next!
            
        }
        self.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        if let vc = resp as? UIViewController{
            superSuperView = vc.view
        }
        else if let vc = resp as? UITableViewCell{
            superSuperView = vc
        }
        
        table = UITableView()
       
        table.rowHeight = self.frame.height
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

        self.addTarget(self, action:#selector(DropMenuButton.showItems), for: .touchUpInside)
        
    }
    
    func initMenu(_ items: [String])
    {
        self.items = items
        
        var resp = self as UIResponder
        
        while !(resp.isKind(of: UIViewController.self) || (resp.isKind(of: UITableViewCell.self))) && resp.next != nil
        {
            resp = resp.next!
            
        }
        
        if let vc = resp as? UIViewController{
            
            superSuperView = vc.view
        }
        else if let vc = resp as? UITableViewCell{
            
            superSuperView = vc
            
        }
        
        table = UITableView()
        table.rowHeight = self.frame.height
        table.delegate = self
        table.dataSource = self
        table.isUserInteractionEnabled = true
        containerView.alpha = 0
        table.separatorColor = UIColor.clear
        containerView.addSubview(table)
        superSuperView.addSubview(containerView)
        
        containerView.layer.borderWidth = 1.0
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.backgroundColor = UIColor.red
        containerView.clipsToBounds = false
        containerView.layer.shadowOffset = CGSize(width: -5, height: 5)
        containerView.layer.shadowRadius = 1
        containerView.layer.shadowOpacity = 0.5
        containerView.layer.shadowColor = UIColor.lightGray.cgColor
        
        self.addTarget(self, action:#selector(DropMenuButton.showItems), for: .touchUpInside)
        
    }
    
    
    func fixLayout()
    {
        
        let auxPoint2 = superSuperView.convert(self.frame.origin, from: self.superview)
        
        var tableFrameHeight = CGFloat()
        
        tableFrameHeight = self.frame.height * CGFloat(items.count)

        containerView.frame  = CGRect(x: auxPoint2.x, y: auxPoint2.y, width: self.frame.width, height:tableFrameHeight)
        table.frame = CGRect(x: 0, y: 0, width: self.frame.width, height:tableFrameHeight)
        table.rowHeight = self.frame.height
        table.separatorColor = UIColor.clear
        
       

        table.reloadData()
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setNeedsDisplay()
        fixLayout()
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        self.setTitle(items[(indexPath as NSIndexPath).row], for: UIControlState())
        self.setTitle(items[(indexPath as NSIndexPath).row], for: UIControlState.highlighted)
        self.setTitle(items[(indexPath as NSIndexPath).row], for: UIControlState.selected)
        
        act?(indexPath.row,self.items[indexPath.row])
     
        let temp = self.items.remove(at: indexPath.row)
        self.items.insert(temp, at: 0)
        
        showItems()
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let itemLabel = UILabel(frame: CGRect(x: 10, y: 0, width: self.frame.width-10, height: self.frame.height))
        itemLabel.textAlignment = NSTextAlignment.left
        itemLabel.text = items[(indexPath as NSIndexPath).row]
        itemLabel.font = UIFont (name: "Helvetica Neue", size: 10)
        itemLabel.textColor = UIColor.darkGray
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.lightGray
        
        let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        cell.backgroundColor = UIColor.white
        cell.selectedBackgroundView = bgColorView
        cell.separatorInset = UIEdgeInsetsMake(0, self.frame.width, 0, self.frame.width)
    
        cell.addSubview(itemLabel)
        
        
        return cell
    }
    
}
