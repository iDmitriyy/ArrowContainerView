//
//  ArrowContainerView.swift
//  ArrowContainerView
//
//  Created by Dmitriy Ignatyev on 19/02/2019.
//  Copyright © 2019 Dmitriy Ignatyev. All rights reserved.
//

import UIKit

/**
 При попытке анимации constraint'ов targetView анимация у нее по факту не происходит
 Ограничения:
 - картинка стрелки должна быть задана на этапе инициализации
 - используемая view должна иметь такой layout, чтоб autoLayout мог высчитать её высоту
 TODO: сделать переопределние картинки и её размеров
 */
open class ArrowContainerView<T: UIView>: UIView {
    /// This is content view
    public let view: T
    private let contentContainer = UIView()
    
    open var contentViewInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 3, bottom: 1, right: 3)
    }
    
    // Private Properties
    private var arrowView = UIView()
    //private var arrowParams = ArrowParams()
    
    private weak var containerTopConstraint: NSLayoutConstraint?
    private weak var containertBottomConstraint: NSLayoutConstraint?
    
    /// Do not call super when overriding this method
    open class func makeViewInstanse() -> T {
        return T()
    }
    
    // MARK: - Initializers
    public required init?(coder aDecoder: NSCoder) {
        view = type(of: self).makeViewInstanse()
        super.init(coder: aDecoder)
        initialSetup()
    }
    public override init(frame: CGRect) {
        view = type(of: self).makeViewInstanse()
        super.init(frame: frame)
        initialSetup()
    }
    
    /// Для случаев, когда в конструктор View нужно передать параметры. Например UIButton(type: .custom)
    init(contentView: T) {
        view = contentView
        super.init(frame: .zero)
        initialSetup()
    }
    
    // MARK: - Overriden
    ///
    open override var backgroundColor: UIColor? {
        didSet {
            let color = backgroundColor ?? .darkGray
            super.backgroundColor = nil
            
            arrowView.tintColor = color
            arrowView.backgroundColor = .blue // FIXME: backgroundColor
            view.backgroundColor = color // FIXME: backgroundColor
            contentContainer.backgroundColor = .orange
            // сделать метод обновления цвета
        }
    }
    
    private var arrowParams = ArrowParams()
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let currentPlacement = arrowParams.placement
        
        let arrowFrame: CGRect
        switch arrowParams.anchor {
        case .toOffset(let xOffset):
            arrowFrame = getArrowFrameFor(xOffsetAnchor: xOffset, placement: currentPlacement)
        case .toSelfWidth(let ratio):
            arrowFrame = getArrowFrameFor(ratioAnchor: ratio, placement: currentPlacement)
        case .toXCenterOf(let box):
            if let targetView = box.targetView, targetView.superview != nil, targetView !== self {
                targetView.layoutIfNeeded() // Обновляем размер targetView и получаем placement
                let placement = getArrowPlacement(relativeTo: targetView)
                
                arrowFrame = getArrowFrameFor(targetViewAnchor: targetView, placement: placement)
                arrowParams.placement = placement
            } else {
                arrowFrame = arrowView.frame // оставляем тоже самое
                arrowParams.placement = .hidden
            }
        }
        
        if currentPlacement == arrowParams.previousPlacement {
            /* В этом ветвлении метод updateConstraintsFor(arrowPlacement:) не вызывается, так как:
             1. это приведет к рекурсии layoutSubviews(). Указанный метод вызывается в других ветвлениях
             2. при входе в это ветвление гарантировано, что указанный метод был ранее вызыван
             в setArrowCenteredTo(targetView:) */
            //if arrowFrame != arrowView.frame, currentPlacement != .hidden {
                UIView.animate(withDuration: ArrowConstants.animationDuration) {
                    self.arrowView.frame = arrowFrame
                    type(of: self).rotateArrow(self.arrowView, for: currentPlacement)
                }
            //}
        } else {
            /* Попадание в первое ветвление может произойти в 2-х сценариях: либо сразу, либо после входа в это
             ветвление и вызова метода updateConstraintValuesFor().
             Если у нас второй сценрий и мы анимруем constraint'ы то получается следующая ситуация: после изменения
             constraint'ов начинается анимация, мы попадаем в первое ветвление и изменения производимые методом
             align() тоже анимируются. */
            if currentPlacement == .hidden {
                makeArrowVisible(false)
                updateConstraintsFor(arrowPlacement: arrowParams.placement, animated: true) // ! анимация по факту не работает
            } else {
                arrowParams.placement = currentPlacement /* присваиваем значение, это вызовет didSet и
                 arrowParams.previousPlacement станет равен currentPlacement. Это нужно чтоб в следующем
                 цикле отрисовки попасть в первое ветвление */
                updateConstraintsFor(arrowPlacement: currentPlacement, animated: true)
            }
        }
    }
    
    //    open override func layoutSubviews() {
    //        super.layoutSubviews()
    //
    //        if let targetView = arrowParams.targetView, targetView.superview != nil {
    //            targetView.layoutIfNeeded()
    //            let placement = getArrowPlacement(relativeTo: targetView)
    //
    //            makeArrowVisible(true)
    //
    //            if placement == arrowParams.placement {
    //                /* В этом ветвлении метод updateConstraintsFor(arrowPlacement:) не вызывается, так как:
    //                 1. это приведет к рекурсии layoutSubviews(). Указанный метод вызывается в других ветвлениях
    //                 2. при входе в это ветвление гарантировано, что указанный метод был ранее вызыван в setArrowCenteredTo(targetView:) */
    //
    //                UIView.animate(withDuration: ArrowConstants.animationDuration) {
    //                    self.align(arrow: self.arrowView, toHorizontalCenterOf: targetView, placement: placement)
    //                }
    //            } else {
    //                arrowParams.placement = placement
    //                updateConstraintsFor(arrowPlacement: placement, animated: true)
    //                /* Попадание в первое ветвление может произойти в 2-х сценариях: либо сразу, либо после входа в это
    //                 ветвление и вызова метода updateConstraintValuesFor().
    //                 Если у нас второй сценрий и мы анимруем constraint'ы то получается следующая ситуация: после изменения
    //                 constraint'ов начинается анимация, мы попадаем в первое ветвление и изменения производимые методом
    //                 align() тоже анимируются. */
    //            }
    //        } else {
    //            let placement: MBArrowedViewPlacement = .hidden
    //
    //            if arrowParams.placement != placement { // делаем проверку чтоб не прятать повторно
    //                arrowParams.placement = placement
    //                makeArrowVisible(false)
    //                updateConstraintsFor(arrowPlacement: placement, animated: true) // ! анимация по факту не работает
    //            }
    //        }
    //    }
    
    public final func setArrowCenteredTo(anchor: ArrowViewXAnchor) {
        
        switch anchor {
        case let .toOffset(xOffset, placement):
            arrowParams.placement = placement
            arrowParams.anchor = .toOffset(xOffset: xOffset)
        case let .toSelfWidth(ratio, placement):
            arrowParams.placement = placement
            arrowParams.anchor = .toSelfWidth(ratio: ratio)
        case let .toXCenterOf(targetView):
            arrowParams.anchor = .toXCenterOf(TargetViewBox(targetView: targetView))
            // arrowParams.placement в этом случае не задается, т.к будет автоматически посчитан в layoutSubviews()
        }
        
        makeArrowVisible(true)
        setNeedsLayout()
    }
    
    public final func hideArrow() {
        arrowParams.anchor = .toXCenterOf(TargetViewBox(targetView: nil))
        setNeedsLayout()
    }
    
    /** Метод для обновления положения стрелки, если targetView меняет размер или положение.
     Пример: изменение текста в UILabel */
    public final func updateArrowPosition() {
        setNeedsLayout() // Чтоб в следующем проходе laoyout'a вызывался layoutSubViews(), где происходит позиционирование
    }
}

