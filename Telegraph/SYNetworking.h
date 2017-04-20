//
//  SYNetworking.h
//  Telegraph
//
//  Created by yoyowill on 17/1/17.
//
//

#import <Foundation/Foundation.h>


typedef void (^HttpRequestSuccess)(NSString * code);
typedef void (^HttpRequestFail)(NSString * code);

@interface SYNetworking : NSObject

+(NSString *)httpRequestWithDic:(NSDictionary*)dict andURL:(NSURL*)url;

@end
