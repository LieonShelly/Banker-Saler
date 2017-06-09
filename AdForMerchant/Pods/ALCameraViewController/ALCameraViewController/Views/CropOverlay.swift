//
//  CropOverlay.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/30.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

internal class CropOverlay: UIView {

    var outerLines = [UIView]()
    var horizontalLines = [UIView]()
    var verticalLines = [UIView]()
    
    var topLeftCornerLines = [UIView]()
    var topRightCornerLines = [UIView]()
    var bottomLeftCornerLines = [UIView]()
    var bottomRightCornerLines = [UIView]()
    
    let cornerDepth: CGFloat = 3
    let cornerWidth: CGFloat = 20
    let lineWidth: CGFloat = 1
    
    internal init() {
        super.init(frame: CGRect.zero)
        createLines()
    }
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        createLines()
    }

    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createLines()
    }
    
    override func layoutSubviews() {
        
        for i in 0..<outerLines.count {
            let line = outerLines[i]
            var lineFrame: CGRect
            switch (i) {
            case 0:
                lineFrame = CGRect(x: 0, y: 0, width: bounds.width, height: lineWidth)
                break
            case 1:
                lineFrame = CGRect(x: bounds.width - lineWidth, y: 0, width: lineWidth, height: bounds.height)
                break
            case 2:
                lineFrame = CGRect(x: 0, y: bounds.height - lineWidth, width: bounds.width, height: lineWidth)
                break
            case 3:
                lineFrame = CGRect(x: 0, y: 0, width: lineWidth, height: bounds.height)
                break
            default:
                lineFrame = CGRect.zero
                break
            }
            
            line.frame = lineFrame
        }
        
        let corners = [topLeftCornerLines, topRightCornerLines, bottomLeftCornerLines, bottomRightCornerLines]
        for i in 0..<corners.count {
            let corner = corners[i]
            var horizontalFrame: CGRect
            var verticalFrame: CGRect
            
            switch (i) {
            case 0:
                verticalFrame = CGRect(x: -cornerDepth, y:  -cornerDepth, width:  cornerDepth, height:  cornerWidth)
                horizontalFrame = CGRect(x: -cornerDepth, y:  -cornerDepth, width:  cornerWidth, height:  cornerDepth)
                break
            case 1:
                verticalFrame = CGRect(x: bounds.width, y:  -cornerDepth, width:  cornerDepth, height:  cornerWidth)
                horizontalFrame = CGRect(x: bounds.width + cornerDepth - cornerWidth, y:  -cornerDepth, width:  cornerWidth, height:  cornerDepth)
                break
            case 2:
                verticalFrame = CGRect(x: -cornerDepth, y:  bounds.height + cornerDepth - cornerWidth, width:  cornerDepth, height:  cornerWidth)
                horizontalFrame = CGRect(x: -cornerDepth, y:  bounds.height, width:  cornerWidth, height:  cornerDepth)
                break
            case 3:
                verticalFrame = CGRect(x: bounds.width, y:  bounds.height + cornerDepth - cornerWidth, width:  cornerDepth, height:  cornerWidth)
                horizontalFrame = CGRect(x: bounds.width + cornerDepth - cornerWidth, y:  bounds.height, width:  cornerWidth, height:  cornerDepth)
                break
            default:
                verticalFrame = CGRect.zero
                horizontalFrame = CGRect.zero
                break
            }
            
            corner[0].frame = verticalFrame
            corner[1].frame = horizontalFrame
          
        }
        
//        let lineThickness = lineWidth / UIScreen.main.scale
//        let padding = (bounds.height - (lineThickness * CGFloat(horizontalLines.count))) / CGFloat(horizontalLines.count + 1)
//        
//        for i in 0..<horizontalLines.count {
//            let hLine = horizontalLines[i]
//            let vLine = verticalLines[i]
//            
//            let spacing = (padding * CGFloat(i + 1)) + (lineThickness * CGFloat(i))
//            
//            hLine.frame = CGRect(x: 0, y: spacing, width: bounds.width, height:  lineThickness)
//            vLine.frame = CGRect(x: spacing, y: 0, width: lineThickness, height: bounds.height)
//        }
    }
    
    func createLines() {
        
        outerLines = [createLine(), createLine(), createLine(), createLine()]
//        horizontalLines = [createLine(), createLine()]
//        verticalLines = [createLine(), createLine()]
        
        topLeftCornerLines = [createLine(), createLine()]
        topRightCornerLines = [createLine(), createLine()]
        bottomLeftCornerLines = [createLine(), createLine()]
        bottomRightCornerLines = [createLine(), createLine()]
        
        isUserInteractionEnabled = false
    }
    
    func createLine() -> UIView {
        let line = UIView()
        line.backgroundColor = UIColor.white
        addSubview(line)
        return line
    }
    
    func setClearSubViews() {
        outerLines.forEach { $0.removeFromSuperview()}
        topLeftCornerLines.forEach { $0.removeFromSuperview()}
        topRightCornerLines .forEach { $0.removeFromSuperview()}
        bottomLeftCornerLines.forEach { $0.removeFromSuperview()}
        bottomRightCornerLines.forEach { $0.removeFromSuperview()}
        
    }
}

internal class CoverView: UIView {
    var roundX: CGFloat = 0
    var roundY: CGFloat = 0
    var roundWidth: CGFloat = 0
    
    convenience init(roundFrame: CGRect) {
        self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        self.isOpaque = false
        self.roundX = roundFrame.origin.x
        self.roundY = roundFrame.origin.y
        self.roundWidth = roundFrame.width
        isUserInteractionEnabled = false
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor)
        context?.fill(rect)
        let roundRect = CGRect(x: roundX, y: roundY, width: roundWidth, height: roundWidth)
        if roundRect.intersects(rect) {
            context?.setBlendMode(CGBlendMode.clear)
            UIColor.clear.set()
            context?.fillEllipse(in: roundRect)
        }
    }
}
