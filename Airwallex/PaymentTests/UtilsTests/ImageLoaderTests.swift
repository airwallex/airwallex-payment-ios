//
//  ImageLoaderTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/26.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import XCTest
@testable import Payment

class ImageLoaderTests: XCTestCase {
    
    var imageLoader: ImageLoader!
    var mockURL: URL!
    var mockImage: UIImage!
    var mockSession: URLSession!
    var mockSuccessResponse: URLResponse!
    var mockFailureResponse: URLResponse!
    
    override func setUp() {
        super.setUp()
        imageLoader = ImageLoader()
        mockURL = URL(string: "https://example.com/image.png")
        mockImage = UIImage(systemName: "star")
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: configuration)
        mockSuccessResponse = HTTPURLResponse(
            url: mockURL,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        mockFailureResponse = HTTPURLResponse(
            url: mockURL,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )
    }
    
    override func tearDown() {
        imageLoader = nil
        mockURL = nil
        mockImage = nil
        MockURLProtocol.mockResponse = nil
        super.tearDown()
    }
    
    func testCachedImageReturnsImage() {
        // Arrange
        imageLoader.updateCache(mockImage, imageURL: mockURL)
        
        // Act
        let cachedImage = imageLoader.cachedImage(mockURL)
        
        // Assert
        XCTAssertNotNil(cachedImage)
        XCTAssertEqual(cachedImage, mockImage)
        imageLoader.updateCache(nil, imageURL: mockURL)
        XCTAssertNil(imageLoader.cachedImage(mockURL))
    }
    
    func testGetImageFetchesAndCachesImage() async throws {
        // Arrange
        let mockData = mockImage.pngData()!
        MockURLProtocol.mockResponse = (mockData, mockSuccessResponse, nil)
        let imageLoader = ImageLoader(session: mockSession)
        let imageView = await UIImageView()
        
        // Act
        let fetchedImage = try await imageLoader.loadImage(mockURL, for: imageView)
        
        // Assert
        XCTAssertNotNil(fetchedImage)
        XCTAssertEqual(mockData, fetchedImage.pngData())
        XCTAssertEqual(fetchedImage, imageLoader.cachedImage(mockURL))
    }
    
    func testGetImageHandlesNetworkError() async {
        // Arrange
        let mockError = NSError(domain: "TestError", code: 1, userInfo: nil)
        let imageLoader = ImageLoader(session: mockSession)
        let imageView = await UIImageView()
        MockURLProtocol.mockResponse = (nil, mockFailureResponse, mockError)
        
        // Act & Assert
        do {
            let _ = try await imageLoader.loadImage(mockURL, for: imageView)
            XCTFail("expected error thrown")
        } catch {
            guard case ImageFetcher.ImageFetcherError.networkError(underlying: let error) = error,
                  (error as NSError).domain == "TestError" else {
                XCTFail()
                return
            }
        }
    }
    
    func testGetImageHandlesExistingTaskFailure() async {
        // Arrange
        let imageLoader = ImageLoader(session: mockSession)
        let imageView = await UIImageView()
        MockURLProtocol.mockResponse = (mockImage.pngData(), mockSuccessResponse, nil)
        
        // Act & Assert
        do {
            async let image1 = imageLoader.loadImage(mockURL, for: imageView)
            async let image2 = imageLoader.loadImage(mockURL, for: imageView)
            let (_, _) = try await (image1, image2)
            XCTFail("expected error thrown")
        } catch {
            guard case ImageFetcher.ImageFetcherError.existingTask = error else {
                XCTFail()
                return
            }
        }
    }
    
    func testImageFetcherCancelledError() async {
        // Arrange
        let imageLoader = ImageLoader(session: mockSession)
        let imageView = await UIImageView()
        MockURLProtocol.mockResponse = (mockImage.pngData(), mockSuccessResponse, nil)
        
        // Act & Assert
        do {
            async let image1 = imageLoader.loadImage(mockURL, for: imageView)
            async let image2 = imageLoader.loadImage(URL(string: "https://example.com/image2.png")!, for: imageView)
            let (_, _) = try await (image1, image2)
            XCTFail("expected error thrown")
        } catch {
            guard case ImageFetcher.ImageFetcherError.cancelled = error else {
                XCTFail()
                return
            }
        }
    }
    
    func testImageFetcherInvalidDataError() async {
        // Arrange
        let imageLoader = ImageLoader(session: mockSession)
        let imageView = await UIImageView()
        MockURLProtocol.mockResponse = (nil, mockSuccessResponse, nil)
        
        // Act & Assert
        do {
            _ = try await imageLoader.loadImage(mockURL, for: imageView)
            XCTFail("expected error thrown")
        } catch {
            guard case ImageFetcher.ImageFetcherError.invalidData = error else {
                XCTFail("Expected ImageFetcher.ImageFetcherError.invalidData but get \(error)")
                return
            }
        }
    }
    
    func testConcurrency() async {
        // Arrange
        let imageLoader = ImageLoader(session: mockSession)
        let imageView = await UIImageView()
        MockURLProtocol.mockResponse = (mockImage.pngData(), mockSuccessResponse, nil)
        
        await withTaskGroup(of: UIImage?.self) { group in
            for _ in 0..<100 {
                group.addTask {
                    return try? await imageLoader.loadImage(self.mockURL, for: imageView)
                }
            }
            
            var count = 0
            for await image in group {
                count += (image == nil ? 0 : 1)
            }
            XCTAssertTrue(count == 1)
        }
        
        // all read from cache
        await withTaskGroup(of: UIImage?.self) { group in
            for _ in 0..<100 {
                group.addTask {
                    return try? await imageLoader.loadImage(self.mockURL, for: imageView)
                }
            }
            
            var count = 0
            for await image in group {
                count += (image == nil ? 0 : 1)
            }
            XCTAssertEqual(count, 100)
        }
    }
}

