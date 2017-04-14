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



+(void)httpRequestWithDic:(NSDictionary*)dict andURL:(NSURL*)url{
    
    
    NSData * postData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:NULL];
    //[postData writeToFile:@"/Users/yoyowill/Desktop/sssssss/xxx" atomically:false];
    //加密：
    NSString *key = @"1234567812345678";
    postData = [postData AES256_Encrypt:key];
    // [postData writeToFile:@"/Users/yoyowill/Desktop/sssssss/aa" atomically:false];
    // NSLog(@"!!!!~~NSData加密+base64+++ postData: %@",[postData newStringInBase64FromData]);

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[postData newStringInBase64FromData] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:@"utf-8" forHTTPHeaderField:@"charset"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:15.0];
    
    //[bStr release];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               
       if (error) {
           
           NSLog(@"发送消息上传失败error:%@%ld", error.localizedDescription,error.code);
       
       }else{
           
           NSInteger responseCode   = [(NSHTTPURLResponse *)response statusCode];
           NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
           
           NSLog(@"发送消息上传成功:%ld", responseCode);
           NSLog(@"发送消息上传成功%@",responseString);
       }
   }];
}


#define MJFileBoundary @"MalJob"
#define MJNewLine @"\r\n"
#define MJEncode(str) [str dataUsingEncoding:NSUTF8StringEncoding]




+(void)upload:(NSString *)filename mimeType:(NSString *)mimeType fileData:(NSData *)fileData params:(NSDictionary *)params URL:(NSString *)REQUEST_URL{
    
    // 1.请求路径
    NSURL *url = [NSURL URLWithString:REQUEST_URL];
    
    // 2.创建一个POST请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    // 3.设置请求体
    NSMutableData *body = [NSMutableData data];
    
    // 3.1.文件参数
    [body appendData:MJEncode(@"--")];
    [body appendData:MJEncode(MJFileBoundary)];
    [body appendData:MJEncode(MJNewLine)];
    
    NSString *disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"", filename];
    [body appendData:MJEncode(disposition)];
    [body appendData:MJEncode(MJNewLine)];
    
    NSString *type = [NSString stringWithFormat:@"Content-Type: %@", mimeType];
    [body appendData:MJEncode(type)];
    [body appendData:MJEncode(MJNewLine)];
    
    [body appendData:MJEncode(MJNewLine)];
    [body appendData:fileData];
    [body appendData:MJEncode(MJNewLine)];
    
    // 3.2.非文件参数
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        [body appendData:MJEncode(@"--")];
        [body appendData:MJEncode(MJFileBoundary)];
        [body appendData:MJEncode(MJNewLine)];
        
        NSString *disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"", key];
        [body appendData:MJEncode(disposition)];
        [body appendData:MJEncode(MJNewLine)];
        
        [body appendData:MJEncode(MJNewLine)];
        [body appendData:MJEncode([obj description])];
        [body appendData:MJEncode(MJNewLine)];
    }];
    
    // 3.3.结束标记
    [body appendData:MJEncode(@"--")];
    [body appendData:MJEncode(MJFileBoundary)];
    [body appendData:MJEncode(@"--")];
    [body appendData:MJEncode(MJNewLine)];
    
    request.HTTPBody = body;
    
    // 4.设置请求头(告诉服务器这次传给你的是文件数据，告诉服务器现在发送的是一个文件上传请求)
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", MJFileBoundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    // 5.发送请求
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
           if (error) {
               
               NSLog(@"Httperror:%@%ld", error.localizedDescription,error.code);
           
           }else{
               
               NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
               NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
               
               NSLog(@"HttpResponseCode:%ld", responseCode);
               NSLog(@"HttpResponseBody %@",responseString);
           }
    }];
}

@end
