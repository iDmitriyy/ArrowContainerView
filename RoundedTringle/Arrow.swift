//
//  Arrow.swift
//  RoundedTringle
//
//  Created by Dmitriy Ignatyev on 19/02/2019.
//  Copyright © 2019 Dmitriy Ignatyev. All rights reserved.
//

import UIKit

open class MBArrowedContainerView<T: UIView>: UIView {
    /// This is content view
    public var view: T = makeViewInstanse()
    
    open var contentViewInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    }
    
    /// Do not call super when overriding this method
    open class func makeViewInstanse() -> T {
        return T()
    }
    
    // Private Properties
    private var arrowView = UIImageView()
    
    private weak var contentTopConstraint: NSLayoutConstraint?
    private weak var contentBottomConstraint: NSLayoutConstraint?
    
    private var arrowParams = ArrowParams()
    
    // MARK: Overriden
    open override class var requiresConstraintBasedLayout: Bool { return true }
    
    open override var backgroundColor: UIColor? {
        didSet {
            let color = backgroundColor ?? .darkGray
            super.backgroundColor = .lightGray // nil
            
            arrowView.tintColor = color
            arrowView.backgroundColor = .blue // FIXME: backgroundColor
            view.backgroundColor = color // FIXME: backgroundColor
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if let targetView = arrowParams.targetView, targetView.superview != nil {
            targetView.layoutIfNeeded()
            let placement = getArrowPlacement(relativeTo: targetView)
            
            makeArrowVisible(true)
            
            if placement == arrowParams.placement {
                /* В этом ветвлении метод updateConstraintsFor(arrowPlacement:) не вызывается, так как:
                 1. это приведет к рекурсии layoutSubviews(). Указанный метод вызывается в других ветвления
                 2. при входе в это ветвление гарантировано, что указанный метод был ранее вызыван в setArrowCenteredTo(targetView:) */
                align(arrow: arrowView, toHorizontalCenterOf: targetView, placement: placement)
            } else {
                arrowParams.placement = placement
                
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5) {
                        self.updateConstraintsFor(arrowPlacement: placement)
                        self.layoutIfNeeded()
                    }
                }
                // updateConstraintsFor(arrowPlacement: placement) // indirectly call layoutIfNeeded(), which leads to calling layoutSubviews() on next update cycle
            }
        } else {
            let placement: MBArrowedViewPlacement = .hidden
            
            if arrowParams.placement != placement {
                makeArrowVisible(false)
                updateConstraintsFor(arrowPlacement: placement)
            }
        }
        
        // TODO:
        // + сделать проверку targetView и ее superView, чтоб стрелка двигалась если размер поменялся
        // + сделать возможность без стрелки
        // сделать анимацию движения стрелки
        // по ходу придется класть контентную view в контейнер, т.к inset у контентной задается от стрелки
        // при первичной настройке настроить constraints и placement
    }
    
    // MARK: Public Interface
    func setArrowCenteredTo(targetView: UIView?) {
        arrowParams.targetView = targetView
        
        if let targetView = targetView, targetView.superview != nil {
            // Первчиная настройка constraint'ов
            updateConstraintsFor(arrowPlacement: arrowParams.placement)
        }
        
        setNeedsLayout()
    }
    
    /** Метод для обновления положения стрелки, если targetView меняет размер или положение */
    public final func updateArrowPosition() {
        setNeedsLayout() // Чтоб в следующем проходе laoyout'a вызывался layoutSubViews() где происходит позиционирование
    }
    
    private func updateConstraintsFor(arrowPlacement: MBArrowedViewPlacement) {
        let top: CGFloat
        let bottom: CGFloat
        
        switch arrowPlacement {
        case .top:
            top = contentViewInsets.top + ArrowedConstants.arrowHeight
            bottom = contentViewInsets.bottom
        case .bottom:
            top = contentViewInsets.top
            bottom = contentViewInsets.bottom + ArrowedConstants.arrowHeight
        case .hidden:
            top = contentViewInsets.top
            bottom = contentViewInsets.bottom
        }
        
        contentTopConstraint?.constant = top
        contentBottomConstraint?.constant = bottom
    }
    
    private func makeArrowVisible(_ visible: Bool) {
        arrowView.isHidden = !visible
    }
}

extension MBArrowedContainerView {
    // MARK: - Arrow Aligment Methods
    
