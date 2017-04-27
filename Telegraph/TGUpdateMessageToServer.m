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
+(NSString *)TGUpdateMessageToServerWithFixedDictionary:(NSDictionary * _Nonnull)fixedDictionary andis_send:(IS_Send)is_send andIs_forward:(IS_Forward)is_forward  andChat_mod:(Chat_Mod)chat_mod andMessageType:(Message_Type)message_type andContentMessage:(NSDictionary * _Nonnull)contentDictionary{
 
    NSMutableDictionary * mutableDictionary;
    if (message_type == TextMessage || message_type == LocationMessage || message_type == ContactsMessage) {
     
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
    __block NSString * result;
    // 不同类型调用方法上传文件
    switch (message_type) {
        case ImageMessage:
            
        result = [self postRequestWithURL:fileUrl postParems:mutableDictionary picFilePath:contentDictionary[@"msg_content"] picFileName:@"msg_content.jpg" andMessageType:ImageMessage andFileName:@""];
            
            break;
        case VedioMessage:
            
        result = [self postRequestWithURL:fileUrl postParems:mutableDictionary picFilePath:contentDictionary[@"msg_content"] picFileName:@"msg_content.mp4" andMessageType:VedioMessage andFileName:@""];
            break;
        case ContactsMessage:
            
           result =   [SYNetworking httpRequestWithDic:mutableDictionary andURL:url];
            
            break;
        case FileMessage:{
            
           /** 这里要判断文件的类型，保证后台打开文件的格式正确 **/
           NSString * fileName =  [NSString stringWithFormat:@"msg_content%@",[self GetFileType:contentDictionary[@"filename"]]];
           result = [self postRequestWithURL:fileUrl postParems:mutableDictionary picFilePath:contentDictionary[@"msg_content"] picFileName:fileName andMessageType:FileMessage andFileName:contentDictionary[@"filename"]];
        }
            break;
        case GifMessage:
            
            break;
        case PasterMessage:
            
           result =   [self postRequestWithURL:fileUrl postParems:mutableDictionary picFilePath:contentDictionary[@"msg_content"] picFileName:@"msg_content.webp" andMessageType:PasterMessage andFileName:@""];
            break;
        case LocationMessage:
            
           result =  [SYNetworking httpRequestWithDic:mutableDictionary andURL:url];
            
           break;
        case WebMessage:
            
           break;
        case MusicMessage:
            
           break;
        case VoiceMessage:
            
           result =   [self postRequestWithURL:fileUrl postParems:mutableDictionary picFilePath:contentDictionary[@"msg_content"] picFileName:@"msg_content.mp3" andMessageType:VoiceMessage andFileName:@""];
            
           break;
        case GameMessage:
            
            break;
        case TextMessage:{
            
            result =  [SYNetworking httpRequestWithDic:mutableDictionary andURL:url];
            
        }
            break;
            
        default:
            break;
    }
    
    NSLog(@"SYNetworking +%@",result);
    return result;
}


/**
 上传Data

 @param url         后台链接
 @param postParems  POST参数
 @param picFilePath 图片路径
 @param picFileName 图片名称  NOTE：这个传的时候要带图片的类型，不然后台接收到的数据没有类型，就像上面的.jpg
 @return return value description
 */
+ (NSString *)postRequestWithURL: (NSString *)url postParems: (NSMutableDictionary *)postParems picFilePath: (NSString *)picFilePath picFileName: (NSString *)picFileName  andMessageType:(Message_Type)message_Type andFileName:(NSString *)fileName{
    
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
        //返回为JPEG图像
        data = UIImageJPEGRepresentation(image, 0.3f);
        
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
        
    }else if (message_Type == FileMessage){
        
         format = [self GetContentType:fileName]; //文件格式
         data   = [NSData dataWithContentsOfFile:picFilePath];
    }
    
    // 在这里判断Data是否存在
    if (!data) {
        
        NSLog(@"data不存在");
        return @"data不存在";
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
    }
    
    if(picFileName){
        
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
    if(data){
        
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
    NSError * error = [[NSError alloc]init];
    NSData  * resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponese error:&error];
    
    NSDictionary * JSONresponseObject = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
    if ([[NSString stringWithFormat:@"%@",JSONresponseObject[@"errorCode"]] isEqualToString:@"0"]) {
        
        NSLog(@"上传成功!!!!!!!!!!!!!");
        return @"200";
    }
    return nil;
}


#pragma mark -- image转化成Base64位
-(NSString *)imageChangeBase64: (UIImage *)image{
    
    NSData   *imageData = nil;
    //NSString *mimeType  = nil;
    
    if ([self imageHasAlpha:image]) {
        
        imageData = UIImageJPEGRepresentation(image,0.3f);
        //mimeType = @"image/png";
        
    }else{
        
        imageData = UIImageJPEGRepresentation(image, 0.3f);
        //mimeType = @"image/jpeg";
    }
    return [NSString stringWithFormat:@"%@",[imageData base64EncodedStringWithOptions: 0]];
}


-(BOOL)imageHasAlpha:(UIImage *)image
{
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}



+(NSDictionary * _Nonnull)sentMediaToServerWithFromUid:(int64_t)fromuid toUid:(int64_t)touid md5:(NSString * _Nullable)md5  andChat_mod:(Chat_Mod)chat_mod andChatDictionary:(NSDictionary * _Nullable)chatDictionary{
    
    //**************************
    NSString * chatID  = @"";
    NSString * fromUid =[NSString stringWithFormat:@"%lld",fromuid];
    NSString * toUid   =[NSString stringWithFormat:@"%lld",touid];
    
    NSString * chatName         = @"";
    NSString * userName         = @"";
    NSString * firstName        = @"";
    NSString * lastName         = @"";
    NSString * channel_id       = @"";
    NSString * channel_name     = @"";
    NSString * selfuserName     = @"";
    NSString * selffirstName    = @"";
    NSString * selflastName     = @"";
    NSString * messageCaption   = @""; // 图片或者视频添加的说明
    
    if (chatDictionary[@"caption"] && ![chatDictionary[@"caption"] isEqualToString:@""]) {
        
        messageCaption = chatDictionary[@"caption"];
    }
    
    
    //生成当前时间戳
    NSDate   * date  = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval interval = [date timeIntervalSince1970]*1000 * 1000;
    NSString *timeStamp = [NSString stringWithFormat:@"%.0f", interval];//转为字符型
    
    TGUser * user        = [TGDatabaseInstance() loadUser:toUid.intValue];
    TGUser * selfUser    = [TGDatabaseInstance() loadUser:fromUid.intValue];;
    NSString * userPhone = user.phoneNumber;
    NSString * selfUserPhone = selfUser.phoneNumber;
    
    if (!user&&!selfUser) {
        
        return nil;
    }
    
    // 群聊接收者的电话和ToUid为空
    if (chat_mod == groupChat) {
        
        chatID    = [NSString stringWithFormat:@"%@",chatDictionary[@"chat_id"]];
        chatName  = [NSString stringWithFormat:@"%@",chatDictionary[@"chat_name"]];
        
        // 广播
    }else if (chat_mod == broadcast){
        
        channel_id    = [NSString stringWithFormat:@"%@",chatDictionary[@"channel_id"]];
        channel_name  = [NSString stringWithFormat:@"%@",chatDictionary[@"channel_name"]];
    }
    
    userName  = user.userName;
    firstName = user.firstName;
    lastName  = user.lastName;
    selfuserName  = selfUser.userName;
    selffirstName = selfUser.firstName;
    selflastName  = selfUser.lastName;
    
    
    if (![NSString isNonemptyString:selfUserPhone]){
        
        selfUserPhone = @"";
    }
    
    if (![NSString isNonemptyString:userPhone]){
        
        userPhone = @"";
    }
    
    if (![NSString isNonemptyString: selffirstName]){
        
        selffirstName = @"";
    }
    if (![NSString isNonemptyString: selflastName]){
        
        selflastName = @"";
    }
    
    if (![NSString isNonemptyString: selfuserName]){
        
        selfuserName = @"";
    }
    
    if (![NSString isNonemptyString: firstName]){
        
        firstName = @"";
    }
    
    if (![NSString isNonemptyString: lastName]){
        
        lastName = @"";
    }
    
    if (![NSString isNonemptyString: userName]){
        
        userName = @"";
    }
    
    if (![NSString isNonemptyString: md5]){
        
        md5 = @"";
    }
    
    NSLog(@"发送媒体消息，发送人ID：%@,接收者ID：%@ 发送者电话：%@  接收者电话 ：%@   %@  %@  %@  %@  %@  %@  %@",fromUid,toUid,selfUserPhone,userPhone,selfUser.firstName,selfUser.lastName,selfUser.userName,firstName,lastName,userName,md5);

    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setValue:fromUid forKey:@"s_uid"];
    [dict setValue:selfUserPhone forKey:@"s_phone"];
    [dict setValue:selfuserName forKey:@"s_username"];
    [dict setValue:selffirstName forKey:@"s_firstname"];
    [dict setValue:selflastName forKey:@"s_lastname"];
    [dict setValue:toUid forKey:@"r_uid"];
    [dict setValue:userPhone forKey:@"r_phone"];
    [dict setValue:userName forKey:@"r_username"];
    [dict setValue:firstName forKey:@"r_firstname"];
    [dict setValue:lastName forKey:@"r_lastname"];
    [dict setValue:md5 forKey:@"md5_value"];
    [dict setValue:chatID forKey:@"chat_id"];
    [dict setValue:chatName forKey:@"chat_name"];
    [dict setValue:timeStamp forKey:@"timestamp"];
    [dict setValue:@"3" forKey:@"device"];
    [dict setValue:channel_id forKey:@"channel_id"];
    [dict setValue:channel_name forKey:@"channel_name"];
    
    if (![messageCaption isEqualToString:@""] && messageCaption) {
        
        [dict setValue:messageCaption forKey:@"msg_content"]; // 视频或者图片的说明内容

    }
    return dict;
}




