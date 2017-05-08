//
//  SYNetworking.h
//  Telegraph
//
//  Created by yoyowill on 17/1/17.
//
//

#import <Foundation/Foundation.h>


typedef void (^HttpRequestSuccess)(NSDictionary * dictionary);
typedef void (^HttpRequestFail)(NSString * code);

@interface SYNetworking : NSObject



+(NSString *)httpRequestWithDic:(NSDictionary*)dict andURL:(NSURL*)url;



+(void)httpRequestWithURL:(NSURL*)url andHttpRequestSuccess:(HttpRequestSuccess)httpRequestSuccess  andHttpRequestFail:(HttpRequestFail)httpRequestFail;

@end
