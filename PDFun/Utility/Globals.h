//
//  Globals.h
//  PDFun
//
//  Created by Anton Skripnik on 10/8/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#ifndef PDFun_Globals_h
#define PDFun_Globals_h

// Different identifiers.
#define APP_SPECIFIC_ID_WITH_SUFFIX(suffix)     ("com.diddlydoo.pdffun." suffix)
#define CELL_ID_WITH_SUFFIX(suffix)             @APP_SPECIFIC_ID_WITH_SUFFIX("cell." suffix)

// Assertion helpers.
#define NSASSERT_NOT_NIL(smth)                  NSAssert((smth) != nil, @"%s must not be nil!", #smth)
#define NSASSERT_OF_CLASS(smth, className)      NSAssert([smth isKindOfClass:[className class]], @"%s is expected to be of class %s instead of %@", #smth, #className, [[smth class] description])

// Neat logging macro.
#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...)
#endif

// Placing following instruction inside some need-to-be-overriden method will remind a developer the necessity of overriding it
#define ENSURE_METHOD_IS_OVERRIDEN \
    @throw [NSException exceptionWithName:NSInternalInconsistencyException  \
                                   reason:[NSString stringWithFormat:@"You must override %s in %@ and make sure that super's method is not called", __func__, [[self class] description]] \
                                 userInfo:nil]

#define MINIMAL_PASSWORD_LENGTH                     8

#endif