+(NSDictionary *)ForwardOrRepalyMessage:(int64_t)fromuid toUid:(int64_t)touid md5:(NSString * _Nullable)md5  andChat_mod:(Chat_Mod)chat_mod andChatDictionary:(NSDictionary * _Nullable)chatDictionary andMessageType:(Message_Type)message_type andIS_Forward:(IS_Forward)is_forward  andUid:(NSString * )uid andFirstname:(NSString * )firstname  andLastname:(NSString * )lastname  andUsername:(NSString * )username andMessageExternDictionary:(NSDictionary *)dictionary {

    NSDictionary * messageDictionary = [self sentMediaToServerWithFromUid:fromuid toUid:touid md5:md5 andChat_mod:chat_mod andChatDictionary:chatDictionary];
    
    NSString * rf_type = @"";
    NSString * replay_content = @"";
    switch (message_type) {
        case ImageMessage:
            
            rf_type = @"0";
            
            break;
        case VedioMessage:
            
            rf_type = @"1";
            break;
        case ContactsMessage:
            
            rf_type = @"2";
            break;
        case FileMessage:
            
            rf_type = @"3";
            break;
        case GifMessage:
            
            rf_type = @"4";
            break;
        case PasterMessage:
            
            rf_type = @"5";
            break;
        case LocationMessage:
            
            rf_type = @"6";
            break;
        case WebMessage:
            
            rf_type = @"7";
            break;
        case MusicMessage:
            
            rf_type = @"8";
            break;
        case VoiceMessage:
            
            rf_type = @"9";
            break;
        case GameMessage:
            
            rf_type = @"10";
            break;
        case TextMessage:
            
            rf_type = @"20";
            break;
            
        default:
            break;
    }

    
    NSMutableDictionary *  mutableDictionary =[NSMutableDictionary dictionary];
    switch (is_forward) {
        case is_forwarding:    // 转发
        {
            
            NSString * forward_uid = uid;
            NSString * forward_firstname = firstname;
            NSString * forward_lastname  = lastname;
            NSString * forward_username  = username;
            
            
            [mutableDictionary setValue:forward_uid forKey:@"forward_uid"];
            [mutableDictionary setValue:forward_firstname forKey:@"forward_firstname"];
            [mutableDictionary setValue:forward_lastname forKey:@"forward_lastname"];
            [mutableDictionary setValue:forward_username forKey:@"forward_username"];
        }
        break;
        case is_replyforwarded: // 回复
        {
            
            NSString * replay_uid = uid;
            NSString * replay_firstname = firstname;
            NSString * replay_lastname  = lastname;
            NSString * replay_username  = username;
            
            
            [mutableDictionary setValue:replay_uid forKey:@"replay_uid"];
            [mutableDictionary setValue:replay_firstname forKey:@"replay_firstname"];
            [mutableDictionary setValue:replay_lastname forKey:@"replay_lastname"];
            [mutableDictionary setValue:replay_username forKey:@"replay_username"];
            [mutableDictionary setValue:replay_content forKey:@"replay_content"];      // 回复消息，要是是文件就放文件说明
            [mutableDictionary setValue:rf_type forKey:@"rf_type"];                    // 被回复消息类型

        }
        break;
        default:
            break;
    }
    
    NSMutableDictionary *  MessageMutableDictionary =[NSMutableDictionary dictionaryWithDictionary:messageDictionary];
    [MessageMutableDictionary setValue:mutableDictionary forKey:@"msg_content"];
    
    if (dictionary) {
        
        [MessageMutableDictionary addEntriesFromDictionary:dictionary];
    }
    
    NSLog(@"MessageMutableDictionary === %@",MessageMutableDictionary);
    
    return MessageMutableDictionary;
}


