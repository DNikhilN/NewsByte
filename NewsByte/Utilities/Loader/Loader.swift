//
//  Loader.swift
//
//

import UIKit

class LoaderManager {
    static let shared = LoaderManager()
    private var loaderView: UIView?

    private init() {}

    func show(in view: UIView) {
        guard loaderView == nil else { return } 

        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = overlay.center
        activityIndicator.startAnimating()

        overlay.addSubview(activityIndicator)
        view.addSubview(overlay)

        loaderView = overlay
    }

    func hide() {
        loaderView?.removeFromSuperview()
        loaderView = nil
    }
}
