//
//  UITableView.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

extension UITableView {
    func isCellCompletelyVisible(at indexPath: IndexPath) -> Bool {
        // cellForRow returns nil if cell is not visible or index path is out of range
        guard let cell = self.cellForRow(at: indexPath) else {
            return false
        }
        
        // Only return true if cell is fully displayed, i.e. cell top + cell height <= table height.
        let cellScrollPos = cell.frame.origin.y - self.contentOffset.y
        return cellScrollPos + cell.frame.height <= self.frame.height
    }
}

extension UITableViewCell {
    func blink() {
        UITableViewCell.animate(
            withDuration: 0.5,
            delay: 0.0,
            options: [.showHideTransitionViews, .autoreverse, .repeat],
            animations: { [weak self] in self?.alpha = 0.0 },
            completion: { [weak self] _ in self?.alpha = 1.0 }
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            [weak self] in
            self?.layer.removeAllAnimations()
        }
    }
}
