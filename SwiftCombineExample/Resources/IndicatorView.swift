//
//  IndicatorView.swift
//  SwiftAsyncExample
//
//  Created by Takeshi Kayahashi on 2022/05/22.
//

import Foundation
import UIKit

class IndicatorView {
    
    static let shared = IndicatorView()

    private init() {}
    
    var grayOutView: UIView!
    
    func startIndicator() {
        DispatchQueue.main.async{
            // xcode15以降のwindow取得方法
            let scenes = UIApplication.shared.connectedScenes
            let windowScenes = scenes.first as? UIWindowScene
            guard let window = windowScenes?.windows.first else {
                return
            }
            self.grayOutView = UIView(frame: window.bounds)
            self.grayOutView.backgroundColor = .black
            self.grayOutView.alpha = 0.6
            
            let indicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
            indicatorView.center = self.grayOutView.center
            indicatorView.color = .white
            
            self.grayOutView.addSubview(indicatorView)
            
            window.addSubview(self.grayOutView)
            window.bringSubviewToFront(self.grayOutView)
            
            indicatorView.startAnimating()
        }
    }
    
    func stopIndicator() {
        DispatchQueue.main.async{
            guard self.grayOutView != nil else {
                return
            }
            self.grayOutView.removeFromSuperview()
        }
    }
    
}
