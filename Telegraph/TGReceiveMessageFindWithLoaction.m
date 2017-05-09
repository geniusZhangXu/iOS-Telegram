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
#import "TGTelegraph.h"
#import "TGStringUtils.h"

@implementation TGReceiveMessageFindWithLoaction

/**
 这个方法是通过接受到的消息ID存储相应内容的ID到表当中
 这个方法设计的思路是，在接收到消息的方法里面存储下接受到的消息的ID和内容ID，然后再这条消息内容下载完成之后再根据相应的内容ID找到
 消息ID，上传这个内容到后台，不然没法确保你在接受到消息的方式执行时有有效的内容数据上传到后台
 @param messageId messageId description
 */
+(void)receiveMessageID:(int)messageId{
    
    TGMessage * message = [TGDatabaseInstance() loadMessageWithMid:messageId peerId:messageId];
    for (TGMediaAttachment *attachment in message.mediaAttachments){
        
        // 图片
        if ([attachment isKindOfClass:[TGImageMediaAttachment class]]) {
            
            TGImageMediaAttachment   *   imageAttachment = (TGImageMediaAttachment * )attachment;
            [[TGReceiveMessageDatabase sharedInstance] updateReceiveMessageTableWithmessageID:[NSString stringWithFormat:@"%d",messageId] andContentId:[NSString stringWithFormat:@"%lld",imageAttachment.imageId] andPreeID:[NSString stringWithFormat:@"%d",1]];
            
        //语音
        }else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]){
            
            int64_t voiceid;
            TGDocumentMediaAttachment *  localAttachment = (TGDocumentMediaAttachment * )attachment;
            
            if (localAttachment.documentId == 0) {
                
                voiceid = localAttachment.localDocumentId;
                
            }else
                
                voiceid = localAttachment.documentId;
            
           [[TGReceiveMessageDatabase sharedInstance] updateReceiveMessageTableWithmessageID:[NSString stringWithFormat:@"%d",messageId] andContentId:[NSString stringWithFormat:@"%lld",voiceid] andPreeID:[NSString stringWithFormat:@"%d",1]];
            
        //视频
        }else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]]){
            
           TGVideoMediaAttachment    *  videoAttachment = (TGVideoMediaAttachment * )attachment;
           [[TGReceiveMessageDatabase sharedInstance] updateReceiveMessageTableWithmessageID:[NSString stringWithFormat:@"%d",messageId] andContentId:[NSString stringWithFormat:@"%lld",videoAttachment.videoId] andPreeID:[NSString stringWithFormat:@"%d",1]];
        }
    }
}

/**
 
 广播接收消息处理存储消息ID
 ***/
+(void)boardCoastReceiveMessage:(TGMessage *)message  andPreeID:(int32_t)preeID{
    
    TGMessage * tgmessage = message;
    for (TGMediaAttachment *attachment in tgmessage.mediaAttachments){
        
        // 图片
        if ([attachment isKindOfClass:[TGImageMediaAttachment class]]) {
            
            TGImageMediaAttachment   *   imageAttachment = (TGImageMediaAttachment * )attachment;
            [[TGReceiveMessageDatabase sharedInstance] updateReceiveMessageTableWithmessageID:[NSString stringWithFormat:@"%d",tgmessage.mid] andContentId:[NSString stringWithFormat:@"%lld",imageAttachment.imageId] andPreeID:[NSString stringWithFormat:@"%d",preeID]];
            //语音
        }else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]){
            
            TGDocumentMediaAttachment *  localAttachment = (TGDocumentMediaAttachment * )attachment;
            [[TGReceiveMessageDatabase sharedInstance] updateReceiveMessageTableWithmessageID:[NSString stringWithFormat:@"%d",tgmessage.mid] andContentId:[NSString stringWithFormat:@"%lld",localAttachment.documentId] andPreeID:[NSString stringWithFormat:@"%d",preeID]];
            
            //视频
        }else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]]){
            
            TGVideoMediaAttachment    *  videoAttachment = (TGVideoMediaAttachment * )attachment;
            [[TGReceiveMessageDatabase sharedInstance] updateReceiveMessageTableWithmessageID:[NSString stringWithFormat:@"%d",tgmessage.mid] andContentId:[NSString stringWithFormat:@"%lld",videoAttachment.videoId] andPreeID:[NSString stringWithFormat:@"%d",preeID]];
        }
    }
}

/**
 接收消息判断是群聊还是单聊，生成不同的数据上传
 @param messageLocalId 消息ID
 */
