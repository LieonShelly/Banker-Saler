//
//  InputView.swift
//  Demo
//
//  Created by Koh Ryu on 2017/2/15.
//  Copyright © 2017年 Koh Ryu. All rights reserved.
//

import UIKit

fileprivate let delButtonTag = -1

class InputView: UIInputView {
    
    @IBOutlet private var buttons: [UIButton]!
    weak var keyInput: UITextField!
    private let numbers: [Int] = {
        var num: [Int] = []
        for i in 0...9 {
            num.append(i)
        }
        return num
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

        for button in buttons {
            button.addTarget(self, action: #selector(self.buttonHandle(sender:)), for: .touchUpInside)
        }
        loadOnlyNumbers()
    }
    
    @IBAction private func buttonHandle(sender: UIButton) {
        UIDevice.current.playInputClick()
        if sender.tag != delButtonTag {
            var length = 0
            if let len = keyInput.text?.characters.count {
                length = len
            }
            if length < 6 {
                keyInput.insertText("\(sender.tag)")
            }
        } else {
            keyInput.deleteBackward()
        }
    }
    
    func loadOnlyNumbers() {
        var set = numbers
        for button in buttons {
            let randomIndex = Int(arc4random_uniform(UInt32(set.count)))
            let num = set.remove(at: randomIndex)
            button.setTitle("\(num)", for: .normal)
            button.tag = num
        }
    }

}

extension InputView: UIInputViewAudioFeedback {
    var enableInputClicksWhenVisible: Bool {
        return true
    }
}
