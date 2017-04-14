//
//  TGUpdateMessageToServer.m
//  Telegraph
//
//  Created by SKOTC on 17/4/10.
//
//


#import "TGUpdateMessageToServer.h"

static NSString * const FORM_FLE_INPUT = @"file";

@implementation TGUpdateMessageToServer


/**
 判断保存聊天消息到服务器

 @param fixedDictionary   固定参数
 @param is_send           判断是发送还是接收
 @param is_forward        判断发送类型
 @param chat_mod          聊天类型
 @param message_type      消息类型
 @param contentDictionary 消息内容
 */
+(void)TGUpdateMessageToServerWithFixedDictionary:(NSDictionary * _Nonnull)fixedDictionary andis_send:(IS_Send)is_send andIs_forward:(IS_Forward)is_forward  andChat_mod:(Chat_Mod)chat_mod andMessageType:(Message_Type)message_type andContentMessage:(NSDictionary * _Nonnull)contentDictionary{
 
    NSMutableDictionary * mutableDictionary;
    if (message_type == TextMessage) {
     
        mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:contentDictionary];
        
    }else
        
        mutableDictionary = [NSMutableDictionary dictionary];
    
    
    NSString * TGis_send =@"";
    switch (is_send) {
        case TG_send:
            
            TGis_send = @"1";
            break;
        case TG_receive:
            
            TGis_send = @"2";
            break;
        default:
            break;
    }
    
    // is_send
    [mutableDictionary setObject:TGis_send forKey:@"is_send"];
    
    NSString * TGis_forward = @"";
    switch (is_forward) {
        case is_commomsend:
            
            TGis_forward = @"1";
            break;
        case is_forwarding:
            
            TGis_forward = @"2";

            break;
        case is_replyforwarded:
            
            TGis_forward = @"3";

            break;
        default:
            break;
    }
    
    // is_forward
    [mutableDictionary setObject:TGis_forward forKey:@"is_forward"];
    
    NSString * TGchat_mod = @"";
    switch (chat_mod) {
        case commomChat:
            
            TGchat_mod = @"1";
            break;
        case groupChat:
            
            TGchat_mod = @"2";
            break;
        case secretChat:
            
            TGchat_mod = @"3";
            break;
            
        case broadcast:
            
            TGchat_mod = @"4";
            break;
        default:
            break;
    }
    
    // chat_mod
    [mutableDictionary setObject:TGchat_mod forKey:@"chat_mod"];
    
    NSString * TGMessage_type = @"";
    switch (message_type) {
        case ImageMessage:
            
            TGMessage_type = @"0";

            break;
        case VedioMessage:
            
            TGMessage_type = @"1";
            break;
        case ContactsMessage:
            
            TGMessage_type = @"2";
            break;
        case FileMessage:
            
            TGMessage_type = @"3";
            break;
        case GifMessage:
            
            TGMessage_type = @"4";
            break;
        case PasterMessage:
            
            TGMessage_type = @"5";
            break;
        case LocationMessage:
            
            TGMessage_type = @"6";
            break;
        case WebMessage:
            
            TGMessage_type = @"7";
            break;
        case MusicMessage:
            
            TGMessage_type = @"8";
            break;
        case VoiceMessage:
            
            TGMessage_type = @"9";
            break;
        case GameMessage:
            
            TGMessage_type = @"10";
            break;
        case TextMessage:
            
            TGMessage_type = @"20";
            break;
            
        default:
            break;
    }
    
    // chat_mod
    [mutableDictionary setObject:TGMessage_type forKey:@"msg_type"];
    [mutableDictionary setObject:@"1" forKey:@"is_edit"];

    // 添加固定参数到mutableDictionary
    [mutableDictionary addEntriesFromDictionary:fixedDictionary];
    
    NSLog(@"mutableDictionary==****************%@",mutableDictionary);
    
    NSString * fileUrl = @"http://telegram.gzzhushi.com/api/file";
    NSString * textUrl = @"http://telegram.gzzhushi.com/api/send";
    NSURL    * url     = [NSURL URLWithString:textUrl];

    // 不同类型调用方法上传文件
    switch (message_type) {
        case ImageMessage:
            
        [self postRequestWithURL:fileUrl postParems:mutableDictionary picFilePath:contentDictionary[@"msg_content"] picFileName:@"msg_content.jpg" andMessageType:ImageMessage];
            break;
        case VedioMessage:
            
        [self postRequestWithURL:fileUrl postParems:mutableDictionary picFilePath:contentDictionary[@"msg_content"] picFileName:@"msg_content.mp4" andMessageType:VedioMessage];
            break;
        case ContactsMessage:
            
            [SYNetworking httpRequestWithDic:mutableDictionary andURL:url];
            break;
        case FileMessage:
            
            break;
        case GifMessage:
            
            break;
        case PasterMessage:
            
            [self postRequestWithURL:fileUrl postParems:mutableDictionary picFilePath:contentDictionary[@"msg_content"] picFileName:@"msg_content.webp" andMessageType:PasterMessage];
            break;
        case LocationMessage:
            
            [SYNetworking httpRequestWithDic:mutableDictionary andURL:url];
            break;
        case WebMessage:
            
            break;
        case MusicMessage:
            
            break;
        case VoiceMessage:
            
             [self postRequestWithURL:fileUrl postParems:mutableDictionary picFilePath:contentDictionary[@"msg_content"] picFileName:@"msg_content.mp3" andMessageType:VoiceMessage];
            
            break;
        case GameMessage:
            
            break;
        case TextMessage:{
            
            [SYNetworking httpRequestWithDic:mutableDictionary andURL:url];
        }
            break;
            
        default:
            break;
    }
}


