//
//  JGSTuner.h
//  JGSTuner
//
//  Created by 梅继高 on 2023/6/28.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

//! Project version number for JGSTuner.
FOUNDATION_EXPORT double JGSTunerVersionNumber;

//! Project version string for JGSTuner.
FOUNDATION_EXPORT const unsigned char JGSTunerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <JGSTuner/PublicHeader.h>



#if __has_include("JGSPCMBufferUtils.h")
#import "JGSPCMBufferUtils.h"
#elif __has_include(<JGSTuner/JGSPCMBufferUtils.h>)
#import <JGSTuner/JGSPCMBufferUtils.h>
#endif
