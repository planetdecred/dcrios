//
//  RequestPinViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class RequestPinViewController: SecurityRequestBaseViewController {
    @IBOutlet weak var headerLabel: UILabel!

    @IBOutlet weak var pinCollectionView: UICollectionView!
    @IBOutlet weak var pinCollectionViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var enterPinLabel: UILabel!
    @IBOutlet weak var pinCount: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var prgsPinStrength: ProgressView!

    @IBOutlet weak var btnBack: UIButton?
    @IBOutlet weak var btnCancel: UIButton?
    @IBOutlet weak var btnSubmit: Button!

    var pinToConfirm: String = ""
    let pinHiddenInput: UITextField = {
        let textfield = UITextField()
        textfield.isHidden = true
        textfield.keyboardType = UIKeyboardType.decimalPad
        return textfield
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInterface()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.pinHiddenInput.becomeFirstResponder()
    }

    private func setupInterface() {
        self.view.addSubview(self.pinHiddenInput)
        self.pinHiddenInput.delegate = self
        self.pinHiddenInput.addTarget(self, action: #selector(self.onPinTextChanged), for: .editingChanged)

        let layout = UICollectionViewCenterLayout()
        layout.estimatedItemSize = CGSize(width: 16, height: 16)
        pinCollectionView.collectionViewLayout = layout

        self.prgsPinStrength.superview?.isHidden = !self.requestConfirmation
        self.setPromptAndButtonText(isFirstStep: true)

        if let prompt = self.prompt {
            self.headerLabel?.text = prompt
        } else {
            self.headerLabel?.removeFromSuperview()
        }

        if !self.showCancelButton {
            self.btnCancel?.removeFromSuperview()
        }
    }

    private func setPromptAndButtonText(isFirstStep: Bool) {
        if isFirstStep {
            self.btnSubmit.setTitle(self.submitBtnText ?? LocalizedStrings.next, for: .normal)
            self.enterPinLabel.text = String(format: LocalizedStrings.enterPIN, self.securityFor)
        } else {
            self.btnSubmit.setTitle(LocalizedStrings.create, for: .normal)
            self.enterPinLabel.text = String(format: LocalizedStrings.confirmPIN, self.securityFor)
        }
    }

    @objc func onPinTextChanged() {
        var pinText = self.pinHiddenInput.text ?? ""
        let isPinEmpty = pinText.count == 0

        if self.isInErrorState {
            if let lastNumber = pinText.last {
                pinText = String(lastNumber)
            }
            self.pinHiddenInput.text = pinText
            self.hideError()
        }

        self.pinCount.text = "\(pinText.count)"
        self.enterPinLabel.isHidden = !isPinEmpty
        self.btnSubmit.isEnabled = !isPinEmpty
        self.pinCount.isHidden = isPinEmpty

        self.updatePinCollectionView()

        if self.requestConfirmation {
            let pinStrength = PinPasswordStrength.percentageStrength(of: pinText)
            self.prgsPinStrength.progressTintColor = pinStrength.color
            self.prgsPinStrength.progress = pinStrength.strength
        }
    }

    private func reset() {
        self.pinToConfirm = ""
        self.prgsPinStrength.progress = 0
        self.prgsPinStrength.superview?.isHidden = false
        self.pinHiddenInput.text = ""
        self.updatePinCollectionView()
        self.onPinTextChanged()
        self.btnBack?.isHidden = true
        self.setPromptAndButtonText(isFirstStep: true)
    }

    @IBAction func onSubmit(_ sender: UIButton) {
        guard let pinText = self.pinHiddenInput.text, !pinText.isEmpty else { return }

        if self.requestConfirmation && self.pinToConfirm.isEmpty {
            self.pinToConfirm = pinText
            self.prgsPinStrength.progress = 0
            self.prgsPinStrength.superview?.isHidden = true
            self.pinHiddenInput.text = ""
            self.updatePinCollectionView()
            self.onPinTextChanged()
            self.setPromptAndButtonText(isFirstStep: false)
            self.btnBack?.isHidden = false
        } else if self.requestConfirmation && self.pinToConfirm != pinText {
            self.reset()
            self.enterPinLabel.text = LocalizedStrings.pinsDidNotMatch
        } else {
            self.btnSubmit.startLoading()
            self.onLoadingStatusChanged?(true)
            self.btnBack?.isEnabled = false
            self.btnCancel?.isEnabled = false
            self.pinHiddenInput.resignFirstResponder()
            self.onUserEnteredSecurityCode?(pinText, self)
        }
    }

    private func updatePinCollectionView() {
        DispatchQueue.main.async {
            self.pinCollectionView.reloadData()
            self.pinCollectionViewHeightContraint.constant = max(16, self.pinCollectionView.contentSize.height)
            self.pinCollectionView.layoutIfNeeded()
        }
    }

    @IBAction func onBack(_ sender: Any) {
        self.reset()
        self.setPromptAndButtonText(isFirstStep: true)
    }

    @IBAction func onCancelButtonTapped(_ sender: Any) {
        self.dismissView()
    }

    override func showError(text: String) {
        super.showError(text: text)
        self.pinCollectionView.reloadData()
        self.pinCount.textColor = UIColor.appColors.orange
        self.errorLabel.text = text
        self.errorLabel.isHidden = false
        self.btnSubmit.stopLoading()
        self.onLoadingStatusChanged?(false)
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
        cell.backgroundColor = self.isInErrorState == true ? UIColor.appColors.orange : UIColor.appColors.turquoise
        return cell
    }
}

extension RequestPinViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let char = string.cString(using: String.Encoding.utf8),
            (strcmp(char, "\\b") == -92), //Backspace was pressed
            self.isInErrorState {
                textField.text = ""
                self.onPinTextChanged()
        }
        guard CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) else {
            return false
        }
        return true
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
        var offset = (collectionViewWidth - rowWidth) / 2
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