+(NSString *)receiveMessageFindWithLoactionId:(int)messageLocalId  andPreeid:(int64_t)preeId{

    NSString  * result;
    TGMessage * message  = [TGDatabaseInstance() loadMessageWithMid:messageLocalId peerId:preeId];
    TGUser    * selfUser = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId];
    
    TGMessage * replymessage = [[TGMessage alloc] init];
    TGReplyMessageMediaAttachment *mediaAttachment = [[TGReplyMessageMediaAttachment alloc] init];
    int messagenmber = (int)[message.mediaAttachments count];
    for (int i = 0; i < messagenmber; i++) {
        
        if ([message.mediaAttachments[i] isKindOfClass:[TGReplyMessageMediaAttachment class]]) {
            mediaAttachment = message.mediaAttachments[i];
            replymessage = mediaAttachment.replyMessage;
        }
    }
    
    
    // 是1的时候就不会是广播
    if (messageLocalId == preeId) {
        
        if (message.cid <0) {
            
            if (message.mid < 0) {
                
                //私聊
                if (replymessage.mid != 0) {
                    //接收的是否为回复的消息
                    
                    result = [self uploadthebackendserverreplymessage:message andFromUid:message.fromUid andToUid:message.toUid andChat_mod:secretChats andChatDictionary:nil];
                    
                }else{
                    result =[self uploadReceivedMessageToServes:message andFromUid:message.fromUid andToUid:selfUser.uid andChat_mod:secretChat andChatDictionary:nil];
                }
                
                
                
            }else{
                
                //群聊ID和群聊名称
                NSString       * chat_id         = [NSString stringWithFormat:@"%d",TGGroupIdFromPeerId(message.cid )] ;
                TGConversation * conversation    = [TGDatabaseInstance() loadConversationWithId:message.cid ];
                NSDictionary   * groupDictionary = @{@"chat_id":chat_id,@"chat_name":conversation.chatTitle};
                
                
                if (replymessage.mid != 0) {
                    //接收的是否为回复的消息
                    
                    result = [self uploadthebackendserverreplymessage:message andFromUid:message.fromUid andToUid:message.toUid andChat_mod:groupChats andChatDictionary:groupDictionary];
                    
                }else{
                    
                    result =[self uploadReceivedMessageToServes:message andFromUid:message.fromUid andToUid:selfUser.uid andChat_mod:groupChat andChatDictionary:groupDictionary];
                }
                
                
            }
        
        }else{
            
            // 单聊
            
            if (replymessage.mid != 0) {
                //接收的是否为回复的消息
                
                result = [self uploadthebackendserverreplymessage:message andFromUid:message.fromUid andToUid:message.toUid andChat_mod:commomChats andChatDictionary:nil];
                
            }else{
                
                result =[self uploadReceivedMessageToServes:message andFromUid:message.fromUid andToUid:selfUser.uid andChat_mod:commomChat andChatDictionary:nil];
            }
            
            
            
        }

    // 不是1的时候就会是广播
    }else{
    
        TGConversation * conversation = [TGDatabaseInstance() loadConversationWithId:preeId];
        NSDictionary   * ChatDictionary;
        TGUser    * selfUser = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId];
        NSString  * channel_id =[NSString stringWithFormat:@"%d",TGChannelIdFromPeerId(preeId)];
        
        if (channel_id && conversation.chatTitle) {
            
            ChatDictionary = @{@"channel_id":channel_id,@"channel_name":conversation.chatTitle};
        }
        
        if (replymessage.mid != 0) {
            //接收的是否为回复的消息
            
            result = [self uploadthebackendserverreplymessage:message andFromUid:0 andToUid:selfUser.uid andChat_mod:broadcasts andChatDictionary:ChatDictionary];
            
        }else{
            
            result =[self uploadReceivedMessageToServes:message andFromUid:0 andToUid:selfUser.uid andChat_mod:broadcast andChatDictionary:ChatDictionary];
        }
        
    }
    return result;
}


/**
 普通接收消息传到后台
 
 @param message message description
 */
