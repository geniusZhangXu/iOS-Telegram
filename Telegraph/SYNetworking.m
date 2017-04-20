//
//  SYNetworking.m
//  Telegraph
//
//  Created by yoyowill on 17/1/17.
//
//


#import "SYNetworking.h"
#import "NSData+AES.h"

@implementation SYNetworking

+(NSString * )httpRequestWithDic:(NSDictionary*)dict andURL:(NSURL*)url{
    
    NSData * postData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:NULL];
    //加密：
    NSString *key = @"1234567812345678";
    postData = [postData AES256_Encrypt:key];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[postData newStringInBase64FromData] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:@"utf-8" forHTTPHeaderField:@"charset"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:15.0];
    
    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData *data, NSError *error){
      
      if(error){
          
          NSLog(@"文本内容上传失败");
          NSLog(@"%@",data);
          NSLog(@"%@",response);
        
      }else{
    
          NSLog(@"文本内容上传成功");
      }
    }];
    
    return @"200";
}

@end
