//
//  Cryptor.m
//  PDFun
//
//  Created by Anton Skripnik on 10/8/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "Cryptor.h"
#import "Globals.h"
#import <CommonCrypto/CommonCrypto.h>


#define ALGORITHM                   kCCAlgorithmAES128
#define ALGORITHM_BLOCK_SIZE        kCCBlockSizeAES128
#define SALT_LENGTH                 16
#define IV_LENGTH                   kCCBlockSizeAES128
#define KEY_LENGTH                  kCCKeySizeAES256
#define KEY_DERIVATION_FUNC         kCCPBKDF2
#define KEY_DERIVATION_PRF          kCCPRFHmacAlgSHA256
#define KEY_DERIVATION_ROUND_NUMBER 25347                   /* Just a large number I fancy=) */



NSString* const CryptorErrorDomain = @"CryptorErrorDomain";
NSString* const CCCryptorErrorDomain = @"CCCryptorErrorDomain";



@interface Cryptor (Private)

- (NSData *)_rubbishDataOfLength:(NSUInteger)length;
- (NSData *)_AESKeyWithPassword:(NSString *)password salt:(NSData *)salt;

@end

@implementation Cryptor

// TODO: Consider ensuring data integrity.
// Might need put additional info into the binary (hash or something) to check the data when decyphering it.
// TODO: Consider stream cyphering for large files.

- (void)encryptSourcePDFData:(NSData *)sourcePDFData
                intoBinaryAt:(NSString *)destinationBinaryPath
                withPassword:(NSString *)password
                  completion:(CryptorCompletionBlock)completion
{
    NSASSERT_NOT_NIL(sourcePDFData);
    NSASSERT_NOT_NIL(destinationBinaryPath);
    NSASSERT_NOT_NIL(password);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        NSData* iv = [self _rubbishDataOfLength:IV_LENGTH];
        if (!iv)
        {
            if (completion)
            {
                NSError* noIVError = [NSError errorWithDomain:CryptorErrorDomain code:CryptorErrorFailedToGenerateInitializationVector userInfo:@{ NSLocalizedDescriptionKey: @"Couldn't generate initialization vector" }];
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    completion(noIVError);
                });
            }
            return;
        }
        
        NSData* salt = [self _rubbishDataOfLength:SALT_LENGTH];
        if (!salt)
        {
            if (completion)
            {
                NSError* noSaltError = [NSError errorWithDomain:CryptorErrorDomain code:CryptorErrorFailedToGenerateSalt userInfo:@{ NSLocalizedDescriptionKey: @"Couldn't generate salt." }];
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    completion(noSaltError);
                });
            }
            return;
        }
        
        NSData* key = [self _AESKeyWithPassword:password salt:salt];
        if (!key)
        {
            if (completion)
            {
                NSError* noKeyError = [NSError errorWithDomain:CryptorErrorDomain code:CryptorErrorFailedToGenerateKey userInfo:@{ NSLocalizedDescriptionKey: @"Couldn't generate key." }];
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    completion(noKeyError);
                });
            }
            return;
        }
        
        NSUInteger prePDFDataLength = IV_LENGTH + SALT_LENGTH;
        // A general rule for the size of the output buffer which must be provided by the caller is that for block
        // ciphers, the output length is never larger than the input length plus the block size.
        // https://developer.apple.com/library/ios/documentation/System/Conceptual/ManPages_iPhoneOS/man3/CCCrypt.3cc.html
        NSUInteger cypheredPDFDataLength = sourcePDFData.length + ALGORITHM_BLOCK_SIZE;
        NSUInteger bufferLength = prePDFDataLength + cypheredPDFDataLength;
        NSMutableData* bufferData = [[NSMutableData alloc] init];
        [bufferData appendData:iv];
        [bufferData appendData:salt];
        NSAssert(bufferData.length == prePDFDataLength, @"Unexpected prePDFData length!");
        
        bufferData.length = bufferLength;
        
        // As per http://stackoverflow.com/questions/3523145/pointer-arithmetic-for-void-pointer-in-c
        // pointer arithmetics is forbidden on void*, so cast the -mutableBytes result to char* to determine
        // the pdf data start address.
        void* pdfDataPointer = (char *)bufferData.mutableBytes + prePDFDataLength;
        
        size_t actualCypheredDataLength = 0;
        CCCryptorStatus status = CCCrypt(kCCEncrypt,
                                         ALGORITHM,
                                         kCCOptionPKCS7Padding,
                                         key.bytes,
                                         key.length,
                                         iv.bytes,
                                         sourcePDFData.bytes,
                                         sourcePDFData.length,
                                         pdfDataPointer,
                                         cypheredPDFDataLength,
                                         &actualCypheredDataLength);
        if (status != kCCSuccess)
        {
            NSError* cccryptorError = [NSError errorWithDomain:CCCryptorErrorDomain code:status userInfo:nil];
            DLog(@"Error while trying to encrypt %@: %@", destinationBinaryPath, cccryptorError);
            if (completion)
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    completion(cccryptorError);
                });
            }
            
            return;
        }
        
        NSAssert(cypheredPDFDataLength >= actualCypheredDataLength, @"Man page lied!");
        bufferData.length = bufferLength - (cypheredPDFDataLength - actualCypheredDataLength);
        
        NSError* destinationBinaryWriteError = nil;
        if (![bufferData writeToFile:destinationBinaryPath options:0 error:&destinationBinaryWriteError])
        {
            DLog(@"Error while writing down cyphered data at %@: %@", destinationBinaryPath, destinationBinaryWriteError);
            if (completion)
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    completion(destinationBinaryWriteError);
                });
            }
            
            return;
        }
        
        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                completion(nil);
            });
        }
    });
}

