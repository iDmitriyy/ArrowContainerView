//
//  ArrowedView.swift
//  RoundedTringle
//
//  Created by Dmitriy Ignatyev on 18/02/2019.
//  Copyright © 2019 Dmitriy Ignatyev. All rights reserved.
//

import UIKit


public extension UIView {
    
    /// Привязывает 4 стороны к superView
    public func addStretchedToBounds(subview: UIView, insets: UIEdgeInsets? = nil) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        
        let constants = (insets ?? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        let constraints: [NSLayoutConstraint] = [
            subview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: constants.left),
            subview.topAnchor.constraint(equalTo: self.topAnchor, constant: constants.top),
            self.trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: constants.right),
            self.bottomAnchor.constraint(equalTo: subview.bottomAnchor, constant: constants.bottom)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}

@IBDesignable public final class MBRightIconButton: UIButton {
    
    /// Величина отступа справа для иконки
    var trailingConstant: CGFloat = 16 {
        didSet { updateImageInsets() }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        updateImageInsets()
    }
    
    private func updateImageInsets() {
        if let imageFrame = imageView?.bounds {
            semanticContentAttribute = .forceRightToLeft
            
            let labelWidth = titleLabel?.bounds.width ?? 0
            let delta = bounds.width - labelWidth - trailingConstant - imageFrame.width
            
            imageEdgeInsets = UIEdgeInsets(top: 0, left: delta, bottom: 0, right: 0)
        }
    }
}