/*** 根据文件类型判断上传的文件格式 ***/
+(NSString*)GetContentType:(NSString*)filename{
    
    if ([filename hasSuffix:@".avi"]) {
    
        return @"video/avi";
    }
    else if([filename hasSuffix:@".bmp"])
    {
        return @"application/x-bmp";
    }
    else if([filename hasSuffix:@"jpeg"])
    {
        return @"image/jpeg";
    }
    else if([filename hasSuffix:@"jpg"])
    {
        return @"image/jpeg";
    }
    else if([filename hasSuffix:@"png"])
    {
        return @"image/x-png";
    }
    else if([filename hasSuffix:@"mp3"])
    {
        return @"audio/mp3";
    }
    else if([filename hasSuffix:@"mp4"])
    {
        return @"video/mpeg4";
    }
    else if([filename hasSuffix:@"rmvb"])
    {
        return @"application/vnd.rn-realmedia-vbr";
    }
    else if([filename hasSuffix:@"txt"])
    {
        return @"text/plain";
    }
    else if([filename hasSuffix:@"xsl"])
    {
        return @"application/x-xls";
    }
    else if([filename hasSuffix:@"xslx"])
    {
        return @"application/x-xls";
    }
    else if([filename hasSuffix:@"xwd"])
    {
        return @"application/x-xwd";
    }
    else if([filename hasSuffix:@"doc"])
    {
        return @"application/msword";
    }
    else if([filename hasSuffix:@"docx"])
    {
        return @"application/msword";
    }
    else if([filename hasSuffix:@"ppt"])
    {
        return @"application/x-ppt";
    }
    else if([filename hasSuffix:@"pdf"])
    {
        return @"application/pdf";
    }
    return nil;
}


