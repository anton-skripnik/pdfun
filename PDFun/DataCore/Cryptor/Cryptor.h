//
//  Cryptor.h
//  PDFun
//
//  Created by Anton Skripnik on 10/8/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import <Foundation/Foundation.h>

// Generic completion block definition.
// CONVENTION: error == nil means everything went well.
typedef void(^CryptorCompletionBlock)(NSError* error);


extern NSString* const CryptorErrorDomain;
NS_ENUM(NSUInteger, CryptorError)
{
    CryptorErrorUnknown,
    CryptorErrorFailedToGenerateInitializationVector,
    CryptorErrorFailedToGenerateSalt,
    CryptorErrorFailedToGenerateKey,
    CryptorErrorUnexpectedEndOfBinaryData,
};
// For errors from Common Crypto code.
extern NSString* const CCCryptorErrorDomain;


//
//  Class manages encryption and decryption of PDF data in files given a password. The operations are
//  asynchronous and completion is invoked on main thread upon finish.
//
@interface Cryptor : NSObject

- (void)encryptSourcePDFData:(NSData *)sourcePDFData
                intoBinaryAt:(NSString *)destinationBinaryPath
                withPassword:(NSString *)password
                  completion:(CryptorCompletionBlock)completion;

- (void)decryptSourceBinaryAt:(NSString *)sourceBinaryPath
                  intoPDFData:(NSMutableData *)desinationPDFData
                 withPassword:(NSString *)password
                   completion:(CryptorCompletionBlock)completion;

@end