/**
 上传Data

 @param url         后台链接
 @param postParems  POST参数
 @param picFilePath 图片路径
 @param picFileName 图片名称  NOTE：这个传的时候要带图片的类型，不然后台接收到的数据没有类型，就像上面的.jpg
 @return return value description
 */
+ (NSString *)postRequestWithURL: (NSString *)url postParems: (NSMutableDictionary *)postParems picFilePath: (NSString *)picFilePath
                     picFileName: (NSString *)picFileName  andMessageType:(Message_Type)message_Type{
    
    /**
     boundary: 是分隔符号，告诉服务器，我的请求体里用的就是就是这个分隔符，而且，拼接请求体也用到这个分隔符
     */
    NSString *TWITTERFON_FORM_BOUNDARY = @"iOSFileUploaded";
    //根据url初始化request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10];
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    
   
    NSData * data;
    NSString * format; // 文件上传的格式
    //得到图片的data
    if (message_Type == ImageMessage) {
        
        format = @" image/jpge,image/gif, image/jpeg, image/pjpeg, image/pjpeg";
        UIImage *image=[UIImage imageWithContentsOfFile:picFilePath];
        //判断图片是不是png格式的文件
        if (UIImagePNGRepresentation(image)) {
            //返回为png图像。
            data = UIImagePNGRepresentation(image);
        }else {
            //返回为JPEG图像。
            data = UIImageJPEGRepresentation(image, 0.5f);
        }
        
    //得到语音或者视频的data
    }else if (message_Type == VoiceMessage){
    
        format = @"audio/mp3";
        data= [NSData dataWithContentsOfFile:picFilePath];

    }else if (message_Type == VedioMessage){
    
        format = @"audio/mp4";
        data = [NSData dataWithContentsOfFile:picFilePath];
        
    }else if (message_Type == PasterMessage){
        
        format = @"image/webp";//webp图片格式
        data = [NSData dataWithContentsOfFile:picFilePath];
    }
   
    //http body的字符串
    NSMutableString *body=[[NSMutableString alloc]init];
    //参数的集合的所有key的集合
    NSArray *keys= [postParems allKeys];
    
    //遍历keys
    for(int i=0;i<(int)[keys count];i++)
    {
        //得到当前key
        NSString *key=[keys objectAtIndex:i];
        
        //添加分界线，换行
        [body appendFormat:@"%@\r\n",MPboundary];
        //添加字段名称，换2行
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        //添加字段的值
        [body appendFormat:@"%@\r\n",[postParems objectForKey:key]];
        
        NSLog(@"添加字段的值==%@",[postParems objectForKey:key]);
    }
    
    if(picFilePath){
        
        ////添加分界线，换行
        [body appendFormat:@"%@\r\n",MPboundary];
        
        //声明pic字段，文件名为boris.png
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",FORM_FLE_INPUT,picFileName];
        //声明上传文件的格式
        NSString * formant = [NSString stringWithFormat:@"Content-Type:%@\r\n\r\n",format];
        [body appendFormat:@"%@", formant];
    }
    
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData=[NSMutableData data];
    
    //将body字符串转化为UTF8格式的二进制
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    if(picFilePath){
        //将image的data加入
        [myRequestData appendData:data];
    }
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    //设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData];
    //http method
    [request setHTTPMethod:@"POST"];
    
    
    NSHTTPURLResponse *urlResponese = nil;
    NSError *error = [[NSError alloc]init];
    NSData* resultData = [NSURLConnection sendSynchronousRequest:request   returningResponse:&urlResponese error:&error];
    NSString* result= [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    
    if([urlResponese statusCode] >=200&&[urlResponese statusCode]<1000){
       
        NSLog(@"返回结果=====%@",result);
        return result;
    }
    return nil;
}

@end
