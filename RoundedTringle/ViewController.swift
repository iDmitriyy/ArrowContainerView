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
        
        showArrowViews()
        // setupArrowTest()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        let offsetTop = makeArrowView(text: "Стрелка смотрит на 40-й пиксель по горизнтали сверху")
        offsetTop.setArrowCenteredTo(anchor: .toOffset(xOffset: 40, placement: .top))
        
        let offsetBottom = makeArrowView(text: "Стрелка смотрит на 80-й пиксель по горизнтали снизу")
        offsetBottom.setArrowCenteredTo(anchor: .toOffset(xOffset: 80, placement: .bottom))
        
        let ratioTop = makeArrowView(text: "Стрелка смотрит на 1/2 ширины сверху")
        ratioTop.setArrowCenteredTo(anchor: .toSelfWidth(ratio: 1/2, placement: .top))
        
        let ratioBottom = makeArrowView(text: "Стрелка смотрит на 1/6 ширины снизу")
        ratioBottom.setArrowCenteredTo(anchor: .toSelfWidth(ratio: 1/6, placement: .bottom))
        
        let arrowViewTargetTop = makeArrowView(text: "Стрелка смотрит розовый квадратик сверху")
        let topTarget = makeTarget(withLeading: -30)
        
        let arrowViewTargetBottom = makeArrowView(text: "Стрелка смотрит розовый квадратик снизу")
        let bottomTarget = makeTarget(withLeading: 50)
        
        let all: [UIView] = [
            offsetTop,
            makeSpacing(),
            offsetBottom,
            makeSpacing(),
            ratioTop,
            makeSpacing(),
            ratioBottom,
            makeSpacing(),
            topTarget.container,
            arrowViewTargetTop,
            makeSpacing(),
            arrowViewTargetBottom,
            bottomTarget.container
        ]
        
//        for view in all {
//            stackView.addArrangedSubview(view)
//        }
        
        do {
            var constraints: [NSLayoutConstraint] = []
            var previousYAnchor: NSLayoutYAxisAnchor = view.safeAreaLayoutGuide.topAnchor
            let superView: UIView = view
            
            for subView in all {
                superView.addSubview(subView)
                constraints.append(contentsOf: [
                    subView.leadingAnchor.constraint(equalTo: superView.leadingAnchor),
                    superView.trailingAnchor.constraint(equalTo: subView.trailingAnchor),
                    subView.topAnchor.constraint(equalTo: previousYAnchor)])
                
                previousYAnchor = subView.bottomAnchor
            }
            
            NSLayoutConstraint.activate(constraints)
        }
        
        arrowViewTargetTop.setArrowCenteredTo(anchor: .toXCenterOf(targetView: topTarget.target))
        arrowViewTargetBottom.setArrowCenteredTo(anchor: .toXCenterOf(targetView: bottomTarget.target))
    }
    
    func makeArrowView(text: String) -> ArrowContainerView<UILabel> {
        let arrowView = ArrowContainerView(contentView: UILabel())
        arrowView.contentViewInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        arrowView.view.numberOfLines = 0
        arrowView.view.text = text
        arrowView.backgroundColor = .lightGray
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
                targetView.centerXAnchor.constraint(equalTo: superView.centerXAnchor, constant: leading),
                targetView.topAnchor.constraint(equalTo: superView.topAnchor),
                superView.bottomAnchor.constraint(equalTo: targetView.bottomAnchor),
                targetView.widthAnchor.constraint(equalToConstant: 40),
                targetView.heightAnchor.constraint(equalToConstant: 10)])
            
        }
        return (targetView, targetViewContainer)
    }
    
    func makeSpacing() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 16).isActive = true
        return view
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