extension ArrowContainerView {
    // MARK: - Arrow Appearance
    private func makeArrowVisible(_ visible: Bool) {
        /* Возможен кейс, когда вызов метода layoutSubviews() спровоцирован работой UIView.animateWithDuration.
         В этом случае вызов UIView.Transition для анимации проперти '.isHidden' приводит к артефактам отрисовки.
         По этой причине стрелка прячется и показывается без анимации */
        arrowView.isHidden = !visible
    }
    
    /// Вращает стрелку на 180 градусов чтоб она смотрела вверх либо вниз в зависимости от параметра placement
    private static func rotateArrow(_ arrow: UIView, for placement: ArrowViewPlacement) {
        // Предполагается, что на используемой в качестве стрелки картинке стрелка смотрит вниз
        let scaleY: CGFloat
        switch placement {
        case .top: scaleY = -1
        case .bottom: scaleY = 1
        case .hidden: scaleY = 1
        }
        
        arrow.transform = CGAffineTransform(scaleX: 1, y: scaleY)
    }
}

extension ArrowContainerView {
    // MARK: - Update Container Constraints
    
    /** Обновляет constraint'ы у contentContainer'а, тем самым двигая его вверх или вниз для освобождения свободного
     пространства для отображения стрелки */
    private func updateConstraintsFor(arrowPlacement: ArrowViewPlacement, animated: Bool) {
        if animated {
            UIView.animate(withDuration: ArrowConstants.animationDuration) {
                self.updateConstraintValuesFor(arrowPlacement: arrowPlacement)
                self.layoutIfNeeded()
            }
        } else {
            updateConstraintValuesFor(arrowPlacement: arrowPlacement)
        }
    }
    