/*** 根据后缀名判断文件类型 ***/
+(NSString*)GetFileType:(NSString*)filename{
    
    if ([filename hasSuffix:@".avi"]) {
        
        return @".avi";
    }
    else if([filename hasSuffix:@".bmp"])
    {
        return @".bmp";
    }
    else if([filename hasSuffix:@"jpeg"])
    {
        return @"jpeg";
    }
    else if([filename hasSuffix:@"jpg"])
    {
        return @"jpg";
    }
    else if([filename hasSuffix:@"png"])
    {
        return @"png";
    }
    else if([filename hasSuffix:@"mp3"])
    {
        return @"mp3";
    }
    else if([filename hasSuffix:@"mp4"])
    {
        return @"mp4";
    }
    else if([filename hasSuffix:@"rmvb"])
    {
        return @"rmvb";
    }
    else if([filename hasSuffix:@"txt"])
    {
        return @"txt";
    }
    else if([filename hasSuffix:@"xsl"])
    {
        return @"xsl";
    }
    else if([filename hasSuffix:@"xslx"])
    {
        return @"xslx";
    }
    else if([filename hasSuffix:@"xwd"])
    {
        return @"xwd";
    }
    else if([filename hasSuffix:@"doc"])
    {
        return @"doc";
    }
    else if([filename hasSuffix:@"docx"])
    {
        return @"docx";
    }
    else if([filename hasSuffix:@"ppt"])
    {
        return @"ppt";
    }
    else if([filename hasSuffix:@"pdf"])
    {
        return @"pdf";
    }
    return nil;
}


@end
