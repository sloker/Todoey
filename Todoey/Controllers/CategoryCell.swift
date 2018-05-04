//
//  CategoryCell.swift
//  Todoey
//
//  Created by Steven Loker on 5/3/18.
//  Copyright © 2018 Steven M. Loker. All rights reserved.
//

import UIKit
import SwipeCellKit
import ChameleonFramework

class CategoryCell: SwipeTableViewCell {
    
    override var backgroundColor: UIColor? {
        didSet {
            updateColors()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryView = ColoredDisclosureIndicator(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        accessoryView?.backgroundColor = UIColor.clear
    }

    func updateColors() {
        let contrast = ContrastColorOf(backgroundColor ?? UIColor.black, returnFlat: true)
        
        textLabel?.textColor = contrast
        accessoryView?.tintColor = contrast
        
        textLabel?.setNeedsDisplay()
        accessoryView?.setNeedsDisplay()
    }
}
