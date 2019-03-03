//
//  ViewController.swift
//  RoundedTringle
//
//  Created by Dmitriy Ignatyev on 18/02/2019.
//  Copyright © 2019 Dmitriy Ignatyev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupArrowTest()
        
        // setupButtonTest()
    }
    
    private func setupArrowTest() {
        let arrow = MBArrowContainerView(contentView: UIButton(type: .custom))
        installContentView(arrow)
        
        let bottomTargetView = TargetView()
        let bottomTargetCenter = bottomTargetView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        //bottomTargetView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -40)
        do {
            bottomTargetView.translatesAutoresizingMaskIntoConstraints = false
            bottomTargetView.backgroundColor = .cyan
            self.view.addSubview(bottomTargetView)
            
            NSLayoutConstraint.activate([
                bottomTargetView.topAnchor.constraint(equalTo: arrow.bottomAnchor, constant: 0),
                bottomTargetCenter,
                bottomTargetView.widthAnchor.constraint(equalToConstant: 80),
                bottomTargetView.heightAnchor.constraint(equalToConstant: 30)
                ])
        }
        
        let topTargetView = TargetView()
        do {
            topTargetView.translatesAutoresizingMaskIntoConstraints = false
            topTargetView.backgroundColor = .cyan
            self.view.addSubview(topTargetView)
            
            let targetCenter = topTargetView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0)
            
            NSLayoutConstraint.activate([
                arrow.topAnchor.constraint(equalTo: topTargetView.bottomAnchor, constant: 0),
                targetCenter,
                topTargetView.widthAnchor.constraint(equalToConstant: 80),
                topTargetView.heightAnchor.constraint(equalToConstant: 30)
                ])
        }
        
        arrow.setArrowCenteredTo(targetView: bottomTargetView)
        arrow.view.setTitle("dsfsdfdsfsfs", for: .normal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            UIView.animate(withDuration: 1.2, animations: {
                bottomTargetCenter.constant = 100
                bottomTargetView.layoutIfNeeded()
            })
            // arrow.setArrowCenteredTo(targetView: topTargetView)
            arrow.updateArrowPosition()
        }
    }
    
    private var button: UIButton?
    
    private func setupButtonTest() {
        let button = MBLabeledRightIconButton()
        button.setTitle("drgdfgdgggfdgfdgggfdfdggfdgdfg",
                           for: .normal)
        button.backgroundColor = .red
        
        button.setImage(UIImage(named: "close_cross"), for: .normal)
        
        installContentView(button)
        self.button = button
        
        button.addTarget(self, action: #selector(addTexttoButton), for: .touchUpInside)
    }
    
    @objc private func addTexttoButton() {
        let text = (button?.titleLabel?.text ?? "") + "v"
        button?.setTitle(text, for: .normal)
    }
    

    private func installContentView(_ subView: UIView) {
        subView.translatesAutoresizingMaskIntoConstraints = false
        let superView: UIView = self.view
        superView.addSubview(subView)
        
        NSLayoutConstraint.activate([
            subView.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 8),
            superView.trailingAnchor.constraint(equalTo: subView.trailingAnchor, constant: 8),
            subView.topAnchor.constraint(equalTo: superView.topAnchor, constant: 130)
            ])
    }
}

final class TargetView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
