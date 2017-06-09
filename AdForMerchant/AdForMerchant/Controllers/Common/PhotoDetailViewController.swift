//
//  PhotoDetailViewController.swift
//  AdForMerchant
//
//  Created by YYQ on 16/3/25.
//  Copyright © 2016年 Windward. All rights reserved.
//  swiftlint:disable weak_delegate

import UIKit
import SKPhotoBrowser
import SDWebImage

protocol DetailPhotoViewDelegate: class {
    func photoBrowser(_ skPhotoBroswer: SKPhotoBrowser?)
}

// MARK: - SKPhoto
public class SKPhotoImage: NSObject, SKPhotoProtocol {
    public var contentMode: UIViewContentMode
    public var underlyingImage: UIImage!
    public var photoURL: String!
    public var shouldCachePhotoURLImage: Bool = false
    public var caption: String!
    public var index: Int
    
    override init() {
        contentMode = .scaleAspectFill
        index = 0
        super.init()
    }
    
    convenience init(image: UIImage) {
        self.init()
        underlyingImage = image
    }
    
    convenience init(url: String) {
        self.init()
        photoURL = url
    }
    
    convenience init(url: String, holder: UIImage?) {
        self.init()
        photoURL = url
        underlyingImage = holder
    }
    
    open func checkCache() {
    }
    
    open func loadUnderlyingImageAndNotify() {
        
        if underlyingImage != nil && photoURL == nil {
            loadUnderlyingImageComplete()
        }
        
        if photoURL != nil {
            SDWebImageManager.shared().loadImage(with: URL(string: photoURL), options: SDWebImageOptions.refreshCached, progress: nil, completed: { (image, _, error, type, complete, url) in
                if complete {
                    self.underlyingImage = image
                    self.loadUnderlyingImageComplete()
                }
            })
        }
    }
    
    open func loadUnderlyingImageComplete() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: SKPHOTO_LOADING_DID_END_NOTIFICATION), object: self)
    }
    
    // MARK: - class func
    open class func photoWithImage(_ image: UIImage) -> SKPhotoImage {
        return SKPhotoImage(image: image)
    }
    
    open class func photoWithImageURL(_ url: String) -> SKPhotoImage {
        return SKPhotoImage(url: url)
    }
    
    open class func photoWithImageURL(_ url: String, holder: UIImage?) -> SKPhotoImage {
        return SKPhotoImage(url: url, holder: holder)
    }
}

class DetailPhotoView: UIView {
    
    var delegate: DetailPhotoViewDelegate?
    
    //    var photosUrlArray: [String] = []
    var photoInfoArray: [(String?, UIImage?)] = [] {
        didSet {
            refreshImages()
        }
    }
    
    var photoWidth: CGFloat = 60

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    func refreshImages() {
        for i in 0...photoCountMax {
            let bgView = viewWithTag(i + smallPhotoTag)
            bgView?.removeFromSuperview()
        }
        
        let space = ((screenWidth - 20 * 2) - photoWidth * 4) / 3
        
        for i in 0 ..< photoInfoArray.count {
            let col = i % 4
            let row = i / 4
            let bgView = UIView(frame: CGRect(x: 20 + CGFloat(col) * (photoWidth + space), y: CGFloat(row) * (photoWidth + space), width: photoWidth + space, height: photoWidth + space))
            bgView.tag = i + smallPhotoTag
            addSubview(bgView)
            
            let img = UIImageView(frame: CGRect(x: 0, y: 10, width: photoWidth, height: photoWidth))
            img.contentMode = UIViewContentMode.scaleAspectFill
            img.isUserInteractionEnabled = true
            img.clipsToBounds = true
            bgView.addSubview(img)
            
            if let image = photoInfoArray[i].1 {
                img.image = image
            } else if let url = photoInfoArray[i].0 {
                img.sd_setImage(with: URL(string: url) ?? URL(string: ""), placeholderImage: UIImage(named: "CommonGrayBg"))
            }
            
            let singleFingerOne = UITapGestureRecognizer(target: self, action: #selector(PhotoView.imagePressed(_:)))
            img.addGestureRecognizer(singleFingerOne)
        }
    }
    
    func imagePressed(_ tapGest: UITapGestureRecognizer) {
        guard let tapView = tapGest.view, let superView = tapView.superview else { return  }
        let index = superView.tag - smallPhotoTag
        var images = [SKPhotoProtocol]()
        for item in self.photoInfoArray {
            let photo = SKPhotoImage.photoWithImageURL(item.0!)
            images.append(photo)
        }
        
        //creat PhotoBrowser instance, and pressent
        let browser = SKPhotoBrowser(photos: images)
        browser.initializePageIndex(index)
        delegate?.photoBrowser(browser)
    }
    
    func deleteImagePressed(_ sender: UIButton) {
    }
    
    //处理图片
    func compressUploadPic(_ image: UIImage) -> UIImage {
        if image.size.width > 60 || image.size.height > 60 {
            var width: CGFloat = 0
            var height: CGFloat = 0
            let zoomWidth: CGFloat = image.size.width / 60
            let zoomHeight: CGFloat = image.size.height / 60
            
            if zoomWidth > zoomHeight {
                width = 60
                height = image.size.height / zoomWidth
            } else {
                width = image.size.width / zoomHeight
                height = 60
            }
            let img = self.imageWithImageSimple(image, scaledToSize:CGSize(width: width, height: height))
            return img
        } else {
            return image
        }
    }
    
    //改变图片大小
    func imageWithImageSimple(_ image: UIImage, scaledToSize newSize: CGSize ) -> UIImage {
        // Create a graphics image context
        UIGraphicsBeginImageContext(newSize)
        // Tell the old image to draw in this new context, with the desired
        // new size
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        // Get the new image from the context
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        // End the context
        UIGraphicsEndImageContext()
        // Return the new image.
        return newImage ?? UIImage()
    }
}

class PhotoDetailViewController: UIViewController {
    @IBOutlet fileprivate weak var topPhotoBg: UIView!
    var photoView: DetailPhotoView!
    var photosUrlArray: [String] = []
    var tempPhotosArray: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "图片详情"
        photoView = DetailPhotoView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 280))
        photoView.delegate = self
        topPhotoBg.addSubview(photoView)
        
        refreshPhotoView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func refreshPhotoView() {
        photoView.photoInfoArray = photosUrlArray.map {return ($0, nil) as (String?, UIImage?)} + tempPhotosArray.map { return (nil, $0) as (String?, UIImage?)}
    }
}

extension PhotoDetailViewController: DetailPhotoViewDelegate {
    func photoBrowser(_ skPhotoBroswer: SKPhotoBrowser?) {
        guard let broswer = skPhotoBroswer else { return }
        present(broswer, animated: true)
    }
}
