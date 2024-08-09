//
//  MockURLProtocol.swift
//  CoreTests
//
//  Created by Tony He (CTR) on 2024/7/30.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    static var httpBody: Data?

    override class func canInit(with request: URLRequest) -> Bool {
        if request.httpMethod == "POST" {
            if let body = request.httpBody {
                httpBody = body
            } else if let bodyStream = request.httpBodyStream {
                // Convert bodyStream (InputStream) to Data
                httpBody = bodyStream.data
            }
        }
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        var mutableRequest = request
        if let body = httpBody {
            mutableRequest.httpBody = body
        }
        httpBody = nil // Reset after usage
        return mutableRequest
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler is unavailable.")
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // Required to override, but no-op for this example
    }
}

private extension InputStream {
    var data: Data {
        open()
        defer { close() }

        var data = Data()
        let bufferSize = 2048
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }

        while hasBytesAvailable {
            let read = read(buffer, maxLength: bufferSize)
            guard read > 0 else { break }
            data.append(buffer, count: read)
        }

        return data
    }
}