    /**
     Constraints update implementation.
     This method indirectly call setNeedsLayout() because of changing constraints values, which leads
     to calling layoutSubviews() on next view update cycle */
    private func updateConstraintValuesFor(arrowPlacement: ArrowViewPlacement) {
        let top: CGFloat
        let bottom: CGFloat
        
        switch arrowPlacement {
        case .top:
            top = ArrowConstants.arrowHeight
            bottom = 0
        case .bottom:
            top = 0
            bottom = ArrowConstants.arrowHeight
        case .hidden:
            top = 0
            bottom = 0
        }
        
        containerTopConstraint?.constant = top
        containertBottomConstraint?.constant = bottom
    }
}

extension ArrowContainerView {
    // MARK: - Arrow Aligment: Top level methods
    
    // MARK: For offset anchor
    private func getArrowFrameFor(xOffsetAnchor xOffset: CGFloat, placement: ArrowViewPlacement) -> CGRect {
        let possibleArrowCenterX = xOffset
        let adjustedOriginX = adjustedArrowOriginXFor(possibleArrowCenterX: possibleArrowCenterX)
        return arrowFrameFor(adjustedOriginX: adjustedOriginX, placement: placement)
    }
    
    // MARK: For ratio anchor
    private func getArrowFrameFor(ratioAnchor ratio: CGFloat, placement: ArrowViewPlacement) -> CGRect {
        let possibleArrowCenterX = bounds.width * ratio
        let adjustedOriginX = adjustedArrowOriginXFor(possibleArrowCenterX: possibleArrowCenterX)
        return arrowFrameFor(adjustedOriginX: adjustedOriginX, placement: placement)
    }
    
    // MARK: For targetView anchor
    private func getArrowFrameFor(targetViewAnchor targetView: UIView, placement: ArrowViewPlacement) -> CGRect {
        let adjustedOriginX = getAdjustedArrowOriginX(forTargetView: targetView)
        return arrowFrameFor(adjustedOriginX: adjustedOriginX, placement: placement)
    }
    
