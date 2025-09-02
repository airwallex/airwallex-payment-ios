//
//  AWXAPIClient+Extension.swift
//  AirwallexPayment
//
//  Created by Weiping Li on 28/8/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

#if canImport(AirwallexCore)
import AirwallexCore
#endif
import Foundation

extension AWXAPIClient {
    /// Generic function to send request
    /// - Parameter request: Request object
    /// - Returns: Response object
    func sendRequest<Req: AWXRequest, Res: AWXResponse>(_ request: Req) async throws -> Res {
        guard let response = try await send(request) as? Res else {
            throw NSError(
                domain: AWXSDKErrorDomain,
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "failed to parse response for \(request.path())"
                ]
            )
        }
        return response
    }
}
