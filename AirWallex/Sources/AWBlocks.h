//
//  AWBlocks.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#ifndef AWBlocks_h
#define AWBlocks_h

@protocol AWResponseProtocol;

typedef void (^AWRequestHandler)(id <AWResponseProtocol> _Nullable response, NSError * _Nullable error);

#endif /* AWBlocks_h */
