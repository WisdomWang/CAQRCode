//
//  ViewController.swift
//  CAQRCode
//
//  Created by Cary on 2018/8/14.
//  Copyright © 2018年 Cary. All rights reserved.
//

import UIKit

let xScreenWidth = UIScreen.main.bounds.size.width
let xScreenHeight = UIScreen.main.bounds.size.height

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupView()
    }

    func setupView() {
        
        title = "二维码"
        let btn = UIButton(frame: CGRect(x: xScreenWidth/2-50, y: 300, width: 100, height: 30))
        btn.setTitle("扫描二维码", for:.normal)
        btn.setTitleColor(UIColor.blue, for: .normal)
        btn.addTarget(self, action: #selector(btnSlected), for: .touchUpInside)
        view.addSubview(btn)
        
    }
    
    @objc func btnSlected() {
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let alert = UIAlertController(title: "提示", message: "您的设备没有摄像头或者相关的驱动, 不能进行该操作！", preferredStyle: .alert)
            let action = UIAlertAction(title: "知道了", style: .cancel) { (alert) in
                
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return;
        }
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let scan = storyBoard.instantiateViewController(withIdentifier: String.init(describing: ScanVC.self))
        navigationController?.pushViewController(scan, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

