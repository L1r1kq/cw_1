//
//  ImageProcessor.swift
//  cw_1
//
//  Created by Кирилл Титов on 21.11.2024.
//

import UIKit

enum ImageProcessingError: Error {
    case failedToApplyFilter(String)
    case imageNotFound
}

class ImageProcessor {
    static func applyFilter(to image: UIImage, filterName: String) throws -> UIImage {
        guard let ciImage = CIImage(image: image) else {
            throw ImageProcessingError.imageNotFound
        }
        let context = CIContext()
        
        guard let filter = CIFilter(name: filterName) else {
            throw ImageProcessingError.failedToApplyFilter(filterName)
        }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            throw ImageProcessingError.failedToApplyFilter(filterName)
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    static func applyRandomFilter(to image: UIImage) -> UIImage? {
        let filters = [
            "CISepiaTone",
            "CIPhotoEffectMono",
            "CIPhotoEffectNoir",
            "CIPhotoEffectChrome",
            "CIPhotoEffectInstant"
        ]
        let randomFilter = filters.randomElement() ?? "CISepiaTone"
        
        do {
            return try applyFilter(to: image, filterName: randomFilter)
        } catch {
            print("Ошибка применения фильтра: \(error)")
            return nil
        }
    }
}