class MultilineButton: UIButton {
    // https://stackoverflow.com/questions/23845982/multiline-uibutton-and-autolayout
    func setup() {
        self.titleLabel?.numberOfLines = 0
        self.setContentHuggingPriority(UILayoutPriority.defaultLow + 1, for: .vertical)
        self.setContentHuggingPriority(UILayoutPriority.defaultLow + 1, for: .horizontal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override var intrinsicContentSize: CGSize {
        // let superSize = super.intrinsicContentSize
        
        let defaultHeightAppendix: CGFloat = 12
        
        let labelSize = self.titleLabel!.intrinsicContentSize
        
        let intrinsicSize = CGSize(width: labelSize.width + contentEdgeInsets.left + contentEdgeInsets.right,
                                   height: labelSize.height + contentEdgeInsets.top + contentEdgeInsets.bottom + defaultHeightAppendix)
        return intrinsicSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.preferredMaxLayoutWidth = self.titleLabel!.frame.size.width
    }
}

///// Кнопка с иконкой справа и текстом слева. Кнопка поддерживает multiline Text и изменяет свой размер
///// Размер кнопки по высоте равен размеру titleLabel
//@IBDesignable public final class MBLabeledRightIconButton: UIButton {
//
//    /// Величина отступа справа для иконки
//    var imageTrailingConstant: CGFloat = 16 {
//        didSet { updateImageInsets() }
//    }
//
//    // MARK: Overriden
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        initialSetup()
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        initialSetup()
//    }
//
//    public override var intrinsicContentSize: CGSize {
//        /* defaultHeightAppendix - добавочная величина полученная опытным путем.
//         По умолчанию высота самой кнопки 34, а высота titleLabel 21.5
//         т.к intrinsicContentSize переопределён и возвращает размер titleLabel, то нужно добавить высоту
//         Цифра 12 корректна для шрифта размером 18.
//         */
//        // let defaultHeightAppendix: CGFloat = 12
//        let labelSize = self.titleLabel!.intrinsicContentSize
//
//        let intrinsicSize = CGSize(width: labelSize.width + contentEdgeInsets.left + contentEdgeInsets.right,
//                                   height: labelSize.height + contentEdgeInsets.top + contentEdgeInsets.bottom)
//        return intrinsicSize
//    }
//
//    public override func layoutSubviews() {
//        super.layoutSubviews()
//
//        updateImageInsets()
//
//        if let titleLabel = titleLabel {
//            titleLabel.preferredMaxLayoutWidth = titleLabel.frame.size.width
//        }
//
//    }
//
//    // MARK: Private
//    private func updateImageInsets() {
//        if let imageFrame = imageView?.bounds {
//
//
//            let labelWidth = titleLabel?.bounds.width ?? 0
//            let delta = bounds.width - labelWidth - imageTrailingConstant - imageFrame.width
//
//            imageEdgeInsets = UIEdgeInsets(top: 0, left: delta, bottom: 0, right: 0)
//        }
//    }
//
//    private func initialSetup() {
//
//        do { // Для работы multiline
//            titleLabel?.numberOfLines = 0
//            setContentHuggingPriority(UILayoutPriority.defaultLow + 1, for: .vertical)
//            setContentHuggingPriority(UILayoutPriority.defaultLow + 1, for: .horizontal)
//        }
//
//        do { // Для отображения картинки справа
//            semanticContentAttribute = .forceRightToLeft
//            contentHorizontalAlignment = .left
//        }
//    }
//}

/**
 Размер кнопки по высоте равен размеру titleLabel
 Реализация кнопки довольно витиевата, поэтому неследование от этого класса кажется сомнительным
 По этой прчине класс сделан final
 */
@IBDesignable public final class MBLabeledRightIconButton: UIButton {
    // https://medium.com/@harmittaa/uibutton-with-label-text-and-right-aligned-image-a9d0f590bba1
    // https://stackoverflow.com/questions/23845982/multiline-uibutton-and-autolayout
    
    /// Величина отступа справа для иконки
    public var imageTrailingConstant: CGFloat = 16 {
        didSet { updateImageInsets() }
    }
    
    // MARK: Overriden
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    /// Метод переопределён для autoSize'инга кнопки
    public override var intrinsicContentSize: CGSize {
        let labelSize = self.titleLabel!.intrinsicContentSize
        
        let intrinsicSize = CGSize(width: labelSize.width + contentEdgeInsets.left + contentEdgeInsets.right,
                                   height: labelSize.height + contentEdgeInsets.top + contentEdgeInsets.bottom)
        return intrinsicSize
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if let titleLabel = titleLabel {
            // Для работы multiline
            titleLabel.preferredMaxLayoutWidth = titleLabel.frame.size.width
        }
        
        updateImageInsets()
    }
    
    // MARK: - Private
    
    /// Метод устанавливает положение imageView
    private func updateImageInsets() {
        // Из-за добавления multiline положение imageView нужно высчитывать по разному
        if let imageBounds = imageView?.bounds {
            let spacingBetweenLabelAndImage: CGFloat = 4
            
            let requiredImageSpace = imageTrailingConstant + imageBounds.width + spacingBetweenLabelAndImage
            
            let labelFrame = titleLabel?.frame ?? CGRect.zero
            let labelOccupiedSpace = labelFrame.width + labelFrame.origin.x
            
            let freeSpaceForImage = bounds.width - labelOccupiedSpace
            
            if freeSpaceForImage < requiredImageSpace {
                titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: requiredImageSpace)
                // если задвать значение titleEdgeInsets в обоих ветвлениях if'а то будет рекурсия
                
            } else {
                let leftInset = freeSpaceForImage - requiredImageSpace
                let rightInset = imageTrailingConstant
                
                imageEdgeInsets = UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
            }
        }
    }
    
    private func initialSetup() {
        do { // Для работы multiline
            titleLabel?.numberOfLines = 0
            setContentHuggingPriority(UILayoutPriority.defaultLow + 1, for: .vertical)
            setContentHuggingPriority(UILayoutPriority.defaultLow + 1, for: .horizontal)
        }
        
        do { // Для отображения картинки справа
            semanticContentAttribute = .forceRightToLeft
            contentHorizontalAlignment = .left
        }
        
        clipsToBounds = false /* т.к высота кнопки  определяется текстом, то картинка может быть больше по высоте чем
         сама кнопка, поэтому ставим false */
    }
}

// На Constraint'ах
final class LabeledIconButton: UIButton {
    // MARK: Overriden
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    private func initialSetup() {
        
    }
}
