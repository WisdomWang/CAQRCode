//
//  ViewController.swift
//  CAQRCode
//
//  Created by Cary on 2018/8/14.
//  Copyright © 2018年 Cary. All rights reserved.
//

import UIKit
import AVFoundation

let xScreenWidth = UIScreen.main.bounds.size.width
let xScreenHeight = UIScreen.main.bounds.size.height

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupView()
    }

    func setupView() {
        
        title = "关于二维码"
        
        let scanBtn = UIButton(frame: CGRect(x: xScreenWidth/2-50, y: 300, width: 100, height: 30))
        scanBtn.setTitle("扫描二维码", for:.normal)
        scanBtn.setTitleColor(UIColor.blue, for: .normal)
        scanBtn.addTarget(self, action: #selector(btnSlected), for: .touchUpInside)
        view.addSubview(scanBtn)
        
        let buildBtn = UIButton(frame: CGRect(x: xScreenWidth/2-50, y: 400, width: 100, height: 30))
        buildBtn.setTitle("生成二维码", for:.normal)
        buildBtn.setTitleColor(UIColor.blue, for: .normal)
        buildBtn.addTarget(self, action: #selector(buildBtnClick), for: .touchUpInside)
        view.addSubview(buildBtn)
    }
    
    @objc func btnSlected() {
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let alert = UIAlertController(title: "提示", message: "您的设备没有摄像头或者相关的驱动, 不能进行该操作！", preferredStyle: .alert)
            let action = UIAlertAction(title: "好的", style: .cancel) { (alert) in
                
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .restricted || status == .denied {
            
            let alert = UIAlertController(title: "请授权相机权限", message: "请在iPhone的\"设置-隐私-相机\"选项中,允许访问您的相机", preferredStyle: .alert)
            let action = UIAlertAction(title: "好的", style: .cancel) { (alert) in
                
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
            
        } else {
            
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            let scan = storyBoard.instantiateViewController(withIdentifier: String.init(describing: ScanVC.self))
            navigationController?.pushViewController(scan, animated: true)
        }
        
    }
    
    @objc func buildBtnClick () {
        
        let vc = BuildQRCodeVC()
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

