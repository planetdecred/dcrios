//
//  DropMenuButton.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import UIKit

class DropMenuButton: UIButton, UITableViewDelegate, UITableViewDataSource
{
    var items = [String]()
    var table = UITableView()
    var act = [() -> (Void)]()
    
    var superSuperView = UIView()
    
    @objc func showItems()
    {
        
        fixLayout()
        
        if(table.alpha == 0)
        {
            self.layer.zPosition = 1
            UIView.animate(withDuration: 0.3
                , animations: {
                    self.table.alpha = 1;
            })
            
        }
            
        else
        {
            
            UIView.animate(withDuration: 0.3
                , animations: {
                    self.table.alpha = 0;
                    self.layer.zPosition = 0
            })
            
        }
        
    }
    
    
    func initMenu(_ items: [String], actions: [() -> (Void)])
    {
        self.items = items
        self.act = actions
        
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
        table.alpha = 0
        table.separatorColor = self.backgroundColor
        superSuperView.addSubview(table)
        self.addTarget(self, action:#selector(DropMenuButton.showItems), for: .touchUpInside)
        
        //table.registerNib(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "cell")
        
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
        table.alpha = 0
        table.separatorColor = UIColor.darkGray
        superSuperView.addSubview(table)
        
        self.addTarget(self, action:#selector(DropMenuButton.showItems), for: .touchUpInside)
        
        //table.registerNib(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "cell")
        
    }
    
    
    func fixLayout()
    {
        
        let auxPoint2 = superSuperView.convert(self.frame.origin, from: self.superview)
        
        var tableFrameHeight = CGFloat()
        
        if (items.count >= 3){
            tableFrameHeight = self.frame.height * 3
        }else{
            
            tableFrameHeight = self.frame.height * CGFloat(items.count)
        }
        table.frame = CGRect(x: auxPoint2.x, y: auxPoint2.y + self.frame.height, width: self.frame.width, height:tableFrameHeight)
        table.rowHeight = self.frame.height
        table.separatorColor = UIColor.darkGray
        
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
        
        if self.act.count > 1
        {
            self.act[indexPath.row]()
        }
        
        showItems()
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let itemLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        itemLabel.textAlignment = NSTextAlignment.center
        itemLabel.text = items[(indexPath as NSIndexPath).row]
        itemLabel.font = self.titleLabel?.font
        itemLabel.textColor = UIColor.black
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.white
        
        let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        cell.backgroundColor = UIColor.white
        cell.selectedBackgroundView = bgColorView
        cell.separatorInset = UIEdgeInsetsMake(0, self.frame.width, 0, self.frame.width)
    
        cell.addSubview(itemLabel)
        
        
        return cell
    }
    
}