- (void)decryptSourceBinaryAt:(NSString *)sourceBinaryPath
                  intoPDFData:(NSMutableData *)desinationPDFData
                 withPassword:(NSString *)password
                   completion:(CryptorCompletionBlock)completion
{
    NSASSERT_NOT_NIL(sourceBinaryPath);
    NSASSERT_NOT_NIL(desinationPDFData);
    NSASSERT_NOT_NIL(password);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        NSError* sourceBinaryReadingError = nil;
        NSData* sourceBinaryData = [NSData dataWithContentsOfFile:sourceBinaryPath
                                                          options:0
                                                            error:&sourceBinaryReadingError];
        if (!sourceBinaryData)
        {
            DLog(@"Error reading source binary %@: %@", sourceBinaryPath, sourceBinaryReadingError);
            if (completion)
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    completion(sourceBinaryReadingError);
                });
            }
            return;
        }
        
        if (sourceBinaryData.length < IV_LENGTH)
        {
            if (completion)
            {
                NSError* unexpectedEndOfBinaryDataError = [NSError errorWithDomain:CryptorErrorDomain code:CryptorErrorUnexpectedEndOfBinaryData userInfo:@{ NSLocalizedDescriptionKey: @"Ran out of binary data while extracting initialization vector." }];
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    completion(unexpectedEndOfBinaryDataError);
                });
            }
            return;
        }
        NSData* iv = [sourceBinaryData subdataWithRange:NSMakeRange(0, IV_LENGTH)];
        
        if (sourceBinaryData.length < IV_LENGTH + SALT_LENGTH)
        {
            if (completion)
            {
                NSError* unexpectedEndOfBinaryDataError = [NSError errorWithDomain:CryptorErrorDomain code:CryptorErrorUnexpectedEndOfBinaryData userInfo:@{ NSLocalizedDescriptionKey: @"Ran out of binary data while extracting salt value." }];
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    completion(unexpectedEndOfBinaryDataError);
                });
            }
            return;
        }
        NSData* salt = [sourceBinaryData subdataWithRange:NSMakeRange(IV_LENGTH, SALT_LENGTH)];
        
        if (sourceBinaryData.length - (IV_LENGTH + SALT_LENGTH) <= 0)
        {
            if (completion)
            {
                NSError* unexpectedEndOfBinaryDataError = [NSError errorWithDomain:CryptorErrorDomain code:CryptorErrorUnexpectedEndOfBinaryData userInfo:@{ NSLocalizedDescriptionKey: @"Ran out of binary data while extracting PDF data." }];
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    completion(unexpectedEndOfBinaryDataError);
                });
            }
            return;
        }
        NSData* pdfData = [sourceBinaryData subdataWithRange:NSMakeRange(IV_LENGTH + SALT_LENGTH, sourceBinaryData.length - (IV_LENGTH + SALT_LENGTH))];
        
        NSData* key = [self _AESKeyWithPassword:password salt:salt];
        if (!key)
        {
            if (completion)
            {
                NSError* noKeyError = [NSError errorWithDomain:CryptorErrorDomain code:CryptorErrorFailedToGenerateKey userInfo:@{ NSLocalizedDescriptionKey: @"Couldn't generate key." }];
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    completion(noKeyError);
                });
            }
            return;
        }
        
        // A general rule for the size of the output buffer which must be provided by the caller is that for block
        // ciphers, the output length is never larger than the input length plus the block size.
        // https://developer.apple.com/library/ios/documentation/System/Conceptual/ManPages_iPhoneOS/man3/CCCrypt.3cc.html
        NSUInteger bufferLength = pdfData.length + ALGORITHM_BLOCK_SIZE;
        desinationPDFData.length = bufferLength;
        size_t actualDecryptedDataLength = 0;
        CCCryptorStatus status = CCCrypt(kCCDecrypt,
                                         ALGORITHM,
                                         kCCOptionPKCS7Padding,
                                         key.bytes,
                                         key.length,
                                         iv.bytes,
                                         pdfData.bytes,
                                         pdfData.length,
                                         desinationPDFData.mutableBytes,
                                         desinationPDFData.length,
                                         &actualDecryptedDataLength);
        if (status != kCCSuccess)
        {
            NSError* cccryptorError = [NSError errorWithDomain:CCCryptorErrorDomain code:status userInfo:nil];
            DLog(@"Error while trying to decrypt %@: %@", sourceBinaryPath, cccryptorError);
            if (completion)
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    completion(cccryptorError);
                });
            }
            
            return;
        }
        
        NSAssert(bufferLength >= actualDecryptedDataLength, @"Man page lied!");
        desinationPDFData.length = actualDecryptedDataLength;
        
        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                completion(nil);
            });
        }
        
    });
}

@end

#pragma mark - Private methods -

@implementation Cryptor (Private)

- (NSData *)_rubbishDataOfLength:(NSUInteger)length
{
    NSMutableData* resultData = [[NSMutableData alloc] initWithLength:length];
    int result = SecRandomCopyBytes(kSecRandomDefault, length, resultData.mutableBytes);
    if (result != 0)
    {
        DLog(@"Error generating random data! Code %d", errno);
        return nil;
    }
    return resultData;
}

- (NSData *)_AESKeyWithPassword:(NSString *)password salt:(NSData *)salt
{
    NSMutableData* keyData = [[NSMutableData alloc] initWithLength:KEY_LENGTH];
    int result = CCKeyDerivationPBKDF(KEY_DERIVATION_FUNC,
                                      password.UTF8String,
                                      [password lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                      salt.bytes,
                                      salt.length,
                                      KEY_DERIVATION_PRF,
                                      KEY_DERIVATION_ROUND_NUMBER,
                                      keyData.mutableBytes,
                                      keyData.length);
    if (result == kCCSuccess)
    {
        return keyData;
    }
    else
    {
        DLog(@"Error generating AES key. Code: %d", result);
        return nil;
    }
}

@end
