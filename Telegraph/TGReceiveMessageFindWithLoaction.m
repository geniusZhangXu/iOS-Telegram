//
//  TGReceiveMessageFindWithLoaction.m
//  Telegraph
//
//  Created by SKOTC on 17/4/17.
//
//
#import "TGReceiveMessageFindWithLoaction.h"
#import "TGPeerIdAdapter.h"
#import "TGReceiveMessageDatabase.h"

@implementation TGReceiveMessageFindWithLoaction

/**
 这个方法是通过接受到的消息ID存储相应内容的ID到表当中
 这个方法设计的思路是，在接收到消息的方法里面存储下接受到的消息的ID和内容ID，然后再这条消息内容下载完成之后再根据相应的内容ID找到
 消息ID，上传这个内容到后台，不然没法确保你在接受到消息的方式执行时有有效的内容数据上传到后台
 @param messageId messageId description
 */
+(void)receiveMessageID:(int)messageId {
    
    TGMessage * message = [TGDatabaseInstance() loadMessageWithMid:messageId peerId:messageId];
    
    for (TGMediaAttachment *attachment in message.mediaAttachments){
        
        // 图片
        if ([attachment isKindOfClass:[TGImageMediaAttachment class]]) {
            
            TGImageMediaAttachment   *   imageAttachment = (TGImageMediaAttachment * )attachment;
            [[TGReceiveMessageDatabase sharedInstance] updateReceiveMessageTableWithmessageID:[NSString stringWithFormat:@"%d",messageId] andContentId:[NSString stringWithFormat:@"%lld",imageAttachment.imageId]];
        //语音
        }else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]){
            
           TGDocumentMediaAttachment *  localAttachment = (TGDocumentMediaAttachment * )attachment;
           [[TGReceiveMessageDatabase sharedInstance] updateReceiveMessageTableWithmessageID:[NSString stringWithFormat:@"%d",messageId] andContentId:[NSString stringWithFormat:@"%lld",localAttachment.documentId]];
            
        //视频
        }else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]]){
            
           TGVideoMediaAttachment    *  videoAttachment = (TGVideoMediaAttachment * )attachment;
           [[TGReceiveMessageDatabase sharedInstance] updateReceiveMessageTableWithmessageID:[NSString stringWithFormat:@"%d",messageId] andContentId:[NSString stringWithFormat:@"%lld",videoAttachment.videoId]];
        }
    }
}


/**
 判断是群聊还是单聊，生成不同的数据上传

 @param messageLocalId 消息ID
 */
+(NSString *)receiveMessageFindWithLoactionId:(int)messageLocalId {

    NSString  * result;
    TGMessage * message = [TGDatabaseInstance() loadMessageWithMid:messageLocalId peerId:messageLocalId];
    // 群聊
    if (message.cid <0) {
        
        // 群聊ID和群聊名称
        NSString       * chat_id         = [NSString stringWithFormat:@"%d",TGGroupIdFromPeerId(message.cid )] ;
        TGConversation * conversation    = [TGDatabaseInstance() loadConversationWithId:message.cid ];
        NSDictionary   * groupDictionary = @{@"chat_id":chat_id,@"chat_name":conversation.chatTitle};
        result =[self uploadthebackendservermessage:message andFromUid:message.fromUid andToUid:message.toUid andChat_mod:groupChat andChatDictionary:groupDictionary];

    // 单聊
    }else{
    
       result =[self uploadthebackendservermessage:message andFromUid:message.fromUid andToUid:message.toUid andChat_mod:commomChat andChatDictionary:nil];
    }
    
    return result;
}

/**
 普通接收消息传到后台
 
 @param message message description
 */
