//
//  JGSTuner.h
//  JGSTuner
//
//  Created by 梅继高 on 2023/5/31.
//

#import <Foundation/Foundation.h>

//! Project version number for JGSTuner.
FOUNDATION_EXPORT double JGSTunerVersionNumber;

//! Project version string for JGSTuner.
FOUNDATION_EXPORT const unsigned char JGSTunerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <JGSTuner/PublicHeader.h>

#if __has_include(<JGSTuner/JGSPitchDetector.h>)
#include <JGSTuner/JGSPitchDetector.h>
#else
#include "JGSPitchDetector.h"
#endif
