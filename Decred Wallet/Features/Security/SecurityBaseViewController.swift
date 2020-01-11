//
//  SecurityBaseViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class SecurityBaseViewController: UIViewController {
    static func instantiate() -> Self {
        return Storyboards.Security.instantiateViewController(for: self)
    }
    
    func dismissView() {
        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
