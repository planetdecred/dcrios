//
//  Button.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

@IBDesignable
class Button: UIButton {
	private var originalButtonText: String?
	private var isLoading: Bool = false
	lazy private var loaderLabel: UILabel = {
		let loaderLabel = UILabel()
		loaderLabel.translatesAutoresizingMaskIntoConstraints = false
		loaderLabel.font = UIFont(name: "SourceSansPro-Regular", size: 18)
		loaderLabel.textColor = UIColor.appColors.bluishGray
		return loaderLabel
	}()
	lazy private var loaderIcon: UIImageView = {
		let loaderIcon = UIImageView()
		loaderIcon.translatesAutoresizingMaskIntoConstraints = false
		loaderIcon.image = UIImage(named: "btn_spinner")
		return loaderIcon
	}()
	lazy private var loaderView: UIView = {
		let loaderView = UIView()
		loaderView.isHidden = true
		self.addSubview(loaderView)
		
		loaderView.translatesAutoresizingMaskIntoConstraints = false
		loaderView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		loaderView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

		loaderView.addSubview(loaderIcon)
		loaderIcon.widthAnchor.constraint(equalToConstant: 20).isActive = true
		loaderIcon.heightAnchor.constraint(equalToConstant: 20).isActive = true
		loaderIcon.leadingAnchor.constraint(equalTo: loaderView.leadingAnchor).isActive = true
		loaderIcon.topAnchor.constraint(equalTo: loaderView.topAnchor).isActive = true
		loaderIcon.bottomAnchor.constraint(equalTo: loaderView.bottomAnchor).isActive = true

		loaderView.addSubview(loaderLabel)
		loaderLabel.leadingAnchor.constraint(equalTo: loaderIcon.trailingAnchor, constant: 10).isActive = true
		loaderLabel.trailingAnchor.constraint(equalTo: loaderView.trailingAnchor).isActive = true
		loaderLabel.centerYAnchor.constraint(equalTo: loaderIcon.centerYAnchor).isActive = true
		
		return loaderView
	}()
	
	@IBInspectable var loaderTextStringKey: String = "" {
		didSet {
			loaderLabel.text = NSLocalizedString(loaderTextStringKey, comment: "")
		}
	}

	@IBInspectable var borderColor: UIColor = UIColor.clear {
		didSet {
			setupView()
		}
	}
	
	@IBInspectable var selectedBorderColor: UIColor = UIColor.appColors.decredBlue {
		didSet {
			setupView()
		}
	}
	
	@IBInspectable var borderWidth: CGFloat = 0 {
		didSet {
			setupView()
		}
	}
	
	@IBInspectable var cornerRadius: CGFloat = 0 {
		didSet {
			setupView()
		}
	}
	
	@IBInspectable var enabledBackgroundColor: UIColor = UIColor.appColors.decredBlue {
		didSet {
			setupView()
		}
	}

	@IBInspectable var disabledBackgroundColor : UIColor = UIColor.appColors.lighterGray {
		didSet {
			setupView()
		}
	}

	override var isEnabled: Bool {
		didSet {
			setupView()
		}
	}
	
	override var isSelected: Bool {
		didSet {
			setupView()
		}
	}
	
	fileprivate func setupView() {
		self.layer.borderColor = self.isSelected ? self.selectedBorderColor.cgColor : self.borderColor.cgColor
		self.layer.borderWidth = self.borderWidth
        self.layer.cornerRadius = self.cornerRadius
		
		self.updateBackgroundColor()
	}
	
	private func updateBackgroundColor() {
		if self.isLoading {
			self.backgroundColor = .clear
		} else if isEnabled {
			self.backgroundColor = self.enabledBackgroundColor
		} else {
			self.backgroundColor = self.disabledBackgroundColor
		}
	}
	
	public func startLoading() {
        if self.isLoading { return }
		self.isLoading = true
		
		DispatchQueue.main.async {
			self.updateBackgroundColor()
			self.originalButtonText = self.title(for: .normal)
			self.setTitle("", for: .normal)
			self.loaderView.isHidden = false
			self.loaderIcon.layer.removeAllAnimations()
			
			let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
			rotation.toValue = NSNumber(value: Double.pi * 2)
			rotation.duration = 1
			rotation.isCumulative = true
			rotation.repeatCount = Float.greatestFiniteMagnitude
			self.loaderIcon.layer.add(rotation, forKey: "rotationAnimation")
		}
	}
	
	public func stopLoading() {
		if !self.isLoading { return }
		self.isLoading = false
		
		DispatchQueue.main.async {
			self.updateBackgroundColor()
			self.setTitle(self.originalButtonText, for: .normal)
			self.loaderIcon.layer.removeAllAnimations()
			self.loaderView.isHidden = true
		}
	}
}
