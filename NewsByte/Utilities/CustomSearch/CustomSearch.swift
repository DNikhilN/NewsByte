//
//  CustomSearch.swift
//
//


import UIKit

class CustomSearch: UIView {

    private var contentView: UIView?
    
    var searchTf: UITextField?
    var crossBtn: UIButton?
        
    var vcNav:UIViewController?
    var completionForSearch: ((String) -> Void)?
    var completionForCrossBtn: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    private func configureView() {
        guard let view = self.loadViewFromNib(nibName: "CustomSearch") else {
            AppConsole.printLog("❌ Failed to load BottomTab.xib")
            return
        }
        
        self.contentView = view
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)
        
        // Manually find the button inside the loaded XIB
        if let search = view.viewWithTag(1) as? UITextField {
            self.searchTf = search
            self.searchTf?.addPadding(.left(40))
            self.searchTf?.addTarget(self, action: #selector(search(_:)), for: .allEvents)
        }
        else {
            AppConsole.printLog("❌ Button not found in BottomTab.xib")
        }
        
        if let button = view.viewWithTag(2) as? UIButton {
            self.crossBtn = button
            self.crossBtn?.isHidden = true
            button.addTarget(self, action: #selector(crossTapped(_:)), for: .touchUpInside)
        }
        else {
            AppConsole.printLog("❌ Button not found in BottomTab.xib")
        }
    
    }
    
    @objc private func crossTapped(_ sender: UIButton) {
        AppConsole.printLog("✅ Button tapped!")
        self.completionForCrossBtn?()
    }
    
    @objc private func search(_ sender: UITextField) {
        let text = sender.text ?? EMPTY_STRING
        self.completionForSearch?(text)
    }

}




