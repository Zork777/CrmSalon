//
//  AlertWindow.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 15.04.2022.
//

import Foundation
import UIKit

func showMessage(message: String) {
    let dialog = UIAlertController(title: "alert", message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default)
    dialog.addAction(action)
    let vc = UIApplication.topViewController()
    vc?.present(dialog, animated: true)
    print (message)
}

extension UIApplication {
    
    class func topViewController(_ viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(presented)
        }
        return viewController
    }
    
    class func topNavigationController(_ viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UINavigationController? {
        
        if let nav = viewController as? UINavigationController {
            return nav
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return selected.navigationController
            }
        }
        return viewController?.navigationController
    }
}
