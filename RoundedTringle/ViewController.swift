//
//  ViewController.swift
//  RoundedTringle
//
//  Created by Dmitriy Ignatyev on 18/02/2019.
//  Copyright © 2019 Dmitriy Ignatyev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //showArrowViews()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupArrowTest()
    }
    
    private func setupArrowTest() {
        let arrow = ArrowContainerView(contentView: UIButton(type: .custom))
        installContentView(arrow)
        
        let bottomTargetView = UIView()
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
        
        let topTargetView = UIView()
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
        
        arrow.setArrowCenteredTo(anchor: .toXCenterOf(targetView: bottomTargetView))
        arrow.view.setTitle("dsfsdfdsfsfs", for: .normal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            bottomTargetCenter.constant = 100
            // arrow.setArrowCenteredTo(targetView: topTargetView)
            arrow.updateArrowPosition()
        }
    }
    
    func showArrowViews() {
        let offsetTop = makeArrowView()
        offsetTop.setArrowCenteredTo(anchor: .toOffset(xOffset: 40, placement: .top))
        
        let offsetBottom = makeArrowView()
        offsetBottom.setArrowCenteredTo(anchor: .toOffset(xOffset: 80, placement: .bottom))
        
        let ratioTop = makeArrowView()
        ratioTop.setArrowCenteredTo(anchor: .toSelfWidth(ratio: 1/3, placement: .top))
        
        let ratioBottom = makeArrowView()
        ratioBottom.setArrowCenteredTo(anchor: .toSelfWidth(ratio: 1/2, placement: .bottom))
        
        let arrowViewTargetTop = makeArrowView()
        let topTarget = makeTarget(withLeading: 120)
        arrowViewTargetTop.setArrowCenteredTo(anchor: .toXCenterOf(targetView: topTarget.target))
        
        let arrowViewTargetBottom = makeArrowView()
        let bottomTarget = makeTarget(withLeading: 160)
        arrowViewTargetBottom.setArrowCenteredTo(anchor: .toXCenterOf(targetView: bottomTarget.target))
        
        let all: [UIView] = [offsetTop,
                             offsetBottom,
                             ratioTop,
                             ratioBottom,
                             topTarget.container,
                             arrowViewTargetTop,
                             arrowViewTargetBottom,
                             bottomTarget.container]
        
        for view in all {
            stackView.addArrangedSubview(view)
        }
        
    }
    
    func makeArrowView() -> ArrowContainerView<UILabel> {
        let text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor"
        let arrowView = ArrowContainerView(contentView: UILabel())
        arrowView.contentViewInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        arrowView.view.numberOfLines = 0
        arrowView.view.text = text
        return arrowView
    }
    
    func makeTarget(withLeading leading: CGFloat) -> (target: UIView, container: UIView) {
        let targetViewContainer = UIView()
        let targetView = UIView()
        do {
            targetViewContainer.translatesAutoresizingMaskIntoConstraints = false
            targetView.translatesAutoresizingMaskIntoConstraints = false
            targetView.backgroundColor = UIColor.magenta
            
            let superView: UIView = targetViewContainer
            superView.addSubview(targetView)
            
            NSLayoutConstraint.activate([
                targetView.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: leading),
                targetView.topAnchor.constraint(equalTo: superView.topAnchor),
                superView.bottomAnchor.constraint(equalTo: targetView.bottomAnchor),
                targetView.widthAnchor.constraint(equalToConstant: 40),
                targetView.heightAnchor.constraint(equalToConstant: 10)])
            
        }
        return (targetView, targetViewContainer)
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