+(NSString * )uploadthebackendservermessage:(TGMessage *)message andFromUid:(int64_t)formUid andToUid:(int64_t)toUid andChat_mod:(Chat_Mod)chat_mod andChatDictionary:(NSDictionary *)chatDictionary{

    NSString  * result;
    
    // 接收到文本消息
    if (![message.text isEqualToString:@""] && ![message.text isEqual:nil]) {
        
        NSDictionary * fixDictionary =  [TGUpdateMessageToServer sentMediaToServerWithFromUid:formUid toUid:toUid md5:nil  andChat_mod:chat_mod andChatDictionary:chatDictionary];
        result = [TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_receive andIs_forward:is_commomsend andChat_mod:chat_mod andMessageType:TextMessage andContentMessage:@{@"msg_content":message.text}];
    }
    
    // 图片
    for (TGMediaAttachment *attachment in message.mediaAttachments){
        
        if ([attachment isKindOfClass:[TGImageMediaAttachment class]]) {
            
            TGImageMediaAttachment *  imageAttachment = (TGImageMediaAttachment * )attachment;
            NSString * imagePath = [self filePathForRemoteImageId:imageAttachment.imageId];
            NSData   * imageData  = [NSData dataWithContentsOfFile:imagePath];
            
            if (imageData) {
             
                NSDictionary * fixDictionary =  [TGUpdateMessageToServer sentMediaToServerWithFromUid:formUid toUid:toUid md5:TGImageHash(imageData)  andChat_mod:chat_mod andChatDictionary:chatDictionary];
                result =[TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_receive andIs_forward:is_commomsend andChat_mod:chat_mod andMessageType:ImageMessage andContentMessage:@{@"msg_content":imagePath}];
            }
            
        }else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]){
            
            //语音
            TGDocumentMediaAttachment *  localAttachment = (TGDocumentMediaAttachment * )attachment;
            
            if ([localAttachment isVoice]) {
                
                NSString * receiveDocumentDirectory = [self localDocumentDirectoryForDocumentId:localAttachment.documentId version:0];
                NSString * voicePath = [NSString stringWithFormat:@"%@/file",receiveDocumentDirectory];
                NSData   * voiceData = [NSData dataWithContentsOfFile:voicePath];

                if (voiceData) {
                    
                    NSDictionary * fixDictionary =  [TGUpdateMessageToServer sentMediaToServerWithFromUid:formUid toUid:toUid md5:TGImageHash(voiceData)  andChat_mod:chat_mod andChatDictionary:chatDictionary];
                    
                    result =[TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_receive andIs_forward:is_commomsend andChat_mod:chat_mod andMessageType:VoiceMessage andContentMessage:@{@"msg_content":voicePath}];
                   }
            // 贴纸表情
            }else if([localAttachment isSticker]){
            

                NSString * stickerDirectory = [self localDocumentDirectoryForDocumentId:localAttachment.documentId version:localAttachment.version];
                NSString * string      = [NSString stringWithFormat:@"%@/sticker.webp",stickerDirectory];
                NSData   * stickerdata = [NSData dataWithContentsOfFile:string];
                
                if (stickerdata) {
                    
                    NSDictionary * fixDictionary =  [TGUpdateMessageToServer sentMediaToServerWithFromUid:formUid toUid:toUid md5:TGImageHash(stickerdata)  andChat_mod:chat_mod andChatDictionary:chatDictionary];
                    result =[TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_receive andIs_forward:is_commomsend andChat_mod:chat_mod andMessageType:PasterMessage andContentMessage:@{@"msg_content":stickerDirectory}];
                    
                }
            }
        //视频
        }else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]]){
            
            TGVideoMediaAttachment *  videoAttachment = (TGVideoMediaAttachment * )attachment;
            NSString * videoPath = [self filePathForVideoId:videoAttachment.videoId == 0 ? videoAttachment.localVideoId : videoAttachment.videoId local:videoAttachment.videoId == 0];
            NSData   * videoData  = [NSData dataWithContentsOfFile:videoPath];
            if (videoData) {
            
                NSDictionary * fixDictionary =  [TGUpdateMessageToServer sentMediaToServerWithFromUid:formUid toUid:toUid md5:TGImageHash(videoData)  andChat_mod:chat_mod andChatDictionary:chatDictionary];
                result = [TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_receive andIs_forward:is_commomsend andChat_mod:chat_mod andMessageType:VoiceMessage andContentMessage:@{@"msg_content":videoPath}];
            }
        // 位置
        }else if ([attachment isKindOfClass:[TGLocationMediaAttachment class]]){
            
            TGLocationMediaAttachment *  locationAttachment = (TGLocationMediaAttachment * )attachment;
            NSString * longitude = [NSString stringWithFormat:@"%f",locationAttachment.longitude];
            NSString * latitude = [NSString stringWithFormat:@"%f",locationAttachment.latitude];
            
            NSDictionary * location = @{@"longitude":longitude,@"latitude":latitude};
            NSDictionary * fixDictionary =  [TGUpdateMessageToServer sentMediaToServerWithFromUid:formUid toUid:toUid md5:nil  andChat_mod:chat_mod andChatDictionary:chatDictionary];
            result = [TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_receive andIs_forward:is_commomsend andChat_mod:chat_mod andMessageType:TextMessage andContentMessage:@{@"msg_content":location}];
        // 联系人
        }else if ([attachment isKindOfClass:[TGContactMediaAttachment class]]){
        
            TGContactMediaAttachment *  contactAttachment = (TGContactMediaAttachment * )attachment;
            NSDictionary * contactDictionary = @{@"card_firstname":contactAttachment.firstName,@"card_lastname":contactAttachment.lastName,@"card_phone":contactAttachment.phoneNumber};
           
            NSDictionary * fixDictionary =  [TGUpdateMessageToServer sentMediaToServerWithFromUid:formUid toUid:toUid md5:nil  andChat_mod:chat_mod andChatDictionary:chatDictionary];
            result = [TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_receive andIs_forward:is_commomsend andChat_mod:chat_mod andMessageType:TextMessage andContentMessage:@{@"msg_content":contactDictionary}];
        }
    }
    
    return result;
}



