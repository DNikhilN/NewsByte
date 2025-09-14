//
//  UIView+Extension.swift
//  NewsByte
//
//  
//

import UIKit

extension UIView {
    func loadViewFromNib(nibName: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        return bundle.loadNibNamed(nibName, owner: self, options: nil)?.first as? UIView
    }
}
