//
//  AOLinkedStoryboardSegue.swift
//  FPTrade
//
//  Created by Kuma on 9/2/15.
//  Copyright (c) 2015 Windward. All rights reserved.
//  swiftlint:disable force_unwrapping

import UIKit

class AOLinkedStoryboardSegue: UIStoryboardSegue {
    static func sceneNamed(_ identifier: String) -> UIViewController {
        
        var info = identifier.components(separatedBy: "@")
        
        let storyboard_name = info[1]
        let scene_name = info[0]
        
        let storyboard = UIStoryboard(name: storyboard_name, bundle: nil)
        
        var scene: UIViewController?
        
        if scene_name.isEmpty {
            scene = (storyboard.instantiateInitialViewController())
            
        } else {
            scene = (storyboard.instantiateViewController(withIdentifier: scene_name))
        }
        return scene ?? UIViewController()
    }
    
    override init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: AOLinkedStoryboardSegue.sceneNamed(identifier!))
    }
    
    override func perform() {
        let source = self.source 
        source.navigationController?.pushViewController(self.destination, animated: true)
    }
    
    static func performWithIdentifier(_ identifier: String, source: UIViewController, sender: Any?) {
        let segue = AOLinkedStoryboardSegue(identifier: identifier, source: source, destination: source)
        source.prepare(for: segue, sender: sender)
        segue.perform()
    }
    
}
