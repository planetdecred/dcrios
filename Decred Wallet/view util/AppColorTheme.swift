import Foundation
import UIKit

enum Theme: Int {
    case dark
    case light
}

private extension Theme {
    struct LightTheme {
        let backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9647058824, blue: 0.9647058824, alpha: 1)
        let textColor = #colorLiteral(red: 0.04705882353, green: 0.1176470588, blue: 0.2431372549, alpha: 1)
        let dimTextColor = #colorLiteral(red: 0.768627451, green: 0.7960784314, blue: 0.8235294118, alpha: 1)
        let navigationBarColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        let defaultTextColor = #colorLiteral(red: 0.04705882353, green: 0.1176470588, blue: 0.2431372549, alpha: 1)
        let greenTextColor = #colorLiteral(red: 0.1764705882, green: 0.8470588235, blue: 0.6392156863, alpha: 1)
        let blueTextColor = #colorLiteral(red: 0.1607843137, green: 0.4392156863, blue: 1, alpha: 1)
        let accountDetailsTextColor = #colorLiteral(red: 0.3803921569, green: 0.4509803922, blue: 0.5254901961, alpha: 1)
        let white = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

    struct DarkTheme {
        let backgroundColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1882352941, alpha: 1)
        let textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let dimTextColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        let navigationBarColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1882352941, alpha: 1)
        let defaultTextColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let greenTextColor = #colorLiteral(red: 0.1764705882, green: 0.8470588235, blue: 0.6392156863, alpha: 1)
        let blueTextColor = #colorLiteral(red: 0.1607843137, green: 0.4392156863, blue: 1, alpha: 1)
        let accountDetailsTextColor = #colorLiteral(red: 0.3803921569, green: 0.4509803922, blue: 0.5254901961, alpha: 1)
        let white = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
    }

    var darkColors: DarkTheme {
        return DarkTheme()
    }

    var lightColors: LightTheme {
        return LightTheme()
    }
}

extension Theme {
    var toggle: Theme {
        return self == .dark ? .light : .dark
    }

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

    var defaultTextColor: UIColor {
        return self == .dark ? darkColors.defaultTextColor : lightColors.defaultTextColor
    }

    var blueTextColor: UIColor {
        return self == .dark ? darkColors.blueTextColor : lightColors.blueTextColor
    }

    var greenTextColor: UIColor {
        return self == .dark ? darkColors.greenTextColor : lightColors.greenTextColor
    }

    var accountDetailsTextColor: UIColor {
        return self == .dark ? darkColors.accountDetailsTextColor : lightColors.accountDetailsTextColor
    }

    var white: UIColor {
        return self == .dark ? darkColors.white : lightColors.white
    }
}
