//
//  AWXProtocol.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

// For a magic reserved keyword color, use @defs(your_protocol_name)
#define defs _protocol_extension

// Interface
#define _protocol_extension($protocol) _protocol_extension_imp($protocol, _protocol_get_container_class($protocol))

// Implementation
#define _protocol_extension_imp($protocol, $container_class) \
protocol $protocol; \
@interface $container_class : NSObject <$protocol> @end \
@implementation $container_class \
+ (void)load { \
_protocol_extension_load(@protocol($protocol), $container_class.class); \
} \

// Get container class name by counter
#define _protocol_get_container_class($protocol) _protocol_get_container_class_imp($protocol, __COUNTER__)
#define _protocol_get_container_class_imp($protocol, $counter) _protocol_get_container_class_imp_concat(__protocolContainer_, $protocol, $counter)
#define _protocol_get_container_class_imp_concat($a, $b, $c) $a ## $b ## _ ## $c

void _protocol_extension_load(Protocol *protocol, Class containerClass);
