import Foundation
import UIKit

enum Theme: Int {
    case dark
    case light
}

private extension Theme {
    private struct LightTheme {
        let backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9647058824, blue: 0.9647058824, alpha: 1)
        let textColor = #colorLiteral(red: 0.04705882353, green: 0.1176470588, blue: 0.2431372549, alpha: 1)
        let dimTextColor = #colorLiteral(red: 0.768627451, green: 0.7960784314, blue: 0.8235294118, alpha: 1)
        let navigationBarColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    }

    private struct DarkTheme {
        let backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        let textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let dimTextColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        let navigationBarColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    }

    private var darkColors: DarkTheme {
        return DarkTheme()
    }

    private var lightColors: LightTheme {
        return LightTheme()
    }
}

extension Theme {
    var backgroundColor: UIColor {
        return self == .dark ? darkColors.backgroundColor : lightColors.backgroundColor
    }

    var textColor: UIColor {
        return self == .dark ? darkColors.textColor : lightColors.textColor
    }

    var dimTextColor: UIColor {
        return self == .dark ? darkColors.dimTextColor : lightColors.dimTextColor
    }

    var navigationBarColor: UIColor {
        return self == .dark ? darkColors.navigationBarColor : lightColors.navigationBarColor
    }
}