    /** Policy-метод. В зависимости от aligment вызывает разные реализации
     Метод предназначен для вызова внутри layoutSubviews() чтоб двигать стрелку по координатам */
//    private func align(arrow arrowView: UIView, withTrait trait: ArrowParams) {
//        switch trait.aligment {
//        case .toXCenterOf(let targetView):
//            align(arrow: arrowView, toHorizontalCenterOf: targetView, position: trait.position)
//        }
//    }
    
    /** реализация выравния стрелки относительно targetView. Двигает arrowView по координатам */
    private func align(arrow arrowView: UIView,
                       toHorizontalCenterOf targetView: UIView,
                       placement: MBArrowedViewPlacement) {
        guard targetView !== self else { return }
        // FIXME: + проверить что targetView не является одной из subView
        // проверить, что bounds у targetView 0, т.к у нее layoutSubviews мог быть не вызван
        
        let targetViewCenter = CGPoint(x: targetView.bounds.midX,
                                       y: targetView.bounds.midY) // центр targetView в собственной системе координат
        let targetConvertedCenter = targetView.convert(targetViewCenter, to: self)
        
        
        
        let arrowHalfWidth = ArrowedConstants.arrowWidth / 2
        let arrowCenterX: CGFloat
        do {
            let possibleArrowCenterX = targetConvertedCenter.x
            let selfWidth = bounds.width
            // Стрелка должна быть видна полнстью. Проверяем позицию и корректируем при необходимости:
            if possibleArrowCenterX + arrowHalfWidth + contentViewInsets.right > selfWidth {
                arrowCenterX = selfWidth - contentViewInsets.right - arrowHalfWidth // Не позволяем уехать за границы справа
            } else if possibleArrowCenterX - arrowHalfWidth - contentViewInsets.left < 0 {
                arrowCenterX = 0 + contentViewInsets.left + arrowHalfWidth // Не позволяем уехать за границы слева
            } else {
                arrowCenterX = possibleArrowCenterX
            }
        }
        
        let arrowOriginY = getArrowOriginY(forPlacement: placement)
        
        let arrowFrame = CGRect(x: arrowCenterX - arrowHalfWidth,
                                y: arrowOriginY,
                                width: ArrowedConstants.arrowWidth,
                                height: ArrowedConstants.arrowHeight)
        
        arrowView.frame = arrowFrame
        
        type(of: self).rotateArrow(arrowView, for: placement)
    }
    
    
    
    private func getArrowOriginY(forPlacement placement: MBArrowedViewPlacement) -> CGFloat {
        let arrowOriginY: CGFloat
        switch placement {
        case .top:
            arrowOriginY = 0
        case .bottom:
            arrowOriginY = bounds.height - ArrowedConstants.arrowHeight
        case .hidden:
            arrowOriginY = 0
        }
        return arrowOriginY
    }
    
    private func getArrowPlacement(relativeTo targetView: UIView) -> MBArrowedViewPlacement {
        // Положение в координатном пространстве UIWindow
        let selfGlobalOrigin = self.convert(self.center, to: nil)
        let targetViewGlobalOrigin = targetView.convert(targetView.center, to: nil)
        
        let position: MBArrowedViewPlacement = selfGlobalOrigin.y < targetViewGlobalOrigin.y ? .bottom : .top
        return position
    }
}

extension MBArrowedContainerView {
    // MARK: - Initial Configuration
    // Private
    
    private func initialSetup() {
        installViews()
        setupInitialAppearance()
    }
    
    private func installViews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(arrowView) // FIXME: показывать arrowView в самом нечале не совсем корректно
        
        // Добавляем контентную view в иерархию
        installContentView()
        
        sendSubviewToBack(arrowView)
    }
    
    /// Добавление view в иерархию
    private func installContentView() {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let superView: UIView = self
        superView.addSubview(view)
        
        let top = view.topAnchor.constraint(equalTo: superView.topAnchor, constant: contentViewInsets.top)
        let bottom = superView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: contentViewInsets.bottom)
        
        let constraints: [NSLayoutConstraint] = [
            view.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: contentViewInsets.left),
            superView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: contentViewInsets.right),
            top,
            bottom
        ]
        NSLayoutConstraint.activate(constraints)
        
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true // FIXME: delete
        
        self.contentTopConstraint = top
        self.contentBottomConstraint = bottom
    }
    
    private func setupInitialAppearance() {
        backgroundColor = nil // FIXME:
        setupArrowInitialApperanace()
    }
    
    private func setupArrowInitialApperanace() {
        /*
        let frame = CGRect(x: 0, y: 0, width: ArrowedConstants.arrowWidth, height: ArrowedConstants.arrowHeight)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = frame
        
        let bezierPath = type(of: self).getArrowBezierPath()
        shapeLayer.path = bezierPath.cgPath
        // apply other properties related to the path
        
        shapeLayer.fillColor = UIColor.black.cgColor
        
        arrowView.frame = frame
        arrowView.layer.mask = shapeLayer
        */
        arrowView.clipsToBounds = true
    }
}

