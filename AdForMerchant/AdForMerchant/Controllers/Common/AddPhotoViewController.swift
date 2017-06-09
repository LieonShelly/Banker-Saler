//
//  AddPhotoViewController.swift
//  feno
//
//  Created by Kuma on 6/16/15.
//  Copyright (c) 2015 Windward. All rights reserved.
//  swiftlint:disable weak_delegate

import UIKit
import AVFoundation
import Photos
import SDWebImage

let smallPhotoTag = 1000
let photoCountMax = 12

protocol PhotoViewItemDelegate: class {
    func clickPhotoWithIndex(_ index: Int)
    func clickDeletePhotoWithIndex(_ index: Int)
}

class PhotoView: UIView {
    var photoInfoArray: [(String?, UIImage?)] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var photoWidth: CGFloat = 60
    var delegate: PhotoViewItemDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // 描绘照片
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        for i in 0...photoCountMax {
            let bgView = viewWithTag(i + smallPhotoTag)
            bgView?.removeFromSuperview()
        }
        
        let space = ((screenWidth - 20 * 2) - photoWidth * 4) / 3
        
        for i in 0 ..< photoInfoArray.count {
            let col = i % 4
            let row = i / 4
            let bgView = UIView(frame: CGRect(x: 20 + CGFloat(col) * (photoWidth + space), y: CGFloat(row) * (photoWidth + space), width: photoWidth + space, height: photoWidth + space))
            bgView.tag = i+smallPhotoTag
            addSubview(bgView)
            
            let img = UIImageView(frame:CGRect(x: 0, y: 10, width: photoWidth, height: photoWidth))
            img.contentMode = UIViewContentMode.scaleAspectFill
            img.isUserInteractionEnabled = true
            img.clipsToBounds = true
            bgView.addSubview(img)
            
            if let image = photoInfoArray[i].1 {
                img.image = compressUploadPic(image)
            } else if let url = photoInfoArray[i].0 {
                if let image = SDImageCache.shared().imageFromDiskCache(forKey: url) {
                    img.image = image
                } else {
                    
                          img.sd_setImage(with: URL(string: url) ?? URL(string: ""), placeholderImage: UIImage(named: "ImageDefaultPlaceholderW55H50"))
                }
//                img.sd_setImageWithURL(NSURL(string: url)!, placeholderImage: UIImage(named: "ImageDefaultPlaceholderW55H50"))
//                img.image = SDImageCache.sharedImageCache().imageFromDiskCacheForKey(url)
                
//                UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:strUrl];
                
            }
            
            let deleteButton = UIButton(type: .custom)
            deleteButton.frame = CGRect(x: photoWidth - 23, y: 13, width: 20, height: 20)
            deleteButton.setBackgroundImage(UIImage(named: "CommonDeleteBadgeButton"), for: UIControlState())
            deleteButton.addTarget(self, action: #selector(PhotoView.deleteImagePressed(_:)), for: .touchUpInside)
            bgView.addSubview(deleteButton)
            
            let singleFingerOne = UITapGestureRecognizer(target: self, action: #selector(PhotoView.imagePressed(_:)))
            img.addGestureRecognizer(singleFingerOne)
        }
    }
    
    func imagePressed(_ tapGest: UITapGestureRecognizer) {
         guard let tapView = tapGest.view, let superView = tapView.superview else { return  }
        let index = superView.tag - smallPhotoTag
        guard let del = delegate else {
            return
        }
        del.clickPhotoWithIndex(index)
    }
    
    func deleteImagePressed(_ sender: UIButton) {
        guard let superView = sender.superview else { return  }
        let index = superView.tag - smallPhotoTag
        guard let del = delegate else {
            return
        }
        del.clickDeletePhotoWithIndex(index)
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
    func imageWithImageSimple(_ image: UIImage, scaledToSize newSize: CGSize) -> UIImage {
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

class AddPhotoViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var topPhotoBg: UIView!
    // url array
    var photosUrlArray: [String] = []
    var tempPhotosArray: [String] = []
    var succeedImgInfos: [(String, String)] = []
    var isEdit = false
    var photoView: PhotoView!
    
    var maxNumb: Int = 10
    var uploadImgPath: String = "goods/detail"
    
    @IBOutlet weak fileprivate var addFromLibraryButton: UIButton!
    @IBOutlet weak fileprivate var takePhotoButton: UIButton!
    
    @IBOutlet fileprivate weak var tipsLabel: UILabel!
    
    var completeBlock: (([String]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "添加图片"
        
        photoView = PhotoView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 280))
        photoView.delegate = self
        topPhotoBg.addSubview(photoView)
        let rightBarItem = UIBarButtonItem(title: "确定", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddPhotoViewController.confirmAction))
        self.navigationItem.rightBarButtonItem = rightBarItem
        addFromLibraryButton.addTarget(self, action: #selector(AddPhotoViewController.addImageFromPhotoLibrary), for: .touchUpInside)
        takePhotoButton.addTarget(self, action: #selector(AddPhotoViewController.takePicture), for: .touchUpInside)
        
        tipsLabel.text = "温馨提示：一共可上传\(maxNumb)张图片，单张图片不超过2M"
        // 刷新图片
        self.refreshPhotoView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func addImageFromPhotoLibrary() {
        let currentInt: Int = Int(photosUrlArray.count + tempPhotosArray.count)
        let maxInt = maxNumb - currentInt
        if maxInt == 0 {
            Utility.showAlert(self, message: "图片已达到\(maxNumb)张，不能再上传图片")
            return
        }
       guard let vc = TZImagePickerController(maxImagesCount: 10, delegate: self) else { return }
        vc.maxImagesCount = Int(maxInt)
        vc.autoDismiss = true
        vc.allowPickingVideo = false
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func takePicture() {
        if (photosUrlArray.count + tempPhotosArray.count) == maxNumb {
            Utility.showAlert(self, message: "图片已达到\(maxNumb)张，不能再上传图片")
            return
        }
        chooseFromType(.camera)
    }
}

extension AddPhotoViewController {
    func backAction() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func confirmAction() {
        uploadImage()
    }
    
    func chooseFromType(_ type: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.navigationBar.barTintColor = UIColor.white
        picker.delegate = self
        picker.sourceType = type
        self.present(picker, animated: true) { () -> Void in
            
        }
    }
    
    func uploadImage() {
        succeedImgInfos.removeAll()
        // 上传成功后 这里的数据被清楚了 tempphotosarray
        let tempArray = tempPhotosArray.flatMap {
            return SDImageCache.shared().defaultCachePath(forKey: $0)
        }
        let imagePathArray = tempArray.flatMap {
            return URL(fileURLWithPath: $0)
        }
        
        //        print("imagePathArray"+"\(imagePathArray)")
        let parameters: [String: Any] = [
            "img": imagePathArray,
            "prefix[img]": uploadImgPath
        ]
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.uploadImageWithFilePath(AFMRequest.imageUpload, params: parameters) { (_, _, object, error) -> Void in
            if let result = object as? [String: Any], let photoUploadedArray = result["success"] as? [[String: Any]] {
                //                if photoUploadedArray.isEmpty {
                //                    Utility.showMBProgressHUDToastWithTxt("上传失败，请稍后重试")
                //                    return
                //                }
                //                print(result)
                let succeedPhotoArray = photoUploadedArray.flatMap({ (imgInfo) -> (String, String) in
                    if let imgUrl = imgInfo["url"] as? String, let imgName = imgInfo["name"] as? String {
                        return (imgUrl, imgName)
                    }
                    return ("", "")
                })
                
                self.succeedImgInfos.append(contentsOf: succeedPhotoArray)
                self.imgUploadSucceed()
                Utility.hideMBProgressHUD()
            } else {
                if let userInfo = error?.userInfo, let msg = userInfo["message"] as? String {
                    Utility.showMBProgressHUDToastWithTxt(msg)
                } else {
                    Utility.showMBProgressHUDToastWithTxt("上传失败，请稍后重试")
                }
            }
        }
    }
    
    func imgUploadSucceed() {
        for (imgUrl, _) in succeedImgInfos where !imgUrl.isEmpty {
            photosUrlArray.append(imgUrl)
        }
        
        tempPhotosArray.removeAll()
        if let block = completeBlock {
            block(photosUrlArray)
            backAction()
        }
        //        print("tempPhotosArray=="+"\(tempPhotosArray.count)")
    }
    
    func imageOrientationFix(_ img: UIImage, orientation: UIImageOrientation) -> UIImage {
        if let cgImage = img.cgImage {
            switch orientation {
            case .down: // 180 deg rotation
                return UIImage(cgImage: cgImage, scale: 1.0, orientation: .down)
            case .left: // 90 deg CCW
                return UIImage(cgImage: cgImage, scale: 1.0, orientation: .left)
            case .right: // 90 deg CW
                return UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
            default:
                return img
            }
        }
        return UIImage()
    }
    
    func proceedFinished() {
        Utility.hideMBProgressHUD()
        refreshPhotoView()
    }
    
    func refreshPhotoView() {
        photoView.photoInfoArray = photosUrlArray.map { return ($0, nil) as (String?, UIImage?)} + tempPhotosArray.map { return ($0, nil) as (String?, UIImage?)}
    }
}

extension AddPhotoViewController: PhotoViewItemDelegate {
    //点击添加图片
    func clickAddPhoto() {
    }
    
    //删除照片
    func clickDeletePhotoWithIndex(_ index: Int) {
        Utility.showConfirmAlert(self, message: "删除该图片？", confirmCompletion: {
            if index < self.photosUrlArray.count {
                self.photosUrlArray.remove(at: index)
            } else {
                self.tempPhotosArray.remove(at: index - self.photosUrlArray.count)
            }
            // 刷新
            self.refreshPhotoView()
        })
    }
    
    //点击某张图片
    func clickPhotoWithIndex(_ index: Int) {
    }
}

extension AddPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Image Picker Controller Delegate
       func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let oldImg = (info as NSDictionary).value(forKey: UIImagePickerControllerOriginalImage) as? UIImage else { return }
        guard let imageData1 = UIImageJPEGRepresentation(oldImg, 0.9) else { return }
        guard let img = UIImage(data: imageData1) else { return }
        let random = AFMRequest.randomStringWithLength16()
        let imgName = "AddPhotoTemp" + "\(random)"
        SDImageCache.shared().store(img, forKey: imgName)
        tempPhotosArray.append(imgName)
        refreshPhotoView()
        dismiss(animated: true, completion: nil)
    }
}

extension AddPhotoViewController: TZImagePickerControllerDelegate {
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        let assetCount = assets.count
        var processedCount = 0
        guard let assets = assets as? [PHAsset] else {return}
        let processImageGroup = DispatchGroup()
        for item in assets {
            processImageGroup.enter()
            
            let manager = PHImageManager.default()
            let opition = PHImageRequestOptions()
            opition.version = .current
            opition.deliveryMode = .highQualityFormat
            let scale = UIScreen.main.scale
            let space = ((screenWidth - 20 * 2) - 60 * 4) / 3
            let cellSize = CGSize(width: 60 + space, height: 60 + space)
            let size = cellSize.width * scale
            let assetGridThumbnailSize = CGSize(width: size, height: size)
            
            manager.requestImage(for: item, targetSize: assetGridThumbnailSize, contentMode: .aspectFill, options: opition, resultHandler: { (image, info) in
                guard let iv = image else { return }
                let fixOrientationImg = self.imageOrientationFix(iv, orientation: iv.imageOrientation)
                let imageData = UIImageJPEGRepresentation(fixOrientationImg, 0.9)
                //                let imageData = UIImageJPEGRepresentation(image!, 1.0)
                let random = AFMRequest.randomStringWithLength16()
                let imgName = "AddPhotoTemp" + "\(random)"
                SDImageCache.shared().storeImageData(toDisk: imageData, forKey: imgName)
                self.tempPhotosArray.append(imgName)
                processedCount += 1
                processImageGroup.leave()
            })
            processImageGroup.notify(queue: DispatchQueue.main) {
                if processedCount == assetCount {
                    self.proceedFinished()
                }
            }
        }
    }
}
