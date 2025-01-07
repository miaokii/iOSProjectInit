//
//  MKLabel.swift
//  MuYunControl
//
//  Created by miaokii on 2023/2/26.
//

import UIKit

class MKLabel: UILabel {

    var inset: UIEdgeInsets = .zero
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        rect.origin.x -= inset.left
        rect.origin.y -= inset.top
        rect.size.width += inset.left + inset.right
        rect.size.height += inset.top + inset.bottom
        
        return rect
    }
    
    override func drawText(in rect: CGRect) {
        let newRect =  CGRectMake(inset.left,
                                  inset.top,
                                  rect.size.width-inset.left-inset.right,
                                  rect.size.height-inset.top-inset.bottom)
        super.drawText(in: newRect)
    }
}