    private func getAdjustedArrowOriginX(forTargetView targetView: UIView) -> CGFloat {
        let targetViewCenter = CGPoint(x: targetView.bounds.midX,
                                       y: targetView.bounds.midY) // центр targetView в её собственной системе координат
        
        let targetConvertedCenter = targetView.convert(targetViewCenter, to: self)
        let possibleArrowCenterX = targetConvertedCenter.x
        
        return adjustedArrowOriginXFor(possibleArrowCenterX: possibleArrowCenterX)
    }
    
    /// Always returns .bottom or .top, never .hidden
    private func getArrowPlacement(relativeTo targetView: UIView) -> ArrowViewPlacement {
        // Положение в координатном пространстве UIWindow
        let selfGlobalOrigin = self.convert(self.center, to: nil)
        let targetViewGlobalOrigin = targetView.convert(targetView.center, to: nil)
        
        let arrowPlacement: ArrowViewPlacement = selfGlobalOrigin.y < targetViewGlobalOrigin.y ? .bottom : .top
        return arrowPlacement
    }
}

extension ArrowContainerView {
    // MARK: - Arrow Aligment: Common methods (used by top level methods)
    
    private func arrowFrameFor(adjustedOriginX: CGFloat, placement: ArrowViewPlacement) -> CGRect {
        let originY = getArrowOriginY(forPlacement: placement)
        return CGRect(x: adjustedOriginX,
                      y: originY,
                      width: ArrowConstants.arrowWidth,
                      height: ArrowConstants.arrowHeight)
    }
    
    private func getArrowOriginY(forPlacement placement: ArrowViewPlacement) -> CGFloat {
        let arrowOriginY: CGFloat
        switch placement {
        case .top: arrowOriginY = 0
        case .bottom :arrowOriginY = bounds.height - ArrowConstants.arrowHeight
        case .hidden: arrowOriginY = 0
        }
        return arrowOriginY
    }
    
    /** Скорректированное таким образом пложение (origin.x) стрелки по оси x, чтобы она не уехала за границы справа / слева
     Входной параметр: точка по оси x, на которую должен ровняться центр стрелки */
    private func adjustedArrowOriginXFor(possibleArrowCenterX: CGFloat) -> CGFloat {
        let selfWidth = bounds.width
        let arrowHalfWidth = ArrowConstants.arrowWidth / 2
        
        let arrowCenterX: CGFloat
        // Стрелка должна быть видна полнстью. Проверяем possibleArrowCenterX и корректируем при необходимости:
        if possibleArrowCenterX + arrowHalfWidth > selfWidth {
            arrowCenterX = selfWidth - arrowHalfWidth // Не позволяем уехать за границы справа
        } else if possibleArrowCenterX - arrowHalfWidth < 0 {
            arrowCenterX = 0 + arrowHalfWidth // Не позволяем уехать за границы слева
        } else {
            arrowCenterX = possibleArrowCenterX
        }
        
        let arrowOriginX = arrowCenterX - arrowHalfWidth
        return arrowOriginX
    }
}

extension ArrowContainerView {
    // MARK: - Initial Configuration
    
    private func initialSetup() {
        installViews()
        setupInitialAppearance()
    }
    
    // MARK: Views Installing
    private func installViews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        installContainerView()
        installContentView()
        
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(arrowView)
        sendSubviewToBack(arrowView)
    }
    
    private func installContainerView() {
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        let superView: UIView = self
        superView.addSubview(contentContainer)
        
        let top = contentContainer.topAnchor.constraint(equalTo: superView.topAnchor)
        let bottom = superView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
        
        self.containerTopConstraint = top
        self.containertBottomConstraint = bottom
        
        NSLayoutConstraint.activate([
            top,
            bottom,
            contentContainer.leadingAnchor.constraint(equalTo: superView.leadingAnchor),
            superView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor)])
    }
    
    private func installContentView() {
        view.translatesAutoresizingMaskIntoConstraints = false
        let superView: UIView = contentContainer
        superView.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: contentViewInsets.left),
            superView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: contentViewInsets.right),
            view.topAnchor.constraint(equalTo: superView.topAnchor, constant: contentViewInsets.top),
            superView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: contentViewInsets.bottom)])
        
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true // FIXME: delete
    }
    
    // MARK: Setup initial appearance
    private func setupInitialAppearance() {
        backgroundColor = nil
        setupArrowInitialApperanace()
    }
    
    private func setupArrowInitialApperanace() {
        let frame = CGRect(x: 0, y: 0, width: ArrowConstants.arrowWidth, height: ArrowConstants.arrowHeight)
        let bezierPath = type(of: self).getArrowBezierPath()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = frame
        shapeLayer.path = bezierPath.cgPath
        
        arrowView.frame = frame
        arrowView.layer.mask = shapeLayer
        arrowView.clipsToBounds = true
        
        makeArrowVisible(false)
    }
}

