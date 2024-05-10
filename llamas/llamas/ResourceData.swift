//
//  resource_data.swift
//  llamas
//
//  Created by Jennifer Chen on 5/1/24.
//

import Foundation
import SwiftUI
import AppKit

struct ResourceData {
    var images: [NSImage]
    var reversedImages: [NSImage]
}

enum Companion {
    case CINAMOROLL
    case LLAMA
    
    func getImages() -> [NSImage] {
        switch self {
        case .CINAMOROLL:
            return getCinamorollImages()
        case .LLAMA:
            return getPartyLlamaImages()
        }
    }
}

func flipImages(images: [NSImage]) -> [NSImage] {
    var flippedImages = [NSImage]()

    for image in images {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            fatalError("Failed to create CGImage from NSImage")
        }

        let width = cgImage.width
        let height = cgImage.height
        let size = CGSize(width: width, height: height)
        let rect = CGRect(origin: .zero, size: size)

        //define bitmapInfo with appropriate alpha handling
        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo) else {
            fatalError("Failed to create graphics context")
        }

        context.translateBy(x: size.width, y: 0)
        context.scaleBy(x: -1, y: 1)
        context.draw(cgImage, in: rect)

        if let newCGImage = context.makeImage() {
            let flippedImage = NSImage(cgImage: newCGImage, size: size)
            flippedImages.append(flippedImage)
        } else {
            fatalError("Failed to create flipped image")
        }
    }
    return flippedImages
}


func getPartyLlamaImages() -> [NSImage]{
    var images: [NSImage] = []
    for i in 0...45 {
        if let image = NSImage(named: "frame_\(i)_delay-0.02s.gif") {
            images.append(image)
        }
    }
    return images
}

func getSleepingLlamaImages() -> [NSImage]{
    var images: [NSImage] = []
    for i in 0...45 {
        if let image = NSImage(named: "sleeping_llama_\(i).gif") {
            images.append(image)
        }
    }
    return images
}

func getCinamorollImages() -> [NSImage]{
    var images: [NSImage] = []
    for i in 0...140 {
        var padding: String = ""
        if i < 10{
            padding += "0"
        }
        if i < 100{
            padding += "0"
        }
        let name: String = "frame_" + padding + "\(i)" + "_delay-0.03s.gif"
        if let image = NSImage(named: name) {
            images.append(image)
        }
    }
    return images
}
