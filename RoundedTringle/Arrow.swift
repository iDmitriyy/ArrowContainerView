//
//  Arrow.swift
//  RoundedTringle
//
//  Created by Dmitriy Ignatyev on 19/02/2019.
//  Copyright © 2019 Dmitriy Ignatyev. All rights reserved.
//

import UIKit

open class MBArrowContainerView<T: UIView>: UIView {
    /// This is content view
    public var view: T = makeViewInstanse()
    
    open var contentViewInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
    }
    
    /// Do not call super when overriding this method
    open class func makeViewInstanse() -> T {
        return T()
    }
    
    // Private Properties
    private var arrowView = UIView()
    private var arrowParams = ArrowParams()
    
    private weak var contentTopConstraint: NSLayoutConstraint?
    private weak var contentBottomConstraint: NSLayoutConstraint?
    
    // MARK: Overriden
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
                
                let arrowFrame = getArrowFrameFor(targetView: targetView, placement: placement)
                
                UIView.animate(withDuration: ArrowedConstants.animationDuration) {
                    self.align(arrow: self.arrowView, toHorizontalCenterOf: targetView, placement: placement)
                    // self.arrowView.frame = arrowFrame
                }
                
                // align(arrow: arrowView, toHorizontalCenterOf: targetView, placement: placement)
            } else {
                arrowParams.placement = placement
                // updateConstraintValuesFor(arrowPlacement: placement)
                
                /*  Попадание в первое ветвление может произойти в 2-х сценариях: сразу либо после вызова
                 метода updateConstraintValuesFor().
                 Если у нас второй сценрий и мы анимруем constraint'ы то получается следующая ситуация: после изменения
                 constraint'ов начинается анимация, мы попадаем в первое ветвление и изменения производимые методом
                 align() тоже анимируются.
                 
                 */
                
                updateConstraintsFor(arrowPlacement: placement, animated: true)
            }
        } else {
            let placement: MBArrowedViewPlacement = .hidden
            
            if arrowParams.placement != placement { // делаем проверку чтоб не прятать повторно
                arrowParams.placement = placement
                makeArrowVisible(false)
                updateConstraintsFor(arrowPlacement: placement, animated: true) // ! анимация по факту не работает
            }
        }
        
        // TODO:
        // + сделать проверку targetView и ее superView, чтоб стрелка двигалась если размер поменялся
        // + сделать возможность без стрелки
        // + сделать анимацию движения стрелки
        // по ходу придется класть контентную view в контейнер, т.к inset у контентной задается от стрелки
        // при первичной настройке настроить constraints и placement
        // разобраться с inset'ами
    }
    
    // MARK: Public Interface
    func setArrowCenteredTo(targetView: UIView?) {
        guard targetView !== self else { return }
        
        arrowParams.targetView = targetView
        
        if let targetView = targetView, targetView.superview != nil {
            // Первчиная настройка constraint'ов. Не анимируется, потомучто анимация произойдет в методе layoutSubviews()
            updateConstraintsFor(arrowPlacement: arrowParams.placement, animated: false)
        }
        
        setNeedsLayout()
    }
    
    /** Метод для обновления положения стрелки, если targetView меняет размер или положение.
     Пример: изменение текста в UILabel */
    public final func updateArrowPosition() {
        setNeedsLayout() // Чтоб в следующем проходе laoyout'a вызывался layoutSubViews() где происходит позиционирование
    }
    
    private func updateConstraintsFor(arrowPlacement: MBArrowedViewPlacement, animated: Bool) {
        if animated {
            UIView.animate(withDuration: ArrowedConstants.animationDuration) {
                self.updateConstraintValuesFor(arrowPlacement: arrowPlacement)
                self.layoutIfNeeded()
            }
        } else {
            updateConstraintValuesFor(arrowPlacement: arrowPlacement)
        }
    }
    
    /// indirectly call setNeedsLayout(), which leads to calling layoutSubviews() on next update cycle
    private func updateConstraintValuesFor(arrowPlacement: MBArrowedViewPlacement) {
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
        /** Возможен кейс, когда вызов метода layoutSubviews() спровоцирован работой UIView.animateWithDuration.
         В этом случае вызов UIView.Transition для анимации проперти '.isHidden' приводит к артефактам отрисовки.
         По этой причине стрелка прячется и показывается без анимации */
        arrowView.isHidden = !visible
    }
}

extension MBArrowContainerView {
    // MARK: - Arrow Aligment Methods
    
    /** реализация выравния стрелки относительно targetView. Двигает arrowView по координатам */
    private func align(arrow arrowView: UIView,
                       toHorizontalCenterOf targetView: UIView,
                       placement: MBArrowedViewPlacement) {
        
        let arrowFrame = getArrowFrameFor(targetView: targetView, placement: placement)
        arrowView.frame = arrowFrame
        
        type(of: self).rotateArrow(arrowView, for: placement)
    }
    
    private func getArrowFrameFor(targetView: UIView, placement: MBArrowedViewPlacement) -> CGRect {
        let originX = getArrowOriginX(forTargetView: targetView)
        let originY = getArrowOriginY(forPlacement: placement)
        
        let arrowFrame = CGRect(x: originX,
                                y: originY,
                                width: ArrowedConstants.arrowWidth,
                                height: ArrowedConstants.arrowHeight)
        return arrowFrame
    }
    
    private func getArrowOriginX(forTargetView targetView: UIView) -> CGFloat {
        let arrowHalfWidth = ArrowedConstants.arrowWidth / 2
        
        let arrowCenterX: CGFloat
        do {
            let targetViewCenter = CGPoint(x: targetView.bounds.midX,
                                           y: targetView.bounds.midY) // центр targetView в её собственной системе координат
            let targetConvertedCenter = targetView.convert(targetViewCenter, to: self)
            
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
        
        let arrowOriginX = arrowCenterX - arrowHalfWidth
        return arrowOriginX
    }
    
    private func getArrowOriginY(forPlacement placement: MBArrowedViewPlacement) -> CGFloat {
        let arrowOriginY: CGFloat
        switch placement {
        case .top: arrowOriginY = 0
        case .bottom :arrowOriginY = bounds.height - ArrowedConstants.arrowHeight
        case .hidden: arrowOriginY = 0
        }
        return arrowOriginY
    }
    
    private func getArrowPlacement(relativeTo targetView: UIView) -> MBArrowedViewPlacement {
        // Положение в координатном пространстве UIWindow
        let selfGlobalOrigin = self.convert(self.center, to: nil)
        let targetViewGlobalOrigin = targetView.convert(targetView.center, to: nil)
        
        let arrowPlacement: MBArrowedViewPlacement = selfGlobalOrigin.y < targetViewGlobalOrigin.y ? .bottom : .top
        return arrowPlacement
    }
}

extension MBArrowContainerView {
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
        backgroundColor = nil
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

extension MBArrowContainerView {
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
    
    static let animationDuration: Double = 2.15
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
