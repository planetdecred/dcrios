import Foundation
import UIKit

// MARK: - Theme

extension UIView {
    @objc func changeSkin() {
//        backgroundColor = AppDelegate.shared.theme.backgroundColor
    }
    
    func subscribeToThemeUpdates() {
        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(self.changeSkin),
                name: NSNotification.Name.appSkinDidChange,
                object: nil
        )
    }
}
