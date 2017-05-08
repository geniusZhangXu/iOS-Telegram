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
    
          // 3.解析服务器返回的数据（解析成字符串）
          NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
          NSLog(@"解析服务器返回的数据====%@", string);
      }
    }];
    
    return @"200";
}



+(void)httpRequestWithURL:(NSURL*)url andHttpRequestSuccess:(HttpRequestSuccess)httpRequestSuccess  andHttpRequestFail:(HttpRequestFail)httpRequestFail{
        
        //推荐使用这种请求方法，上面的方已经被废弃
        //下面的方法没有给Request设置请求头和内容，有需要参考上面的写法
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:[NSURLRequest requestWithURL:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
                if (!error) {
                        
                        //没有错误，返回正确
                        NSError * jsonError;
                        NSDictionary * dic =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                        if (!jsonError) {
                         
                                  httpRequestSuccess(dic);
                        }
                }else{
                        
                        //请求出现错误
                        httpRequestFail(@"请求错误");
                }
                
                NSLog(@"response==%@",response);
        }];
        
        [dataTask resume];
}



@end