extension ArrowContainerView {
    // MARK: - Arrow Path
    
    /** Изаображение для стрелки. В исходном изображении стрелка должна смотреть вниз.
     Если картинка будет меняться, то нужно поменять значения arrowWidth и arrowHeight в ArrowedConstants*/
    private static func getArrowBezierPath() -> UIBezierPath {
        let arrowPath = UIBezierPath()
        
        arrowPath.move(to: CGPoint(x: 0, y: 0))
        arrowPath.addCurve(to: CGPoint(x: 9, y: 3), controlPoint1: CGPoint(x: 0, y: 0), controlPoint2: CGPoint(x: 5, y: 0))
        arrowPath.addCurve(to: CGPoint(x: 16, y: 8), controlPoint1: CGPoint(x: 13, y: 6), controlPoint2: CGPoint(x: 13, y: 8))
        arrowPath.addCurve(to: CGPoint(x: 23, y: 3), controlPoint1: CGPoint(x: 19, y: 8), controlPoint2: CGPoint(x: 19, y: 6))
        arrowPath.addCurve(to: CGPoint(x: 34, y: 0), controlPoint1: CGPoint(x: 27, y: 0), controlPoint2: CGPoint(x: 34, y: 0))
        arrowPath.addLine(to: CGPoint(x: 0, y: 0))
        
        arrowPath.close()
        arrowPath.fill()
        return arrowPath
    }
}

// MARK: - Nested Structs
private enum ArrowConstants {
    static let arrowWidth: CGFloat = 34
    static let arrowHeight: CGFloat = 8
    
    static let animationDuration: Double = 0.15
}

/// Расположение стрелки
public enum ArrowViewPlacement {
    case top
    case bottom
    case hidden
}

public enum ArrowViewXAnchor {
    /** Указывает смещение в пикселях от левого края. На эту точку будет смотерть стрелка.
     Подходит, например, когда стрелка должна указывать на barButton */
    case toOffset(xOffset: CGFloat, placement: ArrowViewPlacement)
    
    /** fraction - это пропорция от собственной ширины, на которую будет ровняться стрелка.
     Например 1/2 - это середина. Дипазон значений от 0 до 1.
     Подходит для случаев, когда есть несколько заранее известных положений стрелки */
    case toSelfWidth(ratio: CGFloat, placement: ArrowViewPlacement)
    
    /** Указывается view, на центр которой по оси x будет ровняться стрелка.
     Параметр placement будет высчитан автоматически */
    case toXCenterOf(targetView: UIView)
}

/// For internal usage inside ArrowContainerView
private enum ArrowViewPrivateAnchor {
    case toOffset(xOffset: CGFloat)
    case toSelfWidth(ratio: CGFloat)
    case toXCenterOf(TargetViewBox)
}

private final class TargetViewBox {
    private(set) weak var targetView: UIView?
    
    init(targetView: UIView?) {
        self.targetView = targetView
    }
}

private struct ArrowParams {
    // FIXME: may be make immutable
    private(set) var previousPlacement: ArrowViewPlacement = .hidden
    var placement: ArrowViewPlacement = .hidden {
        didSet {
            previousPlacement = oldValue
        }
    }
    var anchor: ArrowViewPrivateAnchor = .toXCenterOf(TargetViewBox(targetView: nil))
}
