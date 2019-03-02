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
    
    open var containedViewInsets: UIEdgeInsets {
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
    
    private var arrowParams: ArrowParams?
    
    // MARK: Overriden
    open override class var requiresConstraintBasedLayout: Bool { return true }
    
    open override var backgroundColor: UIColor? {
        didSet {
            let color = backgroundColor ?? .lightGray
            super.backgroundColor = .green // nil
            
            arrowView.tintColor = color
            arrowView.backgroundColor = color // FIXME: backgroundColor
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
        
        if let trait = arrowParams {
            align(arrow: arrowView, withTrait: trait)
        }
        /* Ветвеление else не требуется, т.к arrowTrait равен только до первого вызова setArrow(aligment:)
         После вызова этого метода проперти arrowTrait не равна nil и ее значение не удаляется */
        
        do {
            // FIXME: for debug
            // При первом вызове относительные координаты некорректны
            if let trait = arrowParams {
                switch trait.aligment {
                case .toXCenterOf(let targetView):
                    _ = getArrowPlacement(targetView: targetView)
                }
            }
            
            // TODO: сделать проверку targetView и ее superView, чтоб стрелка двигалась если размер поменялся
            // сделать возможность без стрелки
            // сделать анимацию движения стрелки
            // по ходу придется класть контентную view в контейнер, т.к inset у контентной задается от стрелки
        }
    }
    
    open override func updateConstraints() {
        super.updateConstraints()
        
    }
    
    // MARK: Public Interface
    public final func setArrow(aligment: MBArrowedViewAligment) {
        switch aligment {
        case .toXCenterOf(let targetView):
            guard let superView = targetView.superview else { return }
            
            let placement = getArrowPlacement(relativeTo: targetView)
            let trait = ArrowParams(position: placement, aligment: aligment)
            arrowParams = trait
            
            // Обновление constraint'ов происходит только здесь
            updateConstraintsFor(arrowPosition: placement)
            
            align(arrow: arrowView, withTrait: trait)
        }
    }
    
    
    private func updateConstraintsFor(arrowPosition: MBArrowedViewPlacement) {
        let top: CGFloat
        let bottom: CGFloat
        
        switch arrowPosition {
        case .top:
            top = containedViewInsets.top + ArrowedConstants.arrowHeight
            bottom = containedViewInsets.bottom
        case .bottom:
            top = containedViewInsets.top
            bottom = containedViewInsets.bottom + ArrowedConstants.arrowHeight
        }
        
        contentTopConstraint?.constant = top
        contentBottomConstraint?.constant = bottom
    }
}

extension MBArrowedContainerView {
    // MARK: - Arrow Aligment Methods
    
    /** Policy-метод. В зависимости от aligment вызывает разные реализации
     Метод предназначен для вызова внутри layoutSubviews() чтоб двигать стрелку по координатам */
    private func align(arrow arrowView: UIView, withTrait trait: ArrowParams) {
        switch trait.aligment {
        case .toXCenterOf(let targetView):
            align(arrow: arrowView, toHorizontalCenterOf: targetView, position: trait.position)
        }
    }
    
    /// реализация выравния стрелки относительно targetView
    /// Двигает arrowView по координатам
    private func align(arrow arrowView: UIView,
                       toHorizontalCenterOf targetView: UIView,
                       position: MBArrowedViewPlacement) {
        guard targetView !== self else { return }
        // FIXME: + проверить что targetView не является одной из subView
        
        // центр targetView в собственной системе координат
        let targetConvertedCenter = targetView.convert(targetView.center, to: self)
        
        /* рассчеты arrowOriginY завязаны на рассчеты updateConstraintsFor(arrowPosition: Position) т.к используют
         одни и те же константы */
        let arrowOriginY: CGFloat
        switch position {
        case .top:
            arrowOriginY = 0
        case .bottom:
            arrowOriginY = bounds.height - ArrowedConstants.arrowHeight
        }
        
        let arrowCenterX: CGFloat
        do {
            let possibleArrowCenterX = targetConvertedCenter.x
            let arrowWidth = ArrowedConstants.arrowWidth
            let selfWidth = bounds.width
            // Стрелка должна быть видна полнстью. Проверяем позицию и корректируем при необходимости:
            if possibleArrowCenterX + (arrowWidth / 2) > selfWidth {
                arrowCenterX = selfWidth - (arrowWidth / 2) // Не позволяем уехать за границы справа
            } else if possibleArrowCenterX - (arrowWidth / 2) < 0 {
                arrowCenterX = 0 + (arrowWidth / 2) // Не позволяем уехать за границы слева
            } else {
                arrowCenterX = possibleArrowCenterX
            }
        }
        
        let arrowFrame = CGRect(x: arrowCenterX - (ArrowedConstants.arrowWidth / 2),
                                y: arrowOriginY,
                                width: ArrowedConstants.arrowWidth,
                                height: ArrowedConstants.arrowHeight)
        
        arrowView.frame = arrowFrame
        
        type(of: self).transform(arrow: arrowView, for: position)
    }
    
    private func getArrowPlacement(relativeTo targetView: UIView) -> MBArrowedViewPlacement {
        // Положение в координатном пространстве UIWindow
        // self.superview?.convert(self.frame.origin, to: nil)
        
        //        let selfGlobalOrigin = self.convert(CGPoint.zero, from: nil)
        //        let targetViewGlobalOrigin = targetView.convert(CGPoint.zero, from: nil)
        
        let selfGlobalOrigin = self.convert(CGPoint.zero, to: nil)
        let targetViewGlobalOrigin = targetView.convert(CGPoint.zero, to: nil)
        
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
    }
    
    /// Добавление view в иерархию
    private func installContentView() {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let superView: UIView = self
        superView.addSubview(view)
        
        let top = view.topAnchor.constraint(equalTo: superView.topAnchor, constant: containedViewInsets.top)
        let bottom = superView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: containedViewInsets.bottom)
        
        let constraints: [NSLayoutConstraint] = [
            view.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: containedViewInsets.left),
            superView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: containedViewInsets.right),
            top,
            bottom
        ]
        NSLayoutConstraint.activate(constraints)
        
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true // FIXME: delete
        
        self.contentTopConstraint = top
        self.contentBottomConstraint = bottom
    }
    
    private func setupInitialAppearance() {
        backgroundColor = .gray
        setupArrowInitialApperanace()
    }
    
    private func setupArrowInitialApperanace() {
        let frame = CGRect(x: 0, y: 0, width: ArrowedConstants.arrowWidth, height: ArrowedConstants.arrowHeight)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = frame
        
        let bezierPath = type(of: self).getArrowBezierPath()
        shapeLayer.path = bezierPath.cgPath
        // apply other properties related to the path
        
        shapeLayer.fillColor = UIColor.black.cgColor
        
        arrowView.frame = frame
        arrowView.layer.mask = shapeLayer
        arrowView.clipsToBounds = true
    }
}

extension MBArrowedContainerView {
    /// Вращает стрелку на 180 градусов чтоб она смотрела ввкерх либо вниз в зависимости от параметра position
    private static func transform(arrow: UIView, for position: MBArrowedViewPlacement) {
        // Предполагается, что на используемой в качестве стрелки картинке стрелка смотрит вниз
        let scaleY: CGFloat
        switch position {
        case .top:
            scaleY = -1
        case .bottom:
            scaleY = 1
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

private struct ArrowParams {
    let position: MBArrowedViewPlacement
    let aligment: MBArrowedViewAligment
}

private enum ArrowedConstants {
    static let arrowWidth: CGFloat = 24
    static let arrowHeight: CGFloat = 8
}

fileprivate enum MBArrowedViewPlacement {
    case top
    case bottom
}

public enum MBArrowedViewAligment {
    // case alignedToSelfWidth(CGFloat) // указывается точка на которую ровняться. Например 1/2 это середина, или 1/3
    case toXCenterOf(UIView) // FIXME: make view weak
}

// MARK: NibLoadable Container
//
//open class MBArrowedXibContainerView<T>: MBArrowedContainerView<T> where T: NIbLoadable {
//
//}