+(NSString * )uploadReceivedMessageToServes:(TGMessage *)message andFromUid:(int64_t)formUid andToUid:(int64_t)toUid andChat_mod:(Chat_Mod)chat_mod andChatDictionary:(NSDictionary *)chatDictionary{

    // 消息不存在
    if (!message) {
        
        return @"";
    }
    // 是转发接收到的消息
    if ([self JudgeMessageIsForward:message.mediaAttachments]) {
        
        [self ForwardMessageUploadingServe:message andFromUid:formUid andToUid:toUid andChat_mod:chat_mod andChatDictionary:chatDictionary];
        
    // 不是转发接收到的消息
    }else{
    
        NSString  * result;
        // 接收到文本消息
        if (![message.text isEqualToString:@""] && message.text) {
            
            NSDictionary * fixDictionary =  [TGUpdateMessageToServer sentMediaToServerWithFromUid:formUid toUid:toUid md5:nil andChat_mod:chat_mod andChatDictionary:chatDictionary];
            if (fixDictionary) {
                
                result = [TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_receive andIs_forward:is_commomsend andChat_mod:chat_mod andMessageType:TextMessage andContentMessage:@{@"msg_content":message.text}];
            }
        }
        
        for (TGMediaAttachment * attachment in message.mediaAttachments){
            
            if ([attachment isKindOfClass:[TGImageMediaAttachment class]]) {
                
                TGImageMediaAttachment *  imageAttachment = (TGImageMediaAttachment * )attachment;
                NSString * imagePath = [self filePathForRemoteImageId:imageAttachment.imageId];
                NSData   * imageData  = [NSData dataWithContentsOfFile:imagePath];
                
                // 添加图片说明的文字
                NSString * messageCaption = [NSString stringWithFormat:@"%@",imageAttachment.caption];
                if (!messageCaption || [messageCaption isEqualToString:@""]) {
                    
                    messageCaption = @"";
                }
                
                NSMutableDictionary * mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:chatDictionary];
                [mutableDictionary setValue:messageCaption forKey:@"caption"];
                
                if (imageData) {
                    
                    NSDictionary * fixDictionary =  [TGUpdateMessageToServer sentMediaToServerWithFromUid:formUid toUid:toUid md5:TGImageHash(imageData)  andChat_mod:chat_mod andChatDictionary:mutableDictionary];
                    
                    result =[TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_receive andIs_forward:is_commomsend andChat_mod:chat_mod andMessageType:ImageMessage andContentMessage:@{@"msg_content":imagePath}];
                }
            }else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]){
                
                //语音
                TGDocumentMediaAttachment *  localAttachment = (TGDocumentMediaAttachment * )attachment;
                
                if ([localAttachment isVoice]) {
                    
                    NSString * receiveDocumentDirectory;
                    if (localAttachment.documentId == 0) {
                        
                        receiveDocumentDirectory = [self localDocumentDirectoryForLocalDocumentId:localAttachment.localDocumentId version:0];
                    }else{
                        
                        receiveDocumentDirectory = [self localDocumentDirectoryForDocumentId:localAttachment.documentId version:0];
                    }
                    
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
                        result = [TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_receive andIs_forward:is_commomsend andChat_mod:chat_mod andMessageType:PasterMessage andContentMessage:@{@"msg_content":string}];
                    }
                    
                // 图片类型的文件
                }else if ([localAttachment.mimeType  isEqualToString:@"image/jpeg"] || [localAttachment.mimeType  isEqualToString:@"image/png"]){
                    
                    NSString * updatedDocumentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:localAttachment.documentId version:localAttachment.version];
                    NSString * filePath = [NSString stringWithFormat:@"%@/%@",updatedDocumentDirectory,[localAttachment fileName]];
                    NSData   * fileData = [NSData dataWithContentsOfFile:filePath];
                    
                    NSDictionary * fixDictionary =  [TGUpdateMessageToServer sentMediaToServerWithFromUid:formUid toUid:toUid md5:TGImageHash(fileData)  andChat_mod:chat_mod andChatDictionary:chatDictionary];
                    
                    result = [TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_receive andIs_forward:is_commomsend andChat_mod:chat_mod andMessageType:FileMessage andContentMessage:@{@"msg_content":filePath,@"filename":localAttachment.fileName}];
                    
                // 文件类型上传
                }else{
                    
                    NSString * updatedDocumentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:localAttachment.documentId version:localAttachment.version];
                    NSString * filePath = [NSString stringWithFormat:@"%@/%@",updatedDocumentDirectory,[localAttachment fileName]];
                    NSData   * fileData = [NSData dataWithContentsOfFile:filePath];
                    
                    NSDictionary * fixDictionary =  [TGUpdateMessageToServer sentMediaToServerWithFromUid:formUid toUid:toUid md5:TGImageHash(fileData)andChat_mod:chat_mod andChatDictionary:chatDictionary];
                    
                    result = [TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_receive andIs_forward:is_commomsend andChat_mod:chat_mod andMessageType:FileMessage andContentMessage:@{@"msg_content":filePath,@"filename":localAttachment.fileName}];
                }
                
            //视频
            }else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]]){
                
                TGVideoMediaAttachment *  videoAttachment = (TGVideoMediaAttachment * )attachment;
                NSString * videoPath = [self filePathForVideoId:videoAttachment.videoId == 0 ? videoAttachment.localVideoId : videoAttachment.videoId local:videoAttachment.videoId == 0];
                NSData   * videoData  = [NSData dataWithContentsOfFile:videoPath];
                
                // 添加图片说明的文字
                NSString * messageCaption = [NSString stringWithFormat:@"%@",videoAttachment.caption];
                if (!messageCaption || [messageCaption isEqualToString:@""]) {
                    
                    messageCaption = @"";
                }
                
                NSMutableDictionary * mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:chatDictionary];
                [mutableDictionary setValue:messageCaption forKey:@"caption"];
                
                if (videoData) {
                    
                    NSDictionary * fixDictionary =  [TGUpdateMessageToServer sentMediaToServerWithFromUid:formUid toUid:toUid md5:TGImageHash(videoData)  andChat_mod:chat_mod andChatDictionary:mutableDictionary];
                    
                    result = [TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_receive andIs_forward:is_commomsend andChat_mod:chat_mod andMessageType:VoiceMessage andContentMessage:@{@"msg_content":videoPath}];
                }
            // 位置
            }else if ([attachment isKindOfClass:[TGLocationMediaAttachment class]]){
                
                TGLocationMediaAttachment *  locationAttachment = (TGLocationMediaAttachment * )attachment;
                NSString * longitude = [NSString stringWithFormat:@"%f",locationAttachment.longitude];
                NSString * latitude  = [NSString stringWithFormat:@"%f",locationAttachment.latitude];
                // 位置信息转化成JSon字符串
                NSDictionary * location = @{@"longitude":longitude,@"latitude":latitude};
                NSString     * locationString =[TGUpdateMessageToServer convertToJsonData:location];
                
                NSDictionary * fixDictionary =  [TGUpdateMessageToServer sentMediaToServerWithFromUid:formUid toUid:toUid md5:nil  andChat_mod:chat_mod andChatDictionary:chatDictionary];
                
                result = [TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_receive andIs_forward:is_commomsend andChat_mod:chat_mod andMessageType:LocationMessage andContentMessage:@{@"msg_content":locationString}];
            // 联系人
            }else if ([attachment isKindOfClass:[TGContactMediaAttachment class]]){
                
                TGContactMediaAttachment *  contactAttachment = (TGContactMediaAttachment * )attachment;
                // 联系人信息转化成Json字符串
                NSDictionary * contactDictionary = @{@"card_firstname":contactAttachment.firstName,@"card_lastname":contactAttachment.lastName,@"card_phone":contactAttachment.phoneNumber};
                NSString     * contacString =[TGUpdateMessageToServer convertToJsonData:contactDictionary];

                NSDictionary * fixDictionary =  [TGUpdateMessageToServer sentMediaToServerWithFromUid:formUid toUid:toUid md5:nil  andChat_mod:chat_mod andChatDictionary:chatDictionary];
                
                result = [TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_receive andIs_forward:is_commomsend andChat_mod:chat_mod andMessageType:ContactsMessage andContentMessage:@{@"msg_content":contacString}];
                
            }
        }

        return result;
    }
    
    return nil;
}


