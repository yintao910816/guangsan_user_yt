//
//  ImageRx.swift
//  StoryReader
//
//  Created by 尹涛 on 2018/4/23.
//  Copyright © 2018年 020-YinTao. All rights reserved.
//

import Foundation
import RxSwift

func Create(imageTask url: String,
            needCache: Bool = true,
            folder: String = AppImageCacheTmpDir,
            _ cache: CacheDir = .tmp,
            _ imageType: ImageType = .jpg) ->Observable<(UIImage?, String?)>{
    
    return Observable<(UIImage?, String?)>.create { obser -> Disposable in

        if let cacheImage = UIImage.init(contentsOfFile:(cache.path + folder + url.md5 + imageType.typeString)) {
            obser.onNext((cacheImage, url))
            obser.onCompleted()
        }else {
            do {
                try DownImage(url: url, complement: { ret in
                    if needCache, let _noEmptyImage = ret.0 { SaveImage(toSandox: _noEmptyImage, key: url.md5, folder: folder, cache) }
                    
                    obser.onNext(ret)
                    obser.onCompleted()
                })
            } catch {
                obser.onError(error)
                obser.onCompleted()
            }
        }
        return Disposables.create { }
    }
}

extension String {
    
    var md5: String {
        let str = cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize()
        
        return String(format: hash as String)
    }
    
}

