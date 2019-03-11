//
//  BuildQRCodeVC.swift
//  CAQRCode
//
//  Created by Cary on 2019/2/28.
//  Copyright © 2019 Cary. All rights reserved.
//

import UIKit

class BuildQRCodeVC: UIViewController {
    
    var qrCodeImageView:UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "生成二维码"
        view.backgroundColor = .white
        
        qrCodeImageView = UIImageView()
        qrCodeImageView.center = view.center
        qrCodeImageView.bounds = CGRect(x: 0, y: 0, width: 300, height: 300)
        view.addSubview(qrCodeImageView)
        
        //访问的url
        let url = "https://www.jianshu.com/u/77851f4c0f5b";
        //你的头像（可以为nil）
        let headerImage = UIImage(named: "header")
        //生成图片并且显示
        qrCodeImageView.image = setupQRCodeImage(text: url, image: headerImage)
        
    }
    
    //MARK: -传进去字符串,生成二维码图片
    func setupQRCodeImage(text:String,image:UIImage?) ->UIImage {
        
        //创建滤镜
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        //将url加入二维码
        filter?.setValue(text.data(using: .utf8), forKey: "inputMessage")
        //取出生成的二维码（不清晰）
        if let outputImage = filter?.outputImage {
 
            //生成清晰度更好的二维码
            let qrCodeImage = setupHighDefinitionUIImage(image: outputImage, size: 300)
            
             //如果有头像的话，将头像加入二维码中心
            if var image = image {
                
                //给头像加一个白色圆边（如果不需要直接忽略）
                image = circleImageWithImage(sourceImage: image, borderWidth: 10, borderColor: .white)
                //合成图片
                let newImage = syntheticImage(image: qrCodeImage, iconImage: image, width: 100, height: 100)
                return newImage
                
            }
            return qrCodeImage
        }
        return UIImage()
    }
    
    //MARK: - 生成高清的UIImage
    func setupHighDefinitionUIImage(image:CIImage,size:CGFloat) -> UIImage {
        
        let integral:CGRect = image.extent.integral
        let proportion:CGFloat = min(size/integral.width, size/integral.height)
        let width = integral.width*proportion
        let height = integral.height*proportion
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: 0)!
        let context = CIContext(options: nil)
        let bitmapImage:CGImage = context.createCGImage(image, from: integral)!
        bitmapRef.interpolationQuality = .none
        bitmapRef.scaleBy(x: proportion, y: proportion)
        bitmapRef.draw(bitmapImage, in: integral)
        let image:CGImage = bitmapRef.makeImage()!
        
        return UIImage(cgImage: image)
    }
    
    //image: 二维码 iconImage:头像图片 width: 头像的宽 height: 头像的宽
    func syntheticImage (image:UIImage,iconImage:UIImage,width:CGFloat,height:CGFloat) ->UIImage {
        
        //开启图片上下文
        UIGraphicsBeginImageContext(image.size)
        //绘制背景图片
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        let x = (image.size.width - width)*0.5
        let y = (image.size.height - height)*0.5
        iconImage.draw(in: CGRect(x: x, y: y, width: width, height: height))
        //取出绘制好的图片
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        
        if let newImage = newImage {
            return newImage
        }
        return UIImage()
    }
    
    //生成边框
    func circleImageWithImage(sourceImage:UIImage,borderWidth:CGFloat,borderColor:UIColor) -> UIImage {
        
        let imageWidth = sourceImage.size.width + 2 * borderWidth
        let imageHeight = sourceImage.size.height + 2 * borderWidth
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageWidth, height: imageHeight), false, 0)
        UIGraphicsGetCurrentContext()
        
        let radius = (sourceImage.size.width < sourceImage.size.height ? sourceImage.size.width:sourceImage.size.height) * 0.5
        let bezierPath = UIBezierPath(arcCenter: CGPoint(x: imageWidth*0.5, y: imageHeight*0.5), radius: radius, startAngle: 0, endAngle: .pi*2, clockwise: true)
        bezierPath.lineWidth = borderWidth
        borderColor.setStroke()
        bezierPath.stroke()
        bezierPath.addClip()
        sourceImage.draw(in: CGRect(x: borderWidth, y: borderWidth, width: sourceImage.size.width, height: sourceImage.size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
