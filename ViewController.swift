//
//  ViewController.swift
//  SoolyLabelDemo
//
//  Created by SoolyChristina on 2017/5/11.
//  Copyright © 2017年 SoolyChristina. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textLabel: SoolyLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = SoolyLabel(frame: CGRect(x: 0, y: 200, width: 300, height: 21))
        label.text = "Swift#iOS# 测试 http://www.sina.com"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.gray
        
        view.addSubview(label)
        
        label.delegate = self
        textLabel.delegate = self
        
    }
}

extension ViewController: SoolyLabelDelegate {
    func labelDidSelectedAt(text: String) {
        print("点击了\(text)用户")
    }
    
    func labelDidSelectedLink(text: String) {
        print("点击了\(text)链接")
    }
    
    func labelDidSelectedTopic(text: String) {
        print("点击了\(text)话题")
    }
}