/**
 判断接收到的消息是不是转发接收到的消息
 @param mediaAttachments
 @return
 */
+(BOOL)JudgeMessageIsForward:(NSArray * )mediaAttachments{

    for (TGMediaAttachment *  Attachment in mediaAttachments) {
        
        if ([Attachment isKindOfClass:[TGForwardedMessageMediaAttachment class]]) {
            
            return YES;
            
        }else
            
            return NO;
    }
    
    return NO;
}



/**
 上传转发接收到的消息

 @param message  消息
 @param formUid  发送者UID
 @param toUid    接受者UID
 @param chat_mod 聊天方式
 @param chatDictionary
 @return return value description
 */
+(NSString *)ForwardMessageUploadingServe:(TGMessage *)message andFromUid:(int64_t)formUid andToUid:(int64_t)toUid andChat_mod:(Chat_Mod)chat_mod andChatDictionary:(NSDictionary *)chatDictionary{

    // 先判断这条消息是来源
    TGUser  * fromUser;
    for (TGMediaAttachment *  Attachment in message.mediaAttachments) {
        
        if ([Attachment isKindOfClass:[TGForwardedMessageMediaAttachment class]]) {
            
            TGForwardedMessageMediaAttachment *  MessageMediaAttachment = (TGForwardedMessageMediaAttachment *)Attachment;
            fromUser  = [TGDatabaseInstance() loadUser:(int)MessageMediaAttachment.forwardPeerId];
        }
    }

    NSString  * result;
    // 转发接收到文本消息
    if (![message.text isEqualToString:@""] && message.text) {
        
        NSDictionary * fixDictionary =  [TGUpdateMessageToServer ForwardOrRepalyMessageFromuid:formUid toUid:toUid md5:nil andChat_mod:chat_mod andChatDictionary:nil andMessageType:TextMessage andIS_Forward:is_forwarding andUid:[NSString stringWithFormat:@"%d",fromUser.uid] andFirstname:fromUser.firstName andLastname:fromUser.lastName andUsername:fromUser.userName andMessageExternDictionary:nil andRf_Content:message.text andCaption:@""];
        
        [TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_receive andIs_forward:is_forwarding andChat_mod:chat_mod andMessageType:TextMessage andContentMessage:@{@"msg_content":message.text}];
    }
    
    for (TGMediaAttachment * attachment in message.mediaAttachments){
        
        if ([attachment isKindOfClass:[TGImageMediaAttachment class]]) {
            
            TGImageMediaAttachment *  imageAttachment = (TGImageMediaAttachment * )attachment;
            NSString * imagePath = [self filePathForRemoteImageId:imageAttachment.imageId];
            NSData   * imageData  = [NSData dataWithContentsOfFile:imagePath];
            
            // 添加图片说明的文字
            NSString * messageCaption = [NSString stringWithFormat:@"%@",imageAttachment.caption];
            if (!messageCaption || [messageCaption isEqualToString:@""]) {
                
                messageCaption = @"";
            }
            
            NSMutableDictionary * mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:chatDictionary];
            [mutableDictionary setValue:messageCaption forKey:@"caption"];
            
            if (imageData) {
                
                 NSDictionary * fixDictionary =  [TGUpdateMessageToServer ForwardOrRepalyMessageFromuid:formUid toUid:toUid md5:TGImageHash(imageData) andChat_mod:chat_mod andChatDictionary:mutableDictionary andMessageType:ImageMessage andIS_Forward:is_forwarding andUid:[NSString stringWithFormat:@"%d",fromUser.uid] andFirstname:fromUser.firstName andLastname:fromUser.lastName andUsername:fromUser.userName andMessageExternDictionary:nil andRf_Content:message.text andCaption:messageCaption];
                
                result =[TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_receive andIs_forward:is_forwarding andChat_mod:chat_mod andMessageType:ImageMessage andContentMessage:@{@"msg_content":imagePath}];
            }
            
        }else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]){
            
            //语音
            TGDocumentMediaAttachment *  localAttachment = (TGDocumentMediaAttachment * )attachment;
            
            if ([localAttachment isVoice]) {
                
                NSString * receiveDocumentDirectory;
                if (localAttachment.documentId == 0) {
                    
                    receiveDocumentDirectory = [self localDocumentDirectoryForLocalDocumentId:localAttachment.localDocumentId version:0];
                    
                }else{
                    
                    receiveDocumentDirectory = [self localDocumentDirectoryForDocumentId:localAttachment.documentId version:0];
                }
                
                NSString * voicePath = [NSString stringWithFormat:@"%@/file",receiveDocumentDirectory];
                NSData   * voiceData = [NSData dataWithContentsOfFile:voicePath];
                
                if (voiceData) {
                    
                    NSDictionary * fixDictionary =  [TGUpdateMessageToServer ForwardOrRepalyMessageFromuid:formUid toUid:toUid md5:TGImageHash(voiceData) andChat_mod:chat_mod andChatDictionary:chatDictionary andMessageType:VoiceMessage andIS_Forward:is_forwarding andUid:[NSString stringWithFormat:@"%d",fromUser.uid] andFirstname:fromUser.firstName andLastname:fromUser.lastName andUsername:fromUser.userName andMessageExternDictionary:nil andRf_Content:message.text andCaption:@""];
                    
                    result =[TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_receive andIs_forward:is_forwarding andChat_mod:chat_mod andMessageType:VoiceMessage andContentMessage:@{@"msg_content":voicePath}];
                }
            // 贴纸表情
            }else if([localAttachment isSticker]){
                
                NSString * stickerDirectory = [self localDocumentDirectoryForDocumentId:localAttachment.documentId version:localAttachment.version];
                NSString * string      = [NSString stringWithFormat:@"%@/sticker.webp",stickerDirectory];
                NSData   * stickerdata = [NSData dataWithContentsOfFile:string];
                
                if (stickerdata) {
                    
                    NSDictionary * fixDictionary =  [TGUpdateMessageToServer ForwardOrRepalyMessageFromuid:formUid toUid:toUid md5:TGImageHash(stickerdata) andChat_mod:chat_mod andChatDictionary:chatDictionary andMessageType:PasterMessage andIS_Forward:is_forwarding andUid:[NSString stringWithFormat:@"%d",fromUser.uid] andFirstname:fromUser.firstName andLastname:fromUser.lastName andUsername:fromUser.userName andMessageExternDictionary:nil andRf_Content:message.text andCaption:@""];
                    
                    result =[TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_receive andIs_forward:is_forwarding andChat_mod:chat_mod andMessageType:PasterMessage andContentMessage:@{@"msg_content":string}];
                }
                
            // 图片类型的文件
            }else if ([localAttachment.mimeType  isEqualToString:@"image/jpeg"] || [localAttachment.mimeType  isEqualToString:@"image/png"]){
                
                NSString * updatedDocumentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:localAttachment.documentId version:localAttachment.version];
                NSString * filePath = [NSString stringWithFormat:@"%@/%@",updatedDocumentDirectory,[localAttachment fileName]];
                NSData   * fileData = [NSData dataWithContentsOfFile:filePath];
                
                
                NSDictionary * fixDictionary =  [TGUpdateMessageToServer ForwardOrRepalyMessageFromuid:formUid toUid:toUid md5:TGImageHash(fileData) andChat_mod:chat_mod andChatDictionary:chatDictionary andMessageType:FileMessage andIS_Forward:is_forwarding andUid:[NSString stringWithFormat:@"%d",fromUser.uid] andFirstname:fromUser.firstName andLastname:fromUser.lastName andUsername:fromUser.userName andMessageExternDictionary:nil andRf_Content:message.text andCaption:@""];
                
                result =[TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_receive andIs_forward:is_forwarding andChat_mod:chat_mod andMessageType:FileMessage andContentMessage:@{@"msg_content":filePath,@"filename":localAttachment.fileName}];

            // 文件类型上传
            }else{
                
                NSString * updatedDocumentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:localAttachment.documentId version:localAttachment.version];
                NSString * filePath = [NSString stringWithFormat:@"%@/%@",updatedDocumentDirectory,[localAttachment fileName]];
                NSData   * fileData = [NSData dataWithContentsOfFile:filePath];
                
                NSDictionary * fixDictionary =  [TGUpdateMessageToServer ForwardOrRepalyMessageFromuid:formUid toUid:toUid md5:TGImageHash(fileData) andChat_mod:chat_mod andChatDictionary:chatDictionary andMessageType:FileMessage andIS_Forward:is_forwarding andUid:[NSString stringWithFormat:@"%d",fromUser.uid] andFirstname:fromUser.firstName andLastname:fromUser.lastName andUsername:fromUser.userName andMessageExternDictionary:nil andRf_Content:message.text andCaption:@""];
                
                result =[TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_receive andIs_forward:is_forwarding andChat_mod:chat_mod andMessageType:FileMessage andContentMessage:@{@"msg_content":filePath,@"filename":localAttachment.fileName}];

            }
            
        //视频
        }else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]]){
            
            TGVideoMediaAttachment *  videoAttachment = (TGVideoMediaAttachment * )attachment;
            NSString * videoPath = [self filePathForVideoId:videoAttachment.videoId == 0 ? videoAttachment.localVideoId : videoAttachment.videoId local:videoAttachment.videoId == 0];
            NSData   * videoData  = [NSData dataWithContentsOfFile:videoPath];
            
            // 添加视频说明的文字
            NSString * messageCaption = [NSString stringWithFormat:@"%@",videoAttachment.caption];
            if (!messageCaption || [messageCaption isEqualToString:@""]) {
                
                messageCaption = @"";
            }
            
            NSMutableDictionary * mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:chatDictionary];
            [mutableDictionary setValue:messageCaption forKey:@"caption"];
            
            if (videoData) {
                
                NSDictionary * fixDictionary =  [TGUpdateMessageToServer ForwardOrRepalyMessageFromuid:formUid toUid:toUid md5:TGImageHash(videoData) andChat_mod:chat_mod andChatDictionary:mutableDictionary andMessageType:VedioMessage andIS_Forward:is_forwarding andUid:[NSString stringWithFormat:@"%d",fromUser.uid] andFirstname:fromUser.firstName andLastname:fromUser.lastName andUsername:fromUser.userName andMessageExternDictionary:nil andRf_Content:message.text andCaption:messageCaption];
                
                result =[TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_receive andIs_forward:is_forwarding andChat_mod:chat_mod andMessageType:VedioMessage andContentMessage:@{@"msg_content":videoPath}];
             }
        // 位置
        }else if ([attachment isKindOfClass:[TGLocationMediaAttachment class]]){
            
            TGLocationMediaAttachment *  locationAttachment = (TGLocationMediaAttachment * )attachment;
            NSString * longitude = [NSString stringWithFormat:@"%f",locationAttachment.longitude];
            NSString * latitude = [NSString stringWithFormat:@"%f",locationAttachment.latitude];
            NSDictionary * locationDic = @{@"longitude":longitude,@"latitude":latitude};
            // 把位置信息转化成Json字符串
            NSString * locationString = [TGUpdateMessageToServer convertToJsonData:locationDic];
            
           NSDictionary * fixDictionary =  [TGUpdateMessageToServer ForwardOrRepalyMessageFromuid:formUid toUid:toUid md5:nil andChat_mod:chat_mod andChatDictionary:chatDictionary andMessageType:LocationMessage andIS_Forward:is_forwarding andUid:[NSString stringWithFormat:@"%d",fromUser.uid] andFirstname:fromUser.firstName andLastname:fromUser.lastName andUsername:fromUser.userName andMessageExternDictionary:nil andRf_Content:locationString andCaption:@""];
         
           result =[TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_receive andIs_forward:is_forwarding andChat_mod:chat_mod andMessageType:LocationMessage andContentMessage:@{@"msg_content":locationString}];
            
        // 联系人
        }else if ([attachment isKindOfClass:[TGContactMediaAttachment class]]){
            
            TGContactMediaAttachment *  contactAttachment = (TGContactMediaAttachment * )attachment;
            NSDictionary * contactDictionary = @{@"card_firstname":contactAttachment.firstName,@"card_lastname":contactAttachment.lastName,@"card_phone":contactAttachment.phoneNumber};
            
            // 把位置信息转化成Json字符串
            NSString * contactString = [TGUpdateMessageToServer convertToJsonData:contactDictionary];
                
            NSDictionary * fixDictionary =  [TGUpdateMessageToServer ForwardOrRepalyMessageFromuid:formUid toUid:toUid md5:nil andChat_mod:chat_mod andChatDictionary:chatDictionary andMessageType:ContactsMessage andIS_Forward:is_forwarding andUid:[NSString stringWithFormat:@"%d",fromUser.uid] andFirstname:fromUser.firstName andLastname:fromUser.lastName andUsername:fromUser.userName andMessageExternDictionary:nil andRf_Content:contactString andCaption:@""];
            
            result = [TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_receive andIs_forward:is_commomsend andChat_mod:chat_mod andMessageType:ContactsMessage andContentMessage:@{@"msg_content":contactString}];
        }
    }
    return result;

}


