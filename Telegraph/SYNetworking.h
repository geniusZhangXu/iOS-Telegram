//
//  SYNetworking.h
//  Telegraph
//
//  Created by yoyowill on 17/1/17.
//
//

#import <Foundation/Foundation.h>

@interface SYNetworking : NSObject


+(void)httpRequestWithDic:(NSDictionary*)dict andURL:(NSURL*)url;


+(void)upload:(NSString *)filename mimeType:(NSString *)mimeType fileData:(NSData *)fileData params:(NSDictionary *)params URL:(NSString *)REQUEST_URL;


@end
