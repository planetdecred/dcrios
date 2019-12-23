//
//  RequestPinViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class RequestPinViewController: RequestBaseViewController {
    @IBOutlet weak var pinCount: UILabel!
    @IBOutlet weak var prgsPinStrength: ProgressView!
    @IBOutlet weak var pinCollectionView: UICollectionView!
    @IBOutlet weak var pinCollectionViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var enterPinLabel: UILabel!
    @IBOutlet weak var btnSubmit: Button!
    @IBOutlet weak var btnBack: UIButton?
    @IBOutlet weak var btnCancel: UIButton?
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!

    var pinToConfirm: String = ""
    let pinHiddenInput = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInterface()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.pinHiddenInput.becomeFirstResponder()
    }
    
    private func setupInterface() {
        self.pinHiddenInput.keyboardType = UIKeyboardType.decimalPad
        self.view.addSubview(self.pinHiddenInput)
        self.pinHiddenInput.isHidden = true
        self.pinHiddenInput.addTarget(self, action: #selector(self.onPinTextChanged), for: .editingChanged)
        
        let layout = UICollectionViewCenterLayout()
        layout.estimatedItemSize = CGSize(width: 16, height: 16)
        pinCollectionView.collectionViewLayout = layout
        
        if !self.requestConfirmation {
            self.prgsPinStrength.isHidden = true
        }
        
        self.setTexts(isFirstStep: true)
        
        if let prompt = self.prompt {
            self.headerLabel?.text = prompt
        } else {
            self.headerLabel?.removeFromSuperview()
        }
        
        if !self.showCancelButton {
            self.btnCancel?.removeFromSuperview()
        }
        
        if let submitBtnText = self.submitBtnText {
            self.btnSubmit.setTitle(submitBtnText, for: .normal)
        }
    }
    
    private func setTexts(isFirstStep: Bool) {
        if isFirstStep {
            self.btnSubmit.setTitle(LocalizedStrings.next, for: .normal)
            self.enterPinLabel.text = String(format: LocalizedStrings.enterPIN, self.securityFor)
        } else {
            self.btnSubmit.setTitle(LocalizedStrings.create, for: .normal)
            self.enterPinLabel.text = String(format: LocalizedStrings.confirmPIN, self.securityFor)
        }
    }
    
    @objc func onPinTextChanged() {
        guard var pinText = self.pinHiddenInput.text else { return }
        let isPinOk = pinText.count > 0
        
        if self.isInErrorState {
            pinText = String(pinText.last!)
            self.pinHiddenInput.text = pinText
            self.hideError()
        }
        
        pinCount.text = "\(pinText.count)"
        self.enterPinLabel.isHidden = isPinOk
        self.btnSubmit.isEnabled = isPinOk
        self.pinCount.isHidden = !isPinOk
        
        self.pinCollectionView.reloadData()
        self.pinCollectionView.layoutIfNeeded()
        self.pinCollectionViewHeightContraint.constant = max(16, self.pinCollectionView.contentSize.height)

        if self.requestConfirmation {
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
        self.btnBack?.isHidden = true
    }
    
    @IBAction func onSubmit(_ sender: UIButton) {
        guard let pinText = self.pinHiddenInput.text else { return }
        if pinText == "" { return }
        
        if self.requestConfirmation && self.pinToConfirm == "" {
            self.pinToConfirm = pinText
            self.prgsPinStrength.progress = 0
            self.prgsPinStrength.isHidden = true
            self.pinHiddenInput.text = ""
            self.onPinTextChanged()
            self.setTexts(isFirstStep: false)
            self.btnBack?.isHidden = false
        }
        else if self.requestConfirmation && self.pinToConfirm != pinText {
            self.stepBack()
            self.enterPinLabel.text = LocalizedStrings.pinsDidNotMatch
        } else {
            self.btnSubmit.startLoading()
            self.btnBack?.isEnabled = false
            self.btnCancel?.isEnabled = false
            self.pinHiddenInput.resignFirstResponder()
            self.onUserEnteredCode?(pinText, self)
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.stepBack()
        self.setTexts(isFirstStep: true)
    }
    
    @IBAction func onCancelButtonTapped(_ sender: Any) {
        self.dismissView()
    }

    override func showError(text: String) {
        super.showError(text: text)
        self.pinCollectionView.reloadData()
        self.pinCount.textColor = UIColor.appColors.decredOrange
        self.errorLabel.text = text
        self.errorLabel.isHidden = false
        self.btnSubmit.stopLoading()
        self.pinHiddenInput.becomeFirstResponder()
        self.btnBack?.isEnabled = true
        self.btnCancel?.isEnabled = true
    }
    
    override func hideError() {
        super.hideError()
        self.pinCollectionView.reloadData()
        self.pinCount.textColor = UIColor.appColors.darkBluishGray
        self.errorLabel.isHidden = true
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
        cell.backgroundColor = self.isInErrorState == true ? UIColor.appColors.decredOrange : UIColor.appColors.green
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
