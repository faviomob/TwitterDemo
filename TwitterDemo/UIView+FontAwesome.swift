//
//  UIView+FontAwesome.swift
//
//  Created by Marat on 20.09.16.
//  Copyright © 2016 Favio Mobile. All rights reserved.
//

import Foundation
import FontAwesome

func fontAwesomeText(faCode: String, title: String?) -> String {
    let faIcon = String.fontAwesomeIcon(code: faCode)
    return faIcon! + (title == nil ? "" : title!)
}

public extension UILabel {
    
    public var faIcon: String? {
        get {
            return self.text
        }
        set {
            self.text = fontAwesomeText(faCode: newValue!, title: self.text)
        }
    }
}

public extension UIButton {
    
    public var faIcon: String? {
        get {
            return self.title(for: UIControlState())
        }
        set {
            self.setTitle(fontAwesomeText(faCode: newValue!, title: self.title(for: UIControlState())), for: UIControlState())
        }
    }
    public var faImage: String? {
        get {
            return nil
        }
        set {
            let size = self.titleLabel != nil ?
                CGSize(width: self.titleLabel!.font.pointSize + 10, height: self.titleLabel!.font.pointSize + 10) :
                CGSize(width: self.frame.size.height - 4, height: self.frame.size.height - 4)
            self.setImage(UIImage.fontAwesomeIcon(code: newValue!, textColor: self.tintColor, size: size), for: .normal)
        }
    }
}

public extension UIImageView {
    
    public var faImage: String? {
        get {
            return nil
        }
        set {
            self.image = UIImage.fontAwesomeIcon(code: newValue!, textColor: self.tintColor, size: self.frame.size)
        }
    }
    public var faHighlightedImage: String? {
        get {
            return nil
        }
        set {
            self.highlightedImage = UIImage.fontAwesomeIcon(code: newValue!, textColor: self.tintColor, size: self.frame.size)
        }
    }
}
