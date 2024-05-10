//
//  ContentView.swift
//  llamas
//
//  Created by Jennifer Chen on 4/29/24.
//

import SwiftUI
import AppKit

let IMAGE_WIDTH: CGFloat = 200

struct ContentView: View {
    @ObservedObject var viewModel: CompanionViewModel
    var body: some View {
        VStack {
            AnimatedImageView(isFrozen: $viewModel.isFrozen, facingLeft: $viewModel.facingLeft, images: $viewModel.images, reversedImages: $viewModel.reversedImages, inPlaceImages: $viewModel.inPlaceImages)
                .frame(width: IMAGE_WIDTH, height: (IMAGE_WIDTH/viewModel.images[0].size.width)*viewModel.images[0].size.height)
        }
        .padding()
        .edgesIgnoringSafeArea(.all)
    }
}

extension CGImage {
    func flippedHorizontally() -> CGImage {
        let width = self.width
        let height = self.height
        let size = CGSize(width: width, height: height)
        let rect = CGRect(origin: .zero, size: size)
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        let colorSpace = self.colorSpace!
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo) else {
            fatalError("Failed to create graphics context")
        }
        context.translateBy(x: size.width, y: 0)
        context.scaleBy(x: -1, y: 1)
        context.draw(self, in: rect)
        return context.makeImage()!
    }
}

//allows user to click on the window to pause/unpause movement
class InteractiveImageView: NSImageView {
    var onTap: () -> Void  //closure to call when the image is tapped

    init(onTap: @escaping () -> Void) {
        self.onTap = onTap
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        self.onTap() //call the closure when mouse is down
    }
}


struct AnimatedImageView: NSViewRepresentable {
    @Binding var isFrozen: Bool
    @Binding var facingLeft: Bool
    @Binding var images: [NSImage]
    @Binding var reversedImages: [NSImage]
    @Binding var inPlaceImages: [NSImage]

    func makeNSView(context: Context) -> NSImageView {
        let nsImageView = InteractiveImageView(onTap: {
            self.isFrozen.toggle()
        })
        nsImageView.imageScaling = .scaleProportionallyUpOrDown
        nsImageView.wantsLayer = true
        nsImageView.animates = true
        animateImages(imageView: nsImageView)

        let shadow = NSShadow()
        shadow.shadowOffset = NSMakeSize(2, -2)
        shadow.shadowColor = NSColor.lightGray
        shadow.shadowBlurRadius = 3
        nsImageView.shadow = shadow
        return nsImageView
    }

    func updateNSView(_ nsView: NSImageView, context: Context) {
         animateImages(imageView: nsView)
    }

    func animateImages(imageView: NSImageView) {
        let animation = CAKeyframeAnimation(keyPath: "contents")
        var dirImages = facingLeft ? images : reversedImages
        if isFrozen{
            dirImages = inPlaceImages
        }
        
        let cgImages = dirImages.map { $0.cgImage(forProposedRect: nil, context: nil, hints: nil)! }
        animation.values = cgImages
        animation.duration = Double(dirImages.count) * 0.02
        animation.repeatCount = .infinity
        imageView.layer?.add(animation, forKey: nil)
    }
}