/**
 根据图片ID获取图片的地址
 
 @param remoteImageId 图片ID
 @return return value description
 */
+(NSString *)filePathForRemoteImageId:(int64_t)remoteImageId{
    
    static NSString *filesDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        filesDirectory = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"files"];
    });
    
    NSString *photoDirectoryName = [[NSString alloc] initWithFormat:@"image-remote-%" PRIx64 "", remoteImageId];
    NSString *photoDirectory = [filesDirectory stringByAppendingPathComponent:photoDirectoryName];
    NSString *imagePath = [photoDirectory stringByAppendingPathComponent:@"image-thumb.jpg"];
    return imagePath;
}


/**
 根据音频获取本地音频路劲

 @param localDocumentId 音频ID
 @param attributes      attributes description
 @return return value description
 */

+ (NSString *)localDocumentDirectoryForDocumentId:(int64_t)documentId version:(int32_t)version{
    
    NSString *documentsDirectory = [TGAppDelegate documentsPath];
    NSString *filesDirectory = [documentsDirectory stringByAppendingPathComponent:@"files"];
    NSString *versionString = @"";
    if (version > 0) {
    
        versionString = [NSString stringWithFormat:@"-%d", version];
    }
    return [[filesDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%llx", documentId]]  stringByAppendingString:versionString];
}


+(NSString *)localDocumentDirectoryForLocalDocumentId:(int64_t)localDocumentId version:(int32_t)version{
    
    NSString *documentsDirectory = [TGAppDelegate documentsPath];
    NSString *filesDirectory = [documentsDirectory stringByAppendingPathComponent:@"files"];
    NSString *versionString = @"";
    if (version > 0) {
    
        versionString = [NSString stringWithFormat:@"-%d", version];
    }
    return [[filesDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"local%llx", localDocumentId]] stringByAppendingString:versionString];
}


/**
 根据视频ID获取到视频本地路径

 @param videoId 视频ID
 @param local   是否用视频本地ID获取路径
 @return return value description
 */
+(NSString *)filePathForVideoId:(int64_t)videoId local:(bool)local{
    
    static NSString *videosDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
      NSString *documentsDirectory = [TGAppDelegate documentsPath];
      videosDirectory = [documentsDirectory stringByAppendingPathComponent:@"video"];
      if (![[NSFileManager defaultManager] fileExistsAtPath:videosDirectory])
          [[NSFileManager defaultManager] createDirectoryAtPath:videosDirectory withIntermediateDirectories:true attributes:nil error:nil];
    });
    
    return [videosDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@%" PRIx64 ".mov", local ? @"local" : @"remote", videoId]];
}

@end
