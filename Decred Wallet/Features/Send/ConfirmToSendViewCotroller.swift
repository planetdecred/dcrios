//
//  ConfirmToSendViewCotroller.swift
//  Decred Wallet
//
//  Created by kayeli dennis on 03/12/2019.
//  Copyright © 2019 Decred. All rights reserved.
//

import UIKit

class ConfirmToSendViewCotroller: UIViewController {
    static let instance = Storyboards.Send.instantiateViewController(for: ConfirmToSendViewCotroller.self)

    @IBOutlet var tableView: UITableView!
    lazy var backdropView: UIView = {
        return self.view
    }()
    var isPresenting = false
    lazy var tableViewHeight: CGFloat = {
        return self.tableView.frame.size.height
    }()
    var sendingDetails: SendingDetails?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerCellNib(SimpleInfoTableViewCell.self)
        tableView.registerCellNib(ModalNavBarCell.self)
        tableView.registerCellNib(SendingInfoTableViewCell.self)
        tableView.registerCellNib(WarningInfoTableViewCell.self)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        backdropView.addGestureRecognizer(tapGesture)
    }

    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        dismiss(animated: true)
    }

    @IBAction func send(_ sender: UIButton) {
        let vc = ConfirmToSendPasswordEntryViewController.instance
        vc.modalPresentationStyle = .custom
        present(vc, animated: true, completion: nil)
    }
}

extension ConfirmToSendViewCotroller: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if indexPath.row == 0 {
            if let unWrappedCell = tableView.dequeueReusableCell(withIdentifier: "ModalNavBarCell", for: indexPath) as? ModalNavBarCell {
                unWrappedCell.configure(with: "Confirm to send") {
                    self.dismiss(animated: true, completion: nil)
                }
                cell = unWrappedCell
            }
        } else if indexPath.row == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "SendingInfoTableViewCell", for: indexPath) as? SendingInfoTableViewCell
        } else if indexPath.row == 2 {
            let simpleInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SimpleInfoTableViewCell", for: indexPath) as? SimpleInfoTableViewCell
            simpleInfoTableViewCell?.configureWith(title: "Transaction fee", and: sendingDetails?.transactionFee)
            cell = simpleInfoTableViewCell
        } else if indexPath.row == 3 {
            let simpleInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SimpleInfoTableViewCell", for: indexPath) as? SimpleInfoTableViewCell
            simpleInfoTableViewCell?.configureWith(title: "Total cost", and: sendingDetails?.totalCost)
            cell = simpleInfoTableViewCell
        }
        else if indexPath.row == 4 {
            let simpleInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SimpleInfoTableViewCell", for: indexPath) as? SimpleInfoTableViewCell
            simpleInfoTableViewCell?.configureWith(title: "Balance after send", and: sendingDetails?.balanceAfterSend)
            cell = simpleInfoTableViewCell
        } else if indexPath.row == 5 {
            cell = tableView.dequeueReusableCell(withIdentifier: "WarningInfoTableViewCell", for: indexPath) as? WarningInfoTableViewCell
        }
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 1 ? 180 : 45
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
}

extension ConfirmToSendViewCotroller: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        guard let toVC = toViewController else { return }
        isPresenting = !isPresenting
        
        if isPresenting == true {
            containerView.addSubview(toVC.view)
            
            tableView.frame.origin.y += tableViewHeight
            backdropView.alpha = 0
            
            UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
                self.tableView.frame.origin.y -= self.tableViewHeight
                self.backdropView.alpha = 1
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        } else {
            UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
                self.tableView.frame.origin.y += self.tableViewHeight
                self.backdropView.alpha = 0
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        }
    }
}