extension MBArrowedContainerView {
    /// Вращает стрелку на 180 градусов чтоб она смотрела ввкерх либо вниз в зависимости от параметра position
    private static func rotateArrow(_ arrow: UIView, for position: MBArrowedViewPlacement) {
        // Предполагается, что на используемой в качестве стрелки картинке стрелка смотрит вниз
        let scaleY: CGFloat
        switch position {
        case .top: scaleY = -1
        case .bottom: scaleY = 1
        case .hidden: scaleY = 1
        }
        
        arrow.transform = CGAffineTransform(scaleX: 1, y: scaleY)
    }
    
    private static func getArrowBezierPath() -> UIBezierPath {
        let arrowPath = UIBezierPath()
        // FIXME: Use
        arrowPath.move(to: CGPoint(x: 0, y: 0))
        arrowPath.addCurve(to: CGPoint(x: 9, y: 3), controlPoint1: CGPoint(x: 0, y: 0), controlPoint2: CGPoint(x: 5, y: 0))
        arrowPath.addCurve(to: CGPoint(x: 16, y: 8), controlPoint1: CGPoint(x: 13, y: 6), controlPoint2: CGPoint(x: 13, y: 8))
        arrowPath.addCurve(to: CGPoint(x: 23, y: 3), controlPoint1: CGPoint(x: 19, y: 8), controlPoint2: CGPoint(x: 19, y: 6))
        arrowPath.addCurve(to: CGPoint(x: 34, y: 0), controlPoint1: CGPoint(x: 27, y: 0), controlPoint2: CGPoint(x: 34, y: 0))
        arrowPath.addLine(to: CGPoint(x: 0, y: 0))
        
        arrowPath.close()
        // backgroundColor?.setFill()
        arrowPath.fill()
        
        return arrowPath
    }
}



private struct ArrowParams {
    var placement: MBArrowedViewPlacement = .hidden
    weak var targetView: UIView?
}

private enum ArrowedConstants {
    static let arrowWidth: CGFloat = 24
    static let arrowHeight: CGFloat = 8
}

fileprivate enum MBArrowedViewPlacement {
    case top
    case bottom
    case hidden
}

//public enum MBArrowedViewAligment {
//    // case alignedToSelfWidth(CGFloat) // указывается точка на которую ровняться. Например 1/2 это середина, или 1/3
//    case toXCenterOf(UIView) // FIXME: make view weak
//}

// MARK: NibLoadable Container
//
//open class MBArrowedXibContainerView<T>: MBArrowedContainerView<T> where T: NIbLoadable {
//
//}

/**
 Примеры xFraction:
 - 1/2 - ровнять по центру
 - 1/3 - ровнять на точку равной 1/3 ширины
 - 1/4 - ровнять на точку равной 1/4 ширины
 */
//    private func alignArrow(_ arrowView: UIView, toSelfWidth widthFraction: CGFloat, position: Position) {
//        let arrowWidth = arrowView.bounds.width
//        let selfWidth = bounds.width
//
//        let possibleArrowCenter = selfWidth * widthFraction
//
//        let arrowCenterX: CGFloat
//        // Стрелка должна быть видна полнстью. Проверяем позицию и корректируем при необходимости:
//        if possibleArrowCenter + (arrowWidth / 2) > selfWidth {
//            arrowCenterX = selfWidth - (arrowWidth / 2) // Не позволяем уехать за границы справа
//        } else if possibleArrowCenter - (arrowWidth / 2) < 0 {
//            arrowCenterX = selfWidth + (arrowWidth / 2) // Не позволяем уехать за границы слева
//        } else {
//            arrowCenterX = possibleArrowCenter
//        }
//
//        let arrowFrame: CGRect
//        switch position {
//        case .top:
//            break
//        case .bottom:
//            break
//        }
//
//
//        // guard
//    }
