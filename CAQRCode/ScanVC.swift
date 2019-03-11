//
//  ScanVC.swift
//  CAQRCode
//
//  Created by Cary on 2018/8/14.
//  Copyright © 2018年 Cary. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ScanVC: UIViewController,AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    //创建一个摄像头画面捕获类
    var session:AVCaptureSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        judgeCameraPermission()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if session != nil {
            initScanView()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        session?.stopRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session?.startRunning()
    }

    func judgeCameraPermission() {
        //拒绝，受限制
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .restricted || status == .denied {
            print("没有权限使用！")
        }else if status == .notDetermined {
         
            AVCaptureDevice.requestAccess(for: .video) { (allow) in
                if allow {
                    print("同意了")
                    self.initSession()
                }
                else {
                    print("拒绝了")
                }
            }
        }else {
            initSession()
        }
    }
    
    func setupView() {
        title = "扫描二维码"
        view.backgroundColor = UIColor.black
        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        rightButton.setTitle("相册", for: .normal)
        rightButton.setTitleColor(UIColor.black, for: .normal)
        rightButton.addTarget(self, action: #selector(gotoPhoto), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        view.addSubview(MaskView(frame: UIScreen.main.bounds))
        let lightButton = UIButton(frame: CGRect(x: 0.5 * (xScreenWidth - 30), y: 0.8 * xScreenHeight, width: 30, height: 30))
        lightButton.setBackgroundImage(UIImage(named: "SGQRCodeFlashlightOpenImage"), for: .normal)
        lightButton.setBackgroundImage(UIImage(named: "SGQRCodeFlashlightCloseImage"), for: .selected)
        lightButton.addTarget(self, action: #selector(lightButtonClick(button:)), for: .touchUpInside)
        view.addSubview(lightButton)
    }
    
    func initScanView() {
        //用session生成一个AVCaptureVideoPreviewLayer添加到view的layer上，就会实时显示摄像头捕捉的内容
        let layer = AVCaptureVideoPreviewLayer(session: session!)
        layer.videoGravity = .resizeAspectFill
        layer.frame = UIScreen.main.bounds
        view.layer.insertSublayer(layer, at: 0)
    }
    
    
    func initSession() {
        
        let device = AVCaptureDevice.default(for: .video)
        do {
            let input = try AVCaptureDeviceInput(device: device!) //创建摄像头输入流
            let output = AVCaptureMetadataOutput() //创建输出流
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            //设置扫描区域
            let widthS = 300 / xScreenHeight
            let heightS = 300 / xScreenWidth
            output.rectOfInterest = CGRect(x: (1-widthS)/2, y: (1-heightS)/2, width: widthS, height: heightS)
            session = AVCaptureSession()
            //采集率质量
            session?.sessionPreset = .high
            session?.addInput(input)
            session?.addOutput(output)
            output.metadataObjectTypes = [.qr,.ean13,.ean8,.code128]
            
        } catch let err as NSError {
            print("发生错误：\(String(describing: err.localizedFailureReason))")
        }
    }
    
    @objc func gotoPhoto() {
       
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .restricted || status == .denied {
            print("没有权限使用！")
        }
    
        else {
            enterImagePickerController()
        }
     
    }
    
    func enterImagePickerController() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    //delegate
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        playSound()
        session?.stopRunning()
        if metadataObjects.count > 0 {
    
            let metadata = metadataObjects.first  as! AVMetadataMachineReadableCodeObject
            let alert = UIAlertController(title: "扫描结果", message:metadata.stringValue, preferredStyle:.alert)
            let action = UIAlertAction(title: "确定", style: .default) { (action) in
                self.session?.startRunning()
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        dismiss(animated: true, completion: nil)
        
        /*CIDetector：iOS自带的识别图片的类*/
        let image:UIImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
        let detector = CIDetector(ofType:CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
        let arr = detector?.features(in: CIImage(cgImage:image.cgImage!))
        var detail = ""
        if (arr?.count)! > 0 {
            detail = (arr?.first as! CIQRCodeFeature).messageString!
        } else {
            detail = "未扫描到结果！"
        }
        
        let alert = UIAlertController(title: "扫描结果", message: detail, preferredStyle: .alert)
        let action = UIAlertAction(title: "确定", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc func lightButtonClick(button:UIButton) {
        
        if button.isSelected == false {
            
            openTorchLight()
            button.isSelected = true
        } else {
            
            closeTorchLiaght()
            button.isSelected = false
        }
        
    }
    
    func openTorchLight() {
    
        let device = AVCaptureDevice.default(for: .video)
        if ((try?device?.lockForConfiguration()) != nil) {
            device?.torchMode = .on
        }
        device?.unlockForConfiguration()
    
    }
    
    func closeTorchLiaght() {
        
        let device = AVCaptureDevice.default(for: .video)
        if ((try?device?.lockForConfiguration()) != nil) {
            device?.torchMode = .off
        }
        device?.unlockForConfiguration()
    }
    
    func playSound() {
        
        let file = Bundle.main.path(forResource: "sound.caf", ofType: nil)
        let fileUrl = URL.init(fileURLWithPath: file!)
        
        var soundId:SystemSoundID = 0
        AudioServicesCreateSystemSoundID(fileUrl as CFURL, &soundId)
        AudioServicesPlayAlertSound(soundId)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

class MaskView: UIView {
    
    var lineLayer:CALayer!
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.1)
        
        lineLayer = CALayer()
        lineLayer.frame = CGRect(x: (frame.width-300)/2, y: (frame.height-300)/2, width: 300, height: 2)
        lineLayer.contents = UIImage(named: "line")?.cgImage
        layer.addSublayer(lineLayer)
        resumeAnimation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect:CGRect){
    
        let width:CGFloat = rect.size.width
        let height:CGFloat = rect.size.height
        let pickingWidth:CGFloat = 300
        let pickingHeight:CGFloat = 300
        
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        context?.setFillColor(red:0.1,green:0.1,blue:0.1,alpha:0.35)
        let pickingRect = CGRect(x: (width-pickingWidth)/2, y: (height-pickingHeight)/2, width: pickingWidth, height: pickingHeight)
        
        let pickingPath = UIBezierPath(rect: pickingRect)
        let bezierRect = UIBezierPath(rect: rect)
        bezierRect.append(pickingPath)
        bezierRect.usesEvenOddFillRule = true
        bezierRect.fill()
        context?.setLineWidth(2)
        context?.setStrokeColor(UIColor.orange.cgColor)
        pickingPath.stroke()
        layer.contentsGravity = kCAGravityCenter

    }
    
    func stopAnimation() {
       
        lineLayer.removeAnimation(forKey: "translationY")
    }
    
    func resumeAnimation() {
       
        let basic = CABasicAnimation(keyPath: "transform.translation.y")
        basic.fromValue = 0
        basic.toValue = 300
        basic.duration = 2
        basic.repeatCount = Float(NSIntegerMax)
        lineLayer.add(basic, forKey: "translationY")
        
    }
}
