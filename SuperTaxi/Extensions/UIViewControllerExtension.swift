//
//  UIViewControllerExtension.swift
//  SuperTaxi
//
//  Created by Jose Martins on 14/10/20.
//

import UIKit

extension UIViewController {

    func showToast(message : String, offSetY: CGFloat = 0, _ size: CGFloat = 13) {
        var newOffSetY: CGFloat = self.view.frame.size.height - 195
        
        if offSetY != 0 {
            newOffSetY = offSetY
        }

        let toastLabel = UILabel(
            frame: CGRect(
                x: self.view.frame.width / 2 - 100,
                y: newOffSetY,
                width: 200,
                height: 35
            )
        )
        
        toastLabel.backgroundColor = .black
                
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont.systemFont(ofSize: size)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
            
        self.view.addSubview(toastLabel)
            
        UIView.animate(
            withDuration: 4.0,
            delay: 0.1,
            options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}
