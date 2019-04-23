#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CustomUiKit.h"

FOUNDATION_EXPORT double CustomUiKitVersionNumber;
FOUNDATION_EXPORT const unsigned char CustomUiKitVersionString[];

