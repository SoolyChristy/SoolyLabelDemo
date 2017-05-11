//
//  SoolyLabel.swift
//  SoolyLabelDemo
//
//  Created by SoolyChristina on 2017/4/29.
//  Copyright © 2017年 SoolyChristina. All rights reserved.
//  使用TextKit接管UILabel

import UIKit

protocol SoolyLabelDelegate: NSObjectProtocol {
    func labelDidSelectedLink(text: String)
    func labelDidSelectedTopic(text: String)
    func labelDidSelectedAt(text: String)
}

class SoolyLabel: UILabel {
    
    weak var delegate: SoolyLabelDelegate?
    
    // MARK: 重写属性
    override var text: String? {
        didSet {
            prepareText()
        }
    }
    
    override var attributedText: NSAttributedString? {
        didSet {
            prepareText()
        }
    }
    
    override var font: UIFont! {
        didSet {
            prepareText()
        }
    }
    
    override var textColor: UIColor! {
        didSet {
            prepareText()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareTextSystem()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        prepareTextSystem()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 指定文本绘制区域
        textContainer.size = bounds.size
    }
    
    // 绘制textStorage的文本内容
    override func drawText(in rect: CGRect) {
        
        // 绘制背景
        let range = NSRange(location: 0, length: textStorage.length)
        layoutManager.drawBackground(forGlyphRange: range, at: CGPoint(x: 0, y: 0))
        
        // 绘制字形
        layoutManager.drawGlyphs(forGlyphRange: range, at: CGPoint(x: -5, y: 0))
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    // MARK: 点击文本
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else {
            return
        }
        
        // 获取点击了第几个字符
        let index = layoutManager.glyphIndex(for: location, in: textContainer)
        
        // 判断index是否在 range里
        for range in urlRanges ?? [] {
            if NSLocationInRange(index, range) {
                let str = (textStorage.string as NSString).substring(with: range)
                delegate?.labelDidSelectedLink(text: str)
                return
            }
        }
        
        for range in topicRanges ?? [] {
            if NSLocationInRange(index, range) {
                let str = (textStorage.string as NSString).substring(with: range)
                delegate?.labelDidSelectedTopic(text: str)
                return
            }
        }
        
        for range in atRanges ?? [] {
            if NSLocationInRange(index, range) {
                let str = (textStorage.string as NSString).substring(with: range)
                delegate?.labelDidSelectedAt(text: str)
                return
            }
        }
    }
    
    // MARK: TextKit核心对象
    /// NSAttributedString 子类 设置文本统一使用
    fileprivate lazy var textStorage = NSTextStorage()
    /// 布局管理器 负责 字形 布局
    fileprivate lazy var layoutManager = NSLayoutManager()
    /// 绘制区域
    fileprivate lazy var textContainer = NSTextContainer()

}

// MARK: 交互
extension SoolyLabel {

}

// MARK: 设置TextKit
extension SoolyLabel {
    
    /// 准备文本系统
    fileprivate func prepareTextSystem() {
        
        adjustsFontSizeToFitWidth = true
        
        // 打开交互
        isUserInteractionEnabled = true
        
        // 准备文本内容
        prepareText()
        
        // 设置对象的关系
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
    }
    
    /// 准备文本内容 - 使用TextStorage 接管 label内容
    fileprivate func prepareText() {
        if let attributedText = attributedText {
            textStorage.setAttributedString(attributedText)
        }else if let text = text {
            textStorage.setAttributedString(NSAttributedString(string: text))
        }else {
            textStorage.setAttributedString(NSAttributedString(string: ""))
            return
        }
        
        // 设置Text属性
        setupTextAttributes()
        
    }
    
}

// MARK: 设置TextStorage text的属性 (设置显示)
extension SoolyLabel {
    fileprivate func setupTextAttributes() {
        
        textStorage.addAttributes([NSFontAttributeName: font,
                                   NSForegroundColorAttributeName: textColor],
                                  range: NSRange(location: 0, length: textStorage.length))
        
        for range in urlRanges ?? [] {
            textStorage.addAttributes([NSForegroundColorAttributeName: UIColor.blue], range: range)
        }
        
        for range in topicRanges ?? [] {
            textStorage.addAttributes([NSForegroundColorAttributeName: UIColor.blue], range: range)
        }
        
        for range in atRanges ?? [] {
            textStorage.addAttributes([NSForegroundColorAttributeName: UIColor.blue], range: range)
        }
    }
    
}

// MARK: 正则表达式
extension SoolyLabel {
    /// 链接
    var urlRanges: [NSRange]? {
        let pattern = "\\b(([\\w-]+://?|www[.])[^\\s()<>]+(?:\\([\\w\\d]+\\)|([^[:punct:]\\s]|/)))"
        
        return findRanges(pattern: pattern)
    }
    
    /// 话题
    var topicRanges: [NSRange]? {
        let pattern = "#[^#]+#"
        
        return findRanges(pattern: pattern)
    }
    
    /// @用户
    var atRanges: [NSRange]? {
        let pattern = "@[\\u4e00-\\u9fa5a-zA-Z0-9_-]{2,30}"
        
        return findRanges(pattern: pattern)
    }
    
    /// 根据正则表达式在textStorage中寻找对应的range
    ///
    /// - Parameter pattern: 正则表达式
    /// - Returns: 对应NSRange数组
    private func findRanges(pattern: String) -> [NSRange]? {
        guard let regx = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }
        
        let matches = regx.matches(in: textStorage.string, options: [], range: NSRange(location: 0, length: textStorage.length))
        
        var ranges = [NSRange]()
        for match in matches {
            ranges.append(match.rangeAt(0))
        }
        
        return ranges
    }
}