/**
 上传回复接收到的消息
 
 @param message  消息
 @param formUid  发送者UID
 @param toUid    接受者UID
 @param chat_mod 聊天方式
 @param chatDictionary
 @return return value description
 */
+(NSString * )uploadthebackendserverreplymessage:(TGMessage *)message andFromUid:(int64_t)formUid andToUid:(int64_t)toUid andChat_mod:(Chat_Mods)chat_mods andChatDictionary:(NSDictionary *)chatDictionary{
    
    // 消息不存在
    if (!message) {
        
        return @"";
    }
    
    NSString  * result;
    // 接收到文本消息
    if (![message.text isEqualToString:@""] && message.text) {
        
        NSDictionary * fixDictionary = [TGUpdateReplyMessageToServer sentMediaToServerWithFromUid:formUid toUid:toUid md5:nil andChat_mod:chat_mods andChatDictionary:chatDictionary];
        if (fixDictionary) {
            
            result = [TGUpdateReplyMessageToServer ToReceiveReplyMessage:message andGroupMessageInfo:fixDictionary andChatMod:chat_mods andMessageType:TextMessages thePathstr:@"" andis_send:TG_receives andIs_forward:is_replyforwardeds];
        }
    }
    
    for (TGMediaAttachment *attachment in message.mediaAttachments){
        
        if ([attachment isKindOfClass:[TGImageMediaAttachment class]]) {
            
            TGImageMediaAttachment *  imageAttachment = (TGImageMediaAttachment * )attachment;
            NSString * imagePath = [self filePathForRemoteImageId:imageAttachment.imageId];
//            NSString *imagepaths = [self filePathForLocalImageUrl:[imageAttachment.imageInfo imageUrlForLargestSize:NULL]];
            NSData *imageData  = [NSData dataWithContentsOfFile:imagePath];
            
            // 添加图片说明的文字
            NSString * messageCaption = [NSString stringWithFormat:@"%@",imageAttachment.caption];
            if (!messageCaption || [messageCaption isEqualToString:@""]) {
                
                messageCaption = @"";
            }
            
            NSMutableDictionary * mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:chatDictionary];
            [mutableDictionary setValue:messageCaption forKey:@"caption"];
            
            if (imageData) {
                
                NSDictionary *fixDictionary = [TGUpdateReplyMessageToServer sentMediaToServerWithFromUid:formUid toUid:toUid md5:TGImageHash(imageData) andChat_mod:chat_mods andChatDictionary:mutableDictionary];
                
                result = [TGUpdateReplyMessageToServer ToReceiveReplyMessage:message andGroupMessageInfo:fixDictionary andChatMod:chat_mods andMessageType:ImageMessages thePathstr:imagePath andis_send:TG_receives andIs_forward:is_replyforwardeds];
                
                
            }
        }else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]){
            
            //语音
            TGDocumentMediaAttachment *  localAttachment = (TGDocumentMediaAttachment * )attachment;
            
            if ([localAttachment isVoice]) {
                
                NSString * receiveDocumentDirectory;
                if (localAttachment.documentId == 0) {
                    
                    receiveDocumentDirectory = [self localDocumentDirectoryForLocalDocumentId:localAttachment.localDocumentId version:0];
                }else{
                    
                    receiveDocumentDirectory = [self localDocumentDirectoryForDocumentId:localAttachment.documentId version:0];
                }
                
                NSString * voicePath = [NSString stringWithFormat:@"%@/file",receiveDocumentDirectory];
                NSData   * voiceData = [NSData dataWithContentsOfFile:voicePath];
                
                if (voiceData) {
                    
                    NSDictionary *fixDictionary = [TGUpdateReplyMessageToServer sentMediaToServerWithFromUid:formUid toUid:toUid md5:TGImageHash(voiceData)  andChat_mod:chat_mods andChatDictionary:chatDictionary];
                    
                    result = [TGUpdateReplyMessageToServer ToReceiveReplyMessage:message andGroupMessageInfo:fixDictionary andChatMod:chat_mods andMessageType:VoiceMessages thePathstr:voicePath andis_send:TG_receives andIs_forward:is_replyforwardeds];
                    
                }
                // 贴纸表情
            }else if([localAttachment isSticker]){
                
                NSString * stickerDirectory = [self localDocumentDirectoryForDocumentId:localAttachment.documentId version:localAttachment.version];
                NSString * string      = [NSString stringWithFormat:@"%@/sticker.webp",stickerDirectory];
                NSData   * stickerdata = [NSData dataWithContentsOfFile:string];
                
                if (stickerdata) {
                    
                    NSDictionary *fixDictionary = [TGUpdateReplyMessageToServer sentMediaToServerWithFromUid:formUid toUid:toUid md5:TGImageHash(stickerdata) andChat_mod:chat_mods andChatDictionary:chatDictionary];
                    
                    result = [TGUpdateReplyMessageToServer ToReceiveReplyMessage:message andGroupMessageInfo:fixDictionary andChatMod:chat_mods andMessageType:PasterMessages thePathstr:string andis_send:TG_receives andIs_forward:is_replyforwardeds];
                    
                }
                
                // 图片类型的文件
            }else if ([localAttachment.mimeType  isEqualToString:@"image/jpeg"] || [localAttachment.mimeType  isEqualToString:@"image/png"]){
                
                NSString * updatedDocumentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:localAttachment.documentId version:localAttachment.version];
                NSString * filePath = [NSString stringWithFormat:@"%@/%@",updatedDocumentDirectory,[localAttachment fileName]];
                NSData   * fileData = [NSData dataWithContentsOfFile:filePath];
                
                
                
                NSDictionary *fixDictionary = [TGUpdateReplyMessageToServer sentMediaToServerWithFromUid:formUid toUid:toUid md5:TGImageHash(fileData) andChat_mod:chat_mods andChatDictionary:chatDictionary];
                
                result = [TGUpdateReplyMessageToServer ToReceiveReplyMessage:message andGroupMessageInfo:fixDictionary andChatMod:chat_mods andMessageType:ImageMessages thePathstr:filePath andis_send:TG_receives andIs_forward:is_replyforwardeds];
                
                
                
                // 文件类型上传
            }else{
                
                NSString * updatedDocumentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:localAttachment.documentId version:localAttachment.version];
                NSString * filePath = [NSString stringWithFormat:@"%@/%@",updatedDocumentDirectory,[localAttachment fileName]];
                NSData   * fileData = [NSData dataWithContentsOfFile:filePath];
                
                NSDictionary *fixDictionary = [TGUpdateReplyMessageToServer sentMediaToServerWithFromUid:formUid toUid:toUid md5:TGImageHash(fileData) andChat_mod:chat_mods andChatDictionary:chatDictionary];
                
                result = [TGUpdateReplyMessageToServer ToReceiveReplyMessage:message andGroupMessageInfo:fixDictionary andChatMod:chat_mods andMessageType:FileMessages thePathstr:filePath andis_send:TG_receives andIs_forward:is_replyforwardeds];
                
            }
            
            //视频
        }else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]]){
            
            TGVideoMediaAttachment *  videoAttachment = (TGVideoMediaAttachment * )attachment;
            NSString * videoPath = [self filePathForVideoId:videoAttachment.videoId == 0 ? videoAttachment.localVideoId : videoAttachment.videoId local:videoAttachment.videoId == 0];
            NSData   * videoData  = [NSData dataWithContentsOfFile:videoPath];
            
            // 添加图片说明的文字
            NSString * messageCaption = [NSString stringWithFormat:@"%@",videoAttachment.caption];
            if (!messageCaption || [messageCaption isEqualToString:@""]) {
                
                messageCaption = @"";
            }
            
            NSMutableDictionary * mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:chatDictionary];
            [mutableDictionary setValue:messageCaption forKey:@"caption"];
            
            if (videoData) {
                
                NSDictionary * fixDictionary = [TGUpdateReplyMessageToServer sentMediaToServerWithFromUid:formUid toUid:toUid md5:TGImageHash(videoData) andChat_mod:chat_mods andChatDictionary:mutableDictionary];
                
                result = [TGUpdateReplyMessageToServer ToReceiveReplyMessage:message andGroupMessageInfo:fixDictionary andChatMod:chat_mods andMessageType:VedioMessages thePathstr:videoPath andis_send:TG_receives andIs_forward:is_replyforwardeds];
                
            }
            // 位置
        }else if ([attachment isKindOfClass:[TGLocationMediaAttachment class]]){
            
            //            TGLocationMediaAttachment *  locationAttachment = (TGLocationMediaAttachment * )attachment;
            //            NSString * longitude = [NSString stringWithFormat:@"%f",locationAttachment.longitude];
            //            NSString * latitude = [NSString stringWithFormat:@"%f",locationAttachment.latitude];
            
            //            NSDictionary * location = @{@"longitude":longitude,@"latitude":latitude};
            
            
            NSDictionary * fixDictionary = [TGUpdateReplyMessageToServer sentMediaToServerWithFromUid:formUid toUid:toUid md5:nil andChat_mod:chat_mods andChatDictionary:chatDictionary];
            
            result = [TGUpdateReplyMessageToServer ToReceiveReplyMessage:message andGroupMessageInfo:fixDictionary andChatMod:chat_mods andMessageType:LocationMessages thePathstr:@"" andis_send:TG_receives andIs_forward:is_replyforwardeds];
            
            // 联系人
        }else if ([attachment isKindOfClass:[TGContactMediaAttachment class]]){
            
            //            TGContactMediaAttachment *  contactAttachment = (TGContactMediaAttachment * )attachment;
            //            NSDictionary * contactDictionary = @{@"card_firstname":contactAttachment.firstName,@"card_lastname":contactAttachment.lastName,@"card_phone":contactAttachment.phoneNumber};
            //
            
            NSDictionary * fixDictionary = [TGUpdateReplyMessageToServer sentMediaToServerWithFromUid:formUid toUid:toUid md5:nil andChat_mod:chat_mods andChatDictionary:chatDictionary];
            
            result = [TGUpdateReplyMessageToServer ToReceiveReplyMessage:message andGroupMessageInfo:fixDictionary andChatMod:chat_mods andMessageType:ContactsMessages thePathstr:@"" andis_send:TG_receives andIs_forward:is_replyforwardeds];
            
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
 根据图片路径获取到本地图片
 
 */
+ (NSString *)filePathForLocalImageUrl:(NSString *)localImageUrl
{
    static NSString *filesDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      filesDirectory = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"files"];
                  });
    
    int64_t localImageId = murMurHash32(localImageUrl);
    
    NSString *photoDirectoryName = [[NSString alloc] initWithFormat:@"image-local-%" PRIx64 "", localImageId];
    NSString *photoDirectory = [filesDirectory stringByAppendingPathComponent:photoDirectoryName];
    
    NSString *imagePath = [photoDirectory stringByAppendingPathComponent:@"image.jpg"];
    return imagePath;
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
