//
//  TGForwardMessageUploaded.m
//  Telegraph
//
//  Created by SKOTC on 17/4/25.
//
//

#import "TGForwardMessageUploaded.h"

@implementation TGForwardMessageUploaded


/**
 判断转发的消息类型拼接参数调用上传方法

 @param preparedMessage        发送的消息
 @param toUid                  接收者的UID
 @param messageInfoDictionary  这个字典传的是群聊或者广播消息的群名称，频道ID等相关的信息
 @param chat_mod               聊天的类型
 */
+(void)UploadForwardMessageToServeWithMessage:(TGPreparedForwardedMessage *)preparedMessage andToUid:(int32_t)toUid  andGroupMessageInfo:(NSDictionary *)messageInfoDictionary  andChatMod:(Chat_Mod)chat_mod{
  
    TGPreparedForwardedMessage * forwardedMessage = (TGPreparedForwardedMessage *)preparedMessage;
    
    TGUser  * selfUser   = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId];
    TGUser  * toUser     = [TGDatabaseInstance() loadUser:toUid];
    TGUser  * fromUser   = [TGDatabaseInstance() loadUser:(int)forwardedMessage.innerMessage.fromUid];
    
    NSLog(@"我是转发的消息接收 %@",toUser.firstName);
    NSLog(@"我是转发的消息接收 %d",toUser.uid);
    NSLog(@"我是转发的消息接收 %@",toUser.lastName);
    
    NSLog(@"我是转发的消息来源者 %@",fromUser.firstName);
    NSLog(@"我是转发的消息来源者 %d",fromUser.uid);
    NSLog(@"我是转发的消息来源者 %@",fromUser.lastName);
    
    // 转发文本类型
    if(![forwardedMessage.innerMessage.text isEqualToString:@""]) {
        
        NSDictionary * fixDictionary =  [TGUpdateMessageToServer ForwardOrRepalyMessageFromuid:selfUser.uid toUid:toUser.uid md5:nil andChat_mod:chat_mod andChatDictionary:messageInfoDictionary andMessageType:TextMessage andIS_Forward:is_forwarding andUid:[NSString stringWithFormat:@"%d",fromUser.uid] andFirstname:fromUser.firstName andLastname:fromUser.lastName andUsername:fromUser.userName andMessageExternDictionary:nil andRf_Content:forwardedMessage.innerMessage.text andCaption:@""];
        
        [TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_send andIs_forward:is_commomsend andChat_mod:chat_mod andMessageType:TextMessage andContentMessage:@{@"msg_content":forwardedMessage.innerMessage.text}];
    
    // 转发其他类型
    }else{
        
        for(TGMediaAttachment * attachment in forwardedMessage.innerMessage.mediaAttachments){
            
            // 本地语音、文件、贴纸表情
            if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]){
                
                TGDocumentMediaAttachment * documentAttachment = (TGDocumentMediaAttachment *)attachment;
                NSString * updatedDocumentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:documentAttachment.documentId version:documentAttachment.version];
                NSString * filePath = [NSString stringWithFormat:@"%@/%@",updatedDocumentDirectory,[documentAttachment fileName]];
                NSData   * fileData = [NSData dataWithContentsOfFile:filePath];
                NSLog(@"我是转发的消息 voicePath =======%@",filePath);
                Message_Type messageType;
                // 语音转发
                if ([documentAttachment isVoice]) {
                    
                    messageType = VoiceMessage;
                //贴纸表情转发
                }else if ([documentAttachment isStickerWithPack]){
                
                    messageType = PasterMessage;
                    
                // 文件转发
                }else{
                
                    messageType = FileMessage;
                }
                
                
                // 添加说明的文字
                NSString * messageCaption = [NSString stringWithFormat:@"%@",documentAttachment.caption];
                if (!messageCaption || [messageCaption isEqualToString:@""]) {
                    
                    messageCaption = @"";
                }
                
                NSDictionary * fixDictionary =  [TGUpdateMessageToServer ForwardOrRepalyMessageFromuid:selfUser.uid toUid:toUser.uid md5:TGImageHash(fileData) andChat_mod:chat_mod andChatDictionary:messageInfoDictionary andMessageType:messageType andIS_Forward:is_forwarding andUid:[NSString stringWithFormat:@"%d",fromUser.uid] andFirstname:fromUser.firstName andLastname:fromUser.lastName andUsername:fromUser.userName andMessageExternDictionary:nil andRf_Content:forwardedMessage.innerMessage.text andCaption:messageCaption];
                
                [TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_send andIs_forward:is_forwarding andChat_mod:chat_mod andMessageType:messageType andContentMessage:@{@"msg_content":filePath,@"filename":documentAttachment.fileName}];
                
            // 图片
            }else if ([attachment isKindOfClass:[TGImageMediaAttachment class]]){
                
                TGImageMediaAttachment * imageAttachment = (TGImageMediaAttachment *)attachment;
                NSString * imagePath = [self filePathForRemoteImageId:imageAttachment.imageId];
                NSLog(@"我是转发的消息 imagePath =======%@",imagePath);
                
                NSData   * imageData = [NSData dataWithContentsOfFile:imagePath];
                
                // 添加说明的文字
                NSString * messageCaption = [NSString stringWithFormat:@"%@",imageAttachment.caption];
                if (!messageCaption || [messageCaption isEqualToString:@""]) {
                    
                    messageCaption = @"";
                }
                
                
                NSDictionary * fixDictionary =  [TGUpdateMessageToServer ForwardOrRepalyMessageFromuid:selfUser.uid toUid:toUser.uid md5:TGImageHash(imageData) andChat_mod:chat_mod andChatDictionary:messageInfoDictionary andMessageType:ImageMessage andIS_Forward:is_forwarding andUid:[NSString stringWithFormat:@"%d",fromUser.uid] andFirstname:fromUser.firstName andLastname:fromUser.lastName andUsername:fromUser.userName andMessageExternDictionary:nil andRf_Content:forwardedMessage.innerMessage.text andCaption:messageCaption];
                
                [TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_send andIs_forward:is_forwarding andChat_mod:chat_mod andMessageType:ImageMessage andContentMessage:@{@"msg_content":imagePath}];
                
                
            // 视频
            }else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]]){
                
                TGVideoMediaAttachment * videoAttachment = (TGVideoMediaAttachment *)attachment;
                NSString * documentsDirectory = [TGAppDelegate documentsPath];
                NSString * videosDirectory    = [documentsDirectory stringByAppendingPathComponent:@"video"];
                if (![[NSFileManager defaultManager] fileExistsAtPath:videosDirectory])
                    
                    [[NSFileManager defaultManager] createDirectoryAtPath:videosDirectory withIntermediateDirectories:true attributes:nil error:nil];
                
                NSString * updatedVideoPath    = [videosDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"remote%llx.mov", videoAttachment.videoId]];
                
                NSLog(@"我是转发的消息 updatedVideoPath =======%@",updatedVideoPath);
                
                // 添加说明的文字
                NSString * messageCaption = [NSString stringWithFormat:@"%@",videoAttachment.caption];
                if (!messageCaption || [messageCaption isEqualToString:@""]) {
                    
                    messageCaption = @"";
                }
                
                //转发的视频Data
                NSData   * vedioData = [NSData dataWithContentsOfFile:updatedVideoPath];
                NSDictionary * fixDictionary =  [TGUpdateMessageToServer ForwardOrRepalyMessageFromuid:selfUser.uid toUid:toUser.uid md5:TGImageHash(vedioData) andChat_mod:chat_mod andChatDictionary:messageInfoDictionary andMessageType:VedioMessage andIS_Forward:is_forwarding andUid:[NSString stringWithFormat:@"%d",fromUser.uid] andFirstname:fromUser.firstName andLastname:fromUser.lastName andUsername:fromUser.userName andMessageExternDictionary:nil andRf_Content:forwardedMessage.innerMessage.text andCaption:messageCaption];
                
                [TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_send andIs_forward:is_forwarding andChat_mod:chat_mod andMessageType:VedioMessage andContentMessage:@{@"msg_content":updatedVideoPath}];
            
            // 位置信息
            }else if ([attachment isKindOfClass:[TGLocationMediaAttachment class]]){
            
                TGLocationMediaAttachment * LocationAttachment = (TGLocationMediaAttachment *)attachment;
                //******上传位置到服务器
                NSString     * longitude     = [NSString stringWithFormat:@"%f",LocationAttachment.longitude];
                NSString     * latitude      = [NSString stringWithFormat:@"%f", LocationAttachment.latitude];
                NSDictionary * locationDic   = @{@"longitude":longitude,@"latitude":latitude};
                // 把位置信息转化成Json字符串
                NSString * locationString = [TGUpdateMessageToServer convertToJsonData:locationDic];
                
                NSDictionary * fixDictionary =  [TGUpdateMessageToServer ForwardOrRepalyMessageFromuid:selfUser.uid toUid:toUser.uid md5:nil andChat_mod:chat_mod andChatDictionary:messageInfoDictionary andMessageType:LocationMessage andIS_Forward:is_forwarding andUid:[NSString stringWithFormat:@"%d",fromUser.uid] andFirstname:fromUser.firstName andLastname:fromUser.lastName andUsername:fromUser.userName andMessageExternDictionary:nil andRf_Content:locationString andCaption:@""];
                
                [TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_send andIs_forward:is_forwarding andChat_mod:chat_mod andMessageType:LocationMessage andContentMessage:@{@"msg_content":locationString}];
                
            // 联系人信息
            }else if ([attachment isKindOfClass:[TGContactMediaAttachment class]]){
            
                TGContactMediaAttachment *  contactMediaAttachment = (TGContactMediaAttachment *)attachment;
                // 发送联系方式
                NSDictionary * contactDictionary = @{@"card_firstname":contactMediaAttachment.firstName,@"card_lastname":contactMediaAttachment.lastName,@"card_phone":contactMediaAttachment.phoneNumber};
                // 把联系人转化成Json字符串
                NSString * contactString = [TGUpdateMessageToServer convertToJsonData:contactDictionary];
                
                NSDictionary * fixDictionary =  [TGUpdateMessageToServer ForwardOrRepalyMessageFromuid:selfUser.uid toUid:toUser.uid md5:nil andChat_mod:chat_mod andChatDictionary:messageInfoDictionary andMessageType:ContactsMessage andIS_Forward:is_forwarding andUid:[NSString stringWithFormat:@"%d",fromUser.uid] andFirstname:fromUser.firstName andLastname:fromUser.lastName andUsername:fromUser.userName andMessageExternDictionary:nil andRf_Content:contactString andCaption:@""];
                
                [TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_send andIs_forward:is_forwarding andChat_mod:chat_mod andMessageType:ContactsMessage andContentMessage:@{@"msg_content":contactString}];
            
            }
          }
    }
}


+(NSString *)filePathForRemoteImageId:(int64_t)remoteImageId{
    
    static NSString *filesDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        filesDirectory = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"files"];
    });
    
    NSString *photoDirectoryName = [[NSString alloc] initWithFormat:@"image-remote-%" PRIx64 "", remoteImageId];
    NSString *photoDirectory = [filesDirectory stringByAppendingPathComponent:photoDirectoryName];
    
    NSString *imagePath = [photoDirectory stringByAppendingPathComponent:@"image.jpg"];
    return imagePath;
}


@end
