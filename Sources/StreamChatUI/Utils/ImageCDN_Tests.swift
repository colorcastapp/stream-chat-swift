//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
@testable import StreamChatUI
import XCTest

class ImageCDN_Tests: XCTestCase {
    func test_cache_validStreamURL_filtered() {
        let provider = StreamImageCDN()
        
        let url = URL(string: "https://wwww.stream-io-cdn.com/image.jpg?name=Luke&father=Anakin")!
        let filteredUrl = "https://wwww.stream-io-cdn.com/image.jpg"
        let key = provider.cachingKey(forImage: url)
        
        XCTAssertEqual(key, filteredUrl)
    }
    
    func test_cache_validStreamURL_unchanged() {
        let provider = StreamImageCDN()
        
        let url = URL(string: "https://wwww.stream-io-cdn.com/image.jpg")!
        let key = provider.cachingKey(forImage: url)
        
        XCTAssertEqual(key, url.absoluteString)
    }
    
    func test_cache_validURL_unchanged() {
        let provider = StreamImageCDN()
        
        let url = URL(string: "https://wwww.stream.io")!
        let key = provider.cachingKey(forImage: url)
        
        XCTAssertEqual(key, url.absoluteString)
    }
    
    func test_cache_invalidURL_unchanged() {
        let provider = StreamImageCDN()
        
        let url1 = URL(string: "https://abc")!
        let key1 = provider.cachingKey(forImage: url1)
        
        let url2 = URL(string: "abc.def")!
        let key2 = provider.cachingKey(forImage: url2)
        
        XCTAssertEqual(key1, url1.absoluteString)
        XCTAssertEqual(key2, url2.absoluteString)
    }
    
    func test_thumbnail_validUrl_withoutParameters() {
        let provider = StreamImageCDN()
        
        let url = URL(string: "https://wwww.stream-io-cdn.com/image.jpg")!
        let thumbnailUrl = URL(string: "https://wwww.stream-io-cdn.com/image.jpg?w=128&h=128&crop=bottom&resize=scale&ro=0")!
        let processedURL = provider.thumbnailURL(originalURL: url, preferedSize: CGSize(width: 128, height: 128), crop: .bottom, resize: .scale)
        
        XCTAssertEqual(processedURL, thumbnailUrl)
    }
    
    func test_thumbnail_validUrl_withParameters() {
        let provider = StreamImageCDN()
        
        let url = URL(string: "https://wwww.stream-io-cdn.com/image.jpg?name=Luke")!
        let thumbnailUrl = URL(string: "https://wwww.stream-io-cdn.com/image.jpg?name=Luke&w=128&h=128&crop=bottom&resize=scale&ro=0")!
        let processedURL = provider.thumbnailURL(originalURL: url, preferedSize: CGSize(width: 128, height: 128), crop: .bottom, resize: .scale)
        
        XCTAssertEqual(processedURL, thumbnailUrl)
    }
    
    func test_thumbnail_validUrl_withParameters2() {
        let provider = StreamImageCDN()
        
        let url = URL(string: "https://wwww.stream-io-cdn.com/image.jpg?name=Luke")!
        let thumbnailUrl = URL(string: "https://wwww.stream-io-cdn.com/image.jpg?name=Luke&w=128&h=128&crop=center&resize=fill&ro=0")!
        let processedURL = provider.thumbnailURL(originalURL: url, preferedSize: CGSize(width: 128, height: 128))
        
        XCTAssertEqual(processedURL, thumbnailUrl)
    }
}
