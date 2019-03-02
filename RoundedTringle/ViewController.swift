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
        let arrow = MBArrowedContainerView<UIView>()
        installContentView(arrow)
        
        let targetView = UIView()
        targetView.translatesAutoresizingMaskIntoConstraints = false
        targetView.backgroundColor = .cyan
        self.view.addSubview(targetView)
        
        NSLayoutConstraint.activate([
            targetView.topAnchor.constraint(equalTo: arrow.bottomAnchor, constant: 8),
            targetView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -40),
            targetView.widthAnchor.constraint(equalToConstant: 80),
            targetView.heightAnchor.constraint(equalToConstant: 30)
            ])
        
        arrow.setArrow(aligment: .toXCenterOf(targetView))
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
            subView.topAnchor.constraint(equalTo: superView.topAnchor, constant: 80)
            ])
    }
}

