//
//  UIAplication.swift
//  Podcasts
//
//  Created by Mediha Karakuş on 21.06.23.
//

import UIKit

extension UIApplication {
    static func mainTabbarController() -> MainTabBarController? {
        return shared.keyWindow?.rootViewController as? MainTabBarController
    }
}
