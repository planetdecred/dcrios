//
//  PinSetupViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import JGProgressHUD
import Dcrlibwallet

class RequestPinViewController: SecurityBaseViewController {
    var securityFor: String = "" // expects "Spending", "Startup" or other security section
    var showCancelButton = false
    var requestPinConfirmation = false
    var pinToConfirm: String = ""
    let pinHiddenInput = UITextField()
    
    var onUserEnteredPin: ((_ pin: String) -> Void)?
    var onChangeHeaderText: ((_ text: String) -> Void)?
    
    @IBOutlet weak var pinCount: UILabel!
    @IBOutlet weak var prgsPinStrength: ProgressView!
    @IBOutlet weak var pinCollectionView: UICollectionView!
    @IBOutlet weak var pinCollectionViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var enterSpendingPinLabel: UILabel!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInterface()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.pinHiddenInput.becomeFirstResponder()
    }
    
    func setupInterface() {
        self.pinHiddenInput.keyboardType = UIKeyboardType.decimalPad
        self.view.addSubview(self.pinHiddenInput)
        self.pinHiddenInput.isHidden = true
        self.pinHiddenInput.addTarget(self, action: #selector(self.onPinTextChanged), for: .editingChanged)
        
        let layout = UICollectionViewCenterLayout()
        layout.estimatedItemSize = CGSize(width: 16, height: 16)
        pinCollectionView.collectionViewLayout = layout
        
        if !self.requestPinConfirmation {
            self.prgsPinStrength.isHidden = true
            self.pinCount.isHidden = true
        }
        
        self.setTexts(isFirstStep: true)
    }
    
    private func setTexts(isFirstStep:Bool) {
        if isFirstStep {
            self.btnSubmit.setTitle(LocalizedStrings.next,for: .normal)
            if self.requestPinConfirmation {
                self.onChangeHeaderText?(String(format: LocalizedStrings.createPIN, self.securityFor))
            } else {
                self.onChangeHeaderText?(String(format: LocalizedStrings.enterPIN, self.securityFor))
            }
        } else {
            self.onChangeHeaderText?(String(format: LocalizedStrings.confirmPIN, self.securityFor))
            self.btnSubmit.setTitle(LocalizedStrings.create,for: .normal)
        }
    }
    
    @objc func onPinTextChanged() {
        guard let pinText = self.pinHiddenInput.text else { return }
        let isPinOk = pinText.count > 0
        pinCount.text = "\(pinText.count)"
        self.enterSpendingPinLabel.isHidden = isPinOk
        self.btnSubmit.isEnabled = isPinOk
        
        self.pinCollectionView.reloadData()
        self.pinCollectionView.layoutIfNeeded()
        self.pinCollectionViewHeightContraint.constant = max(16, self.pinCollectionView.contentSize.height)

        if self.requestPinConfirmation {
            self.pinCount.isHidden = !isPinOk
            let pinStrength = PinPasswordStrength.percentageStrength(of: pinText)
            self.prgsPinStrength.progressTintColor = pinStrength.color
            self.prgsPinStrength.progress = pinStrength.strength
        }
    }
    
    private func stepBack() {
        self.pinToConfirm = ""
        self.prgsPinStrength.progress = 0
        self.prgsPinStrength.isHidden = false
        self.pinHiddenInput.text = ""
        self.onPinTextChanged()
        self.btnBack.isHidden = true
    }
    
    @IBAction func onSubmit(_ sender: UIButton) {
        guard let pinText = self.pinHiddenInput.text else { return }
        if pinText == "" { return }
        
        if self.requestPinConfirmation && self.pinToConfirm == "" {
            self.pinToConfirm = pinText
            self.prgsPinStrength.progress = 0
            self.prgsPinStrength.isHidden = true
            self.pinHiddenInput.text = ""
            self.onPinTextChanged()
            self.setTexts(isFirstStep: false)
            self.btnBack.isHidden = false
            self.enterSpendingPinLabel.text = LocalizedStrings.enterSpendingPINAgain
        }
        else if self.requestPinConfirmation && self.pinToConfirm != pinText {
            self.stepBack()
            self.enterSpendingPinLabel.text = LocalizedStrings.pinsDidNotMatch
        } else {
            // only quit VC if not part of the SecurityVC tabs
            if self.tabBarController == nil {
                self.dismissView()
            }
            self.onUserEnteredPin?(pinText)
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.stepBack()
        self.enterSpendingPinLabel.text = LocalizedStrings.enterSpendingPIN
        self.setTexts(isFirstStep: true)
    }
    
    @IBAction func onCancelButtonTapped(_ sender: Any) {
        self.dismissView()
    }

    func dismissView() {
        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}


extension RequestPinViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.pinHiddenInput.text ?? "").count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PinCell", for: indexPath)
        return cell
    }
}

class CollectionViewRow {
    var attributes = [UICollectionViewLayoutAttributes]()
    var spacing: CGFloat = 0

    init(spacing: CGFloat) {
        self.spacing = spacing
    }

    func add(attribute: UICollectionViewLayoutAttributes) {
        attributes.append(attribute)
    }

    var rowWidth: CGFloat {
        return attributes.reduce(0, { result, attribute -> CGFloat in
            return result + attribute.frame.width
        }) + CGFloat(attributes.count - 1) * spacing
    }

    func centerLayout(collectionViewWidth: CGFloat) {
        let padding = (collectionViewWidth - rowWidth) / 2
        var offset = padding
        for attribute in attributes {
            attribute.frame.origin.x = offset
            offset += attribute.frame.width + spacing
        }
    }
}

class UICollectionViewCenterLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }

        var rows = [CollectionViewRow]()
        var currentRowY: CGFloat = -1

        for attribute in attributes {
            if currentRowY != attribute.frame.origin.y {
                currentRowY = attribute.frame.origin.y
                rows.append(CollectionViewRow(spacing: 10))
            }
            rows.last?.add(attribute: attribute)
        }

        rows.forEach { $0.centerLayout(collectionViewWidth: collectionView?.frame.width ?? 0) }
        return rows.flatMap { $0.attributes }
    }
}
