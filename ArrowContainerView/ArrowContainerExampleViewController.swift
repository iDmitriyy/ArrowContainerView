//
//  ViewController.swift
//  RoundedTringle
//
//  Created by Dmitriy Ignatyev on 18/02/2019.
//  Copyright © 2019 Dmitriy Ignatyev. All rights reserved.
//

import UIKit

final class ArrowContainerExampleViewController: UIViewController {

    @IBOutlet private weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showArrowViews()
    }
    
    private func showArrowViews() {
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        let offsetTopArrowView = makeArrowView(text: "Стрелка смотрит на 60-й пиксель по горизнтали сверху")
        offsetTopArrowView.setArrowCenteredTo(anchor: .toOffset(xOffset: 60, placement: .top))
        
        let offsetBottomArrowView = makeArrowView(text: "Стрелка смотрит на 140-й пиксель по горизнтали снизу")
        offsetBottomArrowView.setArrowCenteredTo(anchor: .toOffset(xOffset: 140, placement: .bottom))
        
        let ratioTopArrowView = makeArrowView(text: "Стрелка смотрит на 1/2 ширины сверху")
        ratioTopArrowView.setArrowCenteredTo(anchor: .toSelfWidth(ratio: 1/2, placement: .top))
        
        let ratioBottomArrowView = makeArrowView(text: "Стрелка смотрит на 1/6 ширины снизу")
        ratioBottomArrowView.setArrowCenteredTo(anchor: .toSelfWidth(ratio: 1/6, placement: .bottom))
        
        let targetTopArrowView = makeArrowView(text: "Стрелка смотрит розовый квадратик сверху")
        let topTarget = makeTarget(withCenterXOffset: -30)
        targetTopArrowView.setArrowCenteredTo(anchor: .toXCenterOf(targetView: topTarget.target))
        
        let targetBottomArrowView = makeArrowView(text: "Стрелка смотрит розовый квадратик снизу")
        let bottomTarget = makeTarget(withCenterXOffset: 50)
        targetBottomArrowView.setArrowCenteredTo(anchor: .toXCenterOf(targetView: bottomTarget.target))
        
        let allViews: [UIView] = [
            makeSpacing(),
            offsetTopArrowView,
            makeSpacing(),
            offsetBottomArrowView,
            makeSpacing(),
            makeSeparator(),
            makeSpacing(),
            ratioTopArrowView,
            makeSpacing(),
            ratioBottomArrowView,
            makeSpacing(),
            makeSeparator(),
            makeSpacing(),
            topTarget.container,
            targetTopArrowView,
            makeSpacing(),
            targetBottomArrowView,
            bottomTarget.container
        ]
        
        allViews.forEach { stackView.addArrangedSubview($0) }
    }
}

extension ArrowContainerExampleViewController {
    private func makeArrowView(text: String) -> ArrowContainerView<UILabel> {
        let gray98: UIColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        let gray33: UIColor = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        
        let arrowView = ArrowContainerView(view: UILabel())
        arrowView.contentViewInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        arrowView.backgroundColor = gray33
        arrowView.setCornerRadius(5)
        
        arrowView.view.numberOfLines = 0
        arrowView.view.text = text
        arrowView.view.textColor = gray98
        arrowView.view.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        return arrowView
    }
    
    private func makeTarget(withCenterXOffset offset: CGFloat) -> (target: UIView, container: UIView) {
        let targetViewContainer = UIView()
        let targetView = UIView()
        do {
            let pink: UIColor = #colorLiteral(red: 0.8862745098, green: 0.3882352941, blue: 0.5411764706, alpha: 1)
            targetViewContainer.translatesAutoresizingMaskIntoConstraints = false
            targetView.translatesAutoresizingMaskIntoConstraints = false
            targetView.backgroundColor = pink
            targetView.layer.cornerRadius = 2
            targetView.layer.masksToBounds = true
            
            let superView: UIView = targetViewContainer
            superView.addSubview(targetView)
            
            NSLayoutConstraint.activate([
                targetView.centerXAnchor.constraint(equalTo: superView.centerXAnchor, constant: offset),
                targetView.topAnchor.constraint(equalTo: superView.topAnchor),
                superView.bottomAnchor.constraint(equalTo: targetView.bottomAnchor),
                targetView.widthAnchor.constraint(equalToConstant: 40),
                targetView.heightAnchor.constraint(equalToConstant: 10)])
            
        }
        return (targetView, targetViewContainer)
    }
    
    private func makeSpacing() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 16).isActive = true
        return view
    }
    
    private func makeSeparator() -> UIView {
        let gray85: UIColor = #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1)
        let view = UIView()
        view.backgroundColor = gray85
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }
}
