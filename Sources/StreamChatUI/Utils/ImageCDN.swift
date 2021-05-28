//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import UIKit

public enum ImageCrop: String {
    case top, bottom, left, right, center
}

public enum ImageResize: String {
    case crop, scale, fill
}

/// Caching key provider is providing customised (filtered) key to be used for caching.
///
/// The URL can contain extra parameters that are changing every time. Those parameters are effectively blocking the caching.
/// By providing customised (filtered) key, the cache will work as expected.
public protocol ImageCDN {
    /// Customised (filtered) key for image cache.
    /// - Parameter imageURL: URL of the image that should be customised (filtered).
    /// - Returns: String to be used as an image cache key.
    func cachingKey(forImage url: URL) -> String
    
    /// Enhance image URL with size parameters to get thumbnail
    /// - Parameters:
    ///   - originalURL: URL of the image to gwt the thumbnail for.
    ///   - preferedSize: The requested thumbnail size.
    ///   - crop: Crop type to be used for the thumbnail.
    ///   - resize: Resize type to be used for the thumbnail.
    func thumbnailURL(originalURL: URL, preferedSize: CGSize, crop: ImageCrop, resize: ImageResize) -> URL
}

public extension ImageCDN {
    func thumbnailURL(originalURL: URL, preferedSize: CGSize) -> URL {
        thumbnailURL(originalURL: originalURL, preferedSize: preferedSize, crop: .center, resize: .fill)
    }
}

public struct StreamImageCDN: ImageCDN {
    public static var streamCDNURL = "stream-io-cdn.com"
    
    public func cachingKey(forImage url: URL) -> String {
        let key = url.absoluteString
        
        guard
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let host = components.host
        else { return key }
        
        // Stream CDN
        if host.contains(StreamImageCDN.streamCDNURL) {
            components.query = nil
            return components.string ?? key
        }
        
        return key
    }
    
    public func thumbnailURL(originalURL: URL, preferedSize: CGSize, crop: ImageCrop, resize: ImageResize) -> URL {
        guard var components = URLComponents(url: originalURL, resolvingAgainstBaseURL: true) else { return originalURL }
        
        components.queryItems = components.queryItems ?? []
        components.queryItems?.append(contentsOf: [
            URLQueryItem(name: "w", value: String(format: "%.0f", preferedSize.width)),
            URLQueryItem(name: "h", value: String(format: "%.0f", preferedSize.height)),
            URLQueryItem(name: "crop", value: crop.rawValue),
            URLQueryItem(name: "resize", value: resize.rawValue),
            URLQueryItem(name: "ro", value: "0") // Required parameter.
        ])
        
        return components.url ?? originalURL
    }
}
