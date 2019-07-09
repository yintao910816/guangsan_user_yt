//
//  HCEditUserIconViewController.swift
//  HuChuangApp
//
//  Created by yintao on 2019/2/14.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit

class HCEditUserIconViewController: BaseViewController {

    @IBOutlet weak var userIconOutlet: UIImageView!
    
    private var viewModel: EditUserIconViewModel!
    
    private var selectedImage: UIImage?
    
    @IBAction func actions(_ sender: UIButton) {
        switch sender.tag {
        case 100:
            systemPic()
        case 101:
            takePhoto()
        default:
            break
        }
    }
    
    override func setupUI() {
        
    }
    
    override func rxBind() {
        viewModel = EditUserIconViewModel()
        
        viewModel.userIcon
            .bind(to: userIconOutlet.rx.image(forStrategy: .userIcon))
            .disposed(by: disposeBag)
        
        addBarItem(title: "完成", titleColor: HC_MAIN_COLOR)
            .map{ [unowned self] in self.selectedImage }
            .asObservable()
            .bind(to: viewModel.finishEdit)
            .disposed(by: disposeBag)
        
        viewModel.popSubject
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        viewModel.reloadSubject.onNext(Void())
    }
}

extension HCEditUserIconViewController {
   
    func takePhoto(){
        if HCHelper.checkCameraPermissions() {
            let photoVC = UIImagePickerController()
            photoVC.sourceType = UIImagePickerController.SourceType.camera
            photoVC.delegate = self
            photoVC.allowsEditing = true
            photoVC.showsCameraControls = true
            UIApplication.shared.keyWindow?.rootViewController?.present(photoVC, animated: true, completion: nil)
        }else{
            HCHelper.authorizationForCamera(confirmBlock: { [weak self]()in
                let photoVC = UIImagePickerController()
                photoVC.sourceType = UIImagePickerController.SourceType.camera
                photoVC.delegate = self
                photoVC.allowsEditing = true
                photoVC.showsCameraControls = true
                UIApplication.shared.keyWindow?.rootViewController?.present(photoVC, animated: true, completion: nil)
            })
            NoticesCenter.alert(title: nil, message: "请在手机设置-隐私-相机中开启权限")
        }
    }
    
    func systemPic(){
        let systemPicVC = UIImagePickerController()
        systemPicVC.sourceType = UIImagePickerController.SourceType.photoLibrary
        systemPicVC.delegate = self
        systemPicVC.allowsEditing = true
        UIApplication.shared.keyWindow?.rootViewController?.present(systemPicVC, animated: true, completion: nil)
    }
}

extension HCEditUserIconViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImage = img
            userIconOutlet.image = img
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}
