//
//  SeparatorLine.swift
//  MountEmei
//
//  Created by Kuma on 3/10/15.
//  Copyright (c) 2015 Xiong Jiecheng. All rights reserved.
//

import Foundation

class SeparatorLine: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        for constraint in self.constraints {
            if constraint.firstAttribute == NSLayoutAttribute.height && constraint.constant == 1 {
                (constraint ).constant = constraint.constant / UIScreen.main.scale
            } else if constraint.firstAttribute == NSLayoutAttribute.width && constraint.constant == 1 {
                (constraint ).constant = constraint.constant / UIScreen.main.scale
            }
        }
    }
}
