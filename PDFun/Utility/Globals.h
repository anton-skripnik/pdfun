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
#define CELL_ID_WITH_SUFFIX(suffix)             @APP_SPECIFIC_ID_WITH_SUFFIX("tableviewcell." suffix)

// Assertion helpers.
#define NSASSERT_NOT_NIL(smth)                  NSAssert((smth) != nil, @"%s must not be nil!", #smth)
#define NSASSERT_OF_CLASS(smth, className)      NSAssert([smth isKindOfClass:[className class]], @"%s is expected to be of class %s instead of %@", #smth, #className, [[smth class] description])

// Neat logging macro.
#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...)
#endif


#endif
