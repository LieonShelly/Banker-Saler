//
//  TabBarController.swift
//  AdForMerchant
//
//  Created by choice on 16/5/16.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    static var start: CFTimeInterval = 0
    static var end: CFTimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
}

extension TabBarController: UITabBarControllerDelegate {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.title == "消息" {
            NotificationCenter.default.post(name: Notification.Name(rawValue: refreshMessageCenterItemNotification), object: nil, userInfo: nil)
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index: Int? = viewControllers?.index(of: viewController)
        let vc = tabBarController.selectedViewController
        if TabBarController.end != 0 {
            TabBarController.start = TabBarController.end
        }
        TabBarController.end = CACurrentMediaTime()
        if TabBarController.end - TabBarController.start < 0.5 {
//            print("double click")
            if let idx = index {
                switch idx {
                case 0:
                    if vc is UINavigationController {
                        guard let nav = vc as? UINavigationController else { return false }
                        if nav.viewControllers[0] is ProductHomeViewController {
                            guard let tempVc = nav.viewControllers[0] as? ProductHomeViewController else { return false }
                            tempVc.requestDoubleClickListWithReload()
                        }
                    }
                case 1:
                    if vc is UINavigationController {
                      guard let nav = vc as? UINavigationController else { return false }
                        if nav.viewControllers[0] is CampaignHomeViewController {
                           guard let tempVc = nav.viewControllers[0] as? CampaignHomeViewController else { return false }
                            tempVc.requestDoubleClickListWithReload()
                        }
                    }
                case 2:
                    if vc is UINavigationController {
                       guard let nav = vc as? UINavigationController else { return false }
                        if nav.viewControllers[0] is AdHomeViewController {
                          guard  let tempVc = nav.viewControllers[0] as? AdHomeViewController else { return false }
                            tempVc.requestDoubleClickListWithReload()
                        }
                        
                    }
                case 3:
                    if vc is UINavigationController {
                       guard let nav = vc as? UINavigationController else { return false }
                        if nav.viewControllers[0] is NotificationViewController {
                           guard let tempVc = nav.viewControllers[0] as? NotificationViewController else { return false }
                            tempVc.requestDoubleClickListWithReload()
                        }
                    }
                default:
                    break
                }
            }
            TabBarController.start = 0
            TabBarController.end = 0
        } else {
            TabBarController.start = CACurrentMediaTime()
            TabBarController.end = CACurrentMediaTime()
        }
        
        if index != 0 && tabBarController.selectedIndex == 0 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: removeProductFilterConditionsNotification), object: nil)
        }
        
        return true
    }
}
