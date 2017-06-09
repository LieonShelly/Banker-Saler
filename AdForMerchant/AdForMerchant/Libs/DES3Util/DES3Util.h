//
//  DES3Util.h
//  SiteSeven
//
//  Created by niko on 8/14/14.
//  Copyright (c) 2014 bravesoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DES3Util : NSObject
+ (NSString *)AES128Encrypt:(NSString *)plainText key:(NSString *)key andIv:(NSString *)ivKey;
+ (NSString*) AES128Decrypt:(NSString *)encryptText key:(NSString *)key andIv:(NSString *)ivStr;
@end
