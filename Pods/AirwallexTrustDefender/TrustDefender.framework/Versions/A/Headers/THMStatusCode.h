/*!
 @header THMStatusCode.h

 The statuses that are used as indicators of profiling state.

 @author Nick Blievers
 @copyright 2017 ThreatMetrix. All rights reserved.
 */

#ifndef TrustDefender_THMStatusCode_h
#define TrustDefender_THMStatusCode_h

#if defined(__has_feature) && __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

/*!
 @typedef THMStatusCode

 Possible return codes
 @constant THMStatusCodeNotYet                   Profile request has returned but not yet completed.
 @constant THMStatusCodeOk                       Completed, No errors.
 @constant THMStatusCodeConnectionError          There was connection issue, profiling incomplete.
 @constant THMStatusCodeHostNotFoundError        Unable to resolve the host name of the fingerprint server.
 @constant THMStatusCodeNetworkTimeoutError      Network timed out.
 @constant THMStatusCodeHostVerificationError    Certificate verification or other SSL failure! Potential Man In The Middle attack.
 @constant THMStatusCodeInternalError            Internal Error, profiling incomplete or interrupted.
 @constant THMStatusCodeInterruptedError         Request was cancelled.
 @constant THMStatusCodePartialProfile           Connection error, only partial profile completed.
 @constant THMStatusCodeInvalidOrgID             Request contained an invalid org id.
 @constant THMStatusCodeInvalidParameter         A parameter was supplied that is not recognised by this version of the SDK (currently only used by Strong Auth)
 @constant THMStatusCodeStrongAuthOK             Registration/stepup was performed successfully
 @constant THMStatusCodeStrongAuthFailed         System has rejected registration/stepup attempt
 @constant THMStatusCodeStrongAuthCancelled      User has chosen not to proceed with registration/stepup
 @constant THMStatusCodeStrongAuthUnsupported    Local device is missing functionality required to execute Strong Auth request
 */
typedef NS_ENUM(NSInteger, THMStatusCode)
{
    THMStatusCodeStrongAuthOK = 0,
    THMStatusCodeNotYet = 0,
    THMStatusCodeOk,
    THMStatusCodeConnectionError,
    THMStatusCodeHostNotFoundError,
    THMStatusCodeNetworkTimeoutError,
    THMStatusCodeHostVerificationError,
    THMStatusCodeInternalError,
    THMStatusCodeInterruptedError,
    THMStatusCodePartialProfile,
    THMStatusCodeInvalidOrgID,
    THMStatusCodeNotConfigured,
    THMStatusCodeCertificateMismatch,
    THMStatusCodeInvalidParameter,
    THMStatusCodeStrongAuthFailed,
    THMStatusCodeStrongAuthCancelled,
    THMStatusCodeStrongAuthUnsupported,
    THMStatusCodeStrongAuthUserNotFound
};


#endif
