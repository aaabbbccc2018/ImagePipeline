import Foundation
import AVFoundation

public protocol ImageProcessing {
    func process(image: UIImage) -> UIImage
}

public struct ImageResizer: ImageProcessing {
    let targetSize: CGSize
    let contentMode: ImageContentMode
    let isOpaque: Bool
    let backgroundColor: UIColor?

    public enum ImageContentMode {
        case aspectFit
        case aspectFill
    }

    public init(targetSize: CGSize, contentMode: ImageContentMode = .aspectFit, isOpaque: Bool = false, backgroundColor: UIColor? = nil) {
        self.targetSize = targetSize
        self.contentMode = contentMode
        self.isOpaque = isOpaque
        self.backgroundColor = backgroundColor
    }

    public func process(image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else {
            return image
        }

        let rect: CGRect
        switch contentMode {
        case .aspectFit:
            rect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: .zero, size: targetSize))
        case .aspectFill:
            let aspectRatio = image.size.width / image.size.height
            if targetSize.width / aspectRatio > targetSize.height {
                let height = targetSize.width / aspectRatio
                rect = CGRect(x: 0, y: (targetSize.height - height) / 2, width: targetSize.width, height: height)
            } else {
                let width = targetSize.height * aspectRatio
                rect = CGRect(x: (targetSize.width - width) / 2, y: 0, width: width, height: targetSize.height)
            }
        }

        let width = Int(targetSize.width)
        let height = Int(targetSize.height)
        let space = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: CGImageAlphaInfo = isOpaque ? .noneSkipLast : .premultipliedLast
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: space, bitmapInfo: bitmapInfo.rawValue) else {
            return image
        }

        if let backgroundColor = backgroundColor {
            context.setFillColor(backgroundColor.cgColor)
            context.fill(CGRect(origin: .zero, size: targetSize))
        }
        context.draw(cgImage, in: rect)

        if let cgImage = context.makeImage() {
            return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        }
        return image
    }
}
