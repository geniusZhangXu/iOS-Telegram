//
//  TGForwardMessageUploaded.m
//  Telegraph
//
//  Created by SKOTC on 17/4/25.
//
//

#import "TGForwardMessageUploaded.h"
#import "TGPeerIdAdapter.h"
#import "TGUpdateMessageToServer.h"
#import "TGImageUtils.h"
#import "TGTelegraph.h"

@implementation TGForwardMessageUploaded


+(void)UploadForwardMessageToServeWithMessage:(TGPreparedForwardedMessage *)preparedMessage andConversationId:(int)conversationId{
  
    TGPreparedForwardedMessage * forwardedMessage = (TGPreparedForwardedMessage *)preparedMessage;
    
    TGUser * user     = [TGDatabaseInstance()loadUser:(int)conversationId];
    NSLog(@"我是转发的消息 %@",user.firstName);
    NSLog(@"我是转发的消息 %d",user.uid);
    NSLog(@"我是转发的消息 %@",user.lastName);
    
    // 转发文本类型
    if([forwardedMessage.innerMessage.text isEqualToString:@""]) {
        
        
        
    }else{
        
        for (TGMediaAttachment * attachment in forwardedMessage.innerMessage.mediaAttachments){
            
            if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]){
                
                TGDocumentMediaAttachment * documentAttachment = (TGDocumentMediaAttachment *)attachment;
                // 获取音频路径
                NSString * updatedDocumentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:documentAttachment.documentId version:documentAttachment.version];
                
                NSString * voicePath = [NSString stringWithFormat:@"%@/file",updatedDocumentDirectory];
                //NSData   * voiceData = [NSData dataWithContentsOfFile:voicePath];
                NSLog(@"我是转发的消息 voicePath =======%@",voicePath);
              
                

            }else if ([attachment isKindOfClass:[TGImageMediaAttachment class]]){
                
                TGImageMediaAttachment * documentAttachment = (TGImageMediaAttachment *)attachment;
                NSString * imagePath = [self filePathForRemoteImageId:documentAttachment.imageId];
                NSLog(@"我是转发的消息 imagePath =======%@",imagePath);
                
                
                
            }else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]]){
                
                TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)attachment;
                
                NSString * documentsDirectory = [TGAppDelegate documentsPath];
                NSString * videosDirectory    = [documentsDirectory stringByAppendingPathComponent:@"video"];
                if (![[NSFileManager defaultManager] fileExistsAtPath:videosDirectory])
                    [[NSFileManager defaultManager] createDirectoryAtPath:videosDirectory withIntermediateDirectories:true attributes:nil error:nil];
                NSString * updatedVideoPath    = [videosDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"remote%llx.mov", videoAttachment.videoId]];
                NSLog(@"我是转发的消息 updatedVideoPath =======%@",updatedVideoPath);
                
                //视频上传
                NSData   * vedioData = [NSData dataWithContentsOfFile:updatedVideoPath];
                //添加视频说明的文字
                NSString * messageCaption = [NSString stringWithFormat:@"%@",videoAttachment.caption];
                if (!messageCaption || [messageCaption isEqualToString:@""]) {
                    
                    messageCaption = @"";
                }
                if (updatedVideoPath) {
                    
                    // 能进这个方法的，当会话ID小于0的时候，只能是群聊
                    if (conversationId < 0) {
                        
                        int32_t uid      = [TGDatabaseInstance() encryptedParticipantIdForConversationId:conversationId];
                        TGUser *user     = [TGDatabaseInstance()loadUser:uid];
                        TGUser *selfUser = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId];
                        
                        TGConversation * conversation = [TGDatabaseInstance() loadConversationWithId:conversationId];
                        NSDictionary * ChatDictionary;
                        Chat_Mod   chat_mod;
                        // 广播信息
                        if (![conversation isChat]) {
                            
                            NSString  * channel_id =[NSString stringWithFormat:@"%d",TGChannelIdFromPeerId(conversationId)];
                            ChatDictionary = @{@"channel_id":channel_id,@"channel_name":conversation.chatTitle,@"caption":messageCaption};
                            chat_mod = broadcast;
                            
                            // 群聊
                        }else {
                            
                            NSString  * chat_id =[NSString stringWithFormat:@"%d",TGGroupIdFromPeerId(conversationId)];
                            ChatDictionary = @{@"chat_id":chat_id,@"chat_name":conversation.chatTitle,@"caption":messageCaption};
                            chat_mod = groupChat;
                        }
                        
                        NSDictionary * fixDictionary =  [TGUpdateMessageToServer sentMediaToServerWithFromUid:selfUser.uid toUid:user.uid md5:TGImageHash(vedioData)  andChat_mod:chat_mod andChatDictionary:ChatDictionary];
                        
                        [TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_send andIs_forward:is_commomsend andChat_mod:chat_mod andMessageType:VedioMessage andContentMessage:@{@"msg_content":updatedVideoPath}];
                        
                    }else{
                        
                        TGUser *user     = [TGDatabaseInstance()loadUser:(int)conversationId];
                        TGUser *selfUser = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId];
                        
                        NSDictionary * fixDictionary =  [TGUpdateMessageToServer sentMediaToServerWithFromUid:selfUser.uid toUid:user.uid md5:TGImageHash(vedioData)  andChat_mod:commomChat andChatDictionary:@{@"caption":messageCaption}];
                        
                        [TGUpdateMessageToServer TGUpdateMessageToServerWithFixedDictionary:fixDictionary andis_send:TG_send andIs_forward:is_commomsend andChat_mod:commomChat andMessageType:VedioMessage andContentMessage:@{@"msg_content":updatedVideoPath}];
                        
                        }
                    }
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
