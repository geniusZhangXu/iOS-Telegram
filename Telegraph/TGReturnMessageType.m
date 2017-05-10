//
//  TGReturnMessageType.m
//  Telegraph
//
//  Created by mac on 2017/4/28.
//
//

#import "TGReturnMessageType.h"


@implementation TGReturnMessageType


+ (NSString *)judgeReplyTypeMessage:(TGMessage *)message
{
    int messagenmber = (int)[message.mediaAttachments count];
    
    NSString *replystr = [[NSString alloc] init];
    
    if (![message.text isEqualToString:@""]) {
        
        replystr = message.text;
        
    }else{
        

//        "Message.ForwardedMessage" = "Forwarded Message\nFrom: %@";
//        "Message.SharedContact" = "Shared Contact";
//        "Message.Animation" = "GIF";
        
        
        
        for (int i = 0; i < messagenmber; i++) {
            
            if ([message.mediaAttachments[i] isKindOfClass:[TGImageMediaAttachment class]]) {
                //图片
                
                NSLog(@"图片+++++++++++++++");
                
                replystr = TGLocalized(@"Message.Photo");
                
                
            }else if ([message.mediaAttachments[i] isKindOfClass:[TGVideoMediaAttachment class]]){
                //视频
                NSLog(@"视频+++++++++++++++");
                
                replystr = TGLocalized(@"Message.Video");
                
                
            }else if ([message.mediaAttachments[i] isKindOfClass:[TGLocationMediaAttachment class]]){
                //位置
                NSLog(@"位置+++++++++++++++");
                
                replystr = TGLocalized(@"Message.Location");
                
            }else if ([message.mediaAttachments[i] isKindOfClass:[TGContactMediaAttachment class]]){
                //联系人
                NSLog(@"联系人+++++++++++++++");
                
                replystr = TGLocalized(@"Shared Contact");
                
                
                
            }else if ([message.mediaAttachments[i] isKindOfClass:[TGDocumentMediaAttachment class]]){
                //语音   本地表情
                NSLog(@"语音   本地表情+++++++++++++++");
                
                TGDocumentMediaAttachment *documentMedia = message.mediaAttachments[i];
                
                if ([documentMedia.mimeType isEqualToString:@"audio/ogg"]) {
                    //语音
                    
                    replystr = TGLocalized(@"Message.Audio");
                    
                    
                    
                }else if([documentMedia.mimeType isEqualToString:@"image/webp"]){
                    //表情
                    
                    replystr = TGLocalized(@"Message.Sticker");
                    
                    
                }else{
                    //image/jpeg
                    //图片文件
                    replystr = TGLocalized(@"Message.File");
                    
                }
            }
            
        }
        
    }
    
    
    return replystr;
    
}





+ (Message_Types)replyTypeMessage:(TGMessage *)message
{
    int messagenmber = (int)[message.mediaAttachments count];
    
    Message_Types messageTypes;
    
    if (![message.text isEqualToString:@""] && message.text) {
        
        messageTypes = TextMessages;
        
    }else{
        
        for (int i = 0; i < messagenmber; i++) {
            
            if ([message.mediaAttachments[i] isKindOfClass:[TGImageMediaAttachment class]]) {
                //图片
                
                NSLog(@"图片+++++++++++++++");
                
                
                messageTypes = ImageMessages;
                
                
                
            }else if ([message.mediaAttachments[i] isKindOfClass:[TGVideoMediaAttachment class]]){
                //视频
                NSLog(@"视频+++++++++++++++");
                

                messageTypes = VedioMessages;
                
                
            }else if ([message.mediaAttachments[i] isKindOfClass:[TGLocationMediaAttachment class]]){
                //位置
                NSLog(@"位置+++++++++++++++");
                
                messageTypes = LocationMessages;
                
            }else if ([message.mediaAttachments[i] isKindOfClass:[TGContactMediaAttachment class]]){
                //联系人
                NSLog(@"联系人+++++++++++++++");
                
                
                messageTypes = ContactsMessages;
                
                
                
            }else if ([message.mediaAttachments[i] isKindOfClass:[TGDocumentMediaAttachment class]]){
                //语音   本地表情
                NSLog(@"语音   本地表情+++++++++++++++");
                
                TGDocumentMediaAttachment *documentMedia = message.mediaAttachments[i];
                
                if ([documentMedia.mimeType isEqualToString:@"audio/ogg"]) {
                    //语音
                    
                    
                    messageTypes = VoiceMessages;
                    
                    
                }else if([documentMedia.mimeType isEqualToString:@"image/webp"]){
                    //表情
                    
                    
                    messageTypes = PasterMessages;
                    
                }else{
                    //image/jpeg
                    //图片文件
                    
                    messageTypes = FileMessages;
                }
            }
            
        }
        
    }
    
    
    
    
    return messageTypes;
    
}







+ (NSString *)filePathForRemoteImageId:(int64_t)remoteImageId
{
    static NSString *filesDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      filesDirectory = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"files"];
                  });
    
    NSString *photoDirectoryName = [[NSString alloc] initWithFormat:@"image-remote-%" PRIx64 "", remoteImageId];
    NSString *photoDirectory = [filesDirectory stringByAppendingPathComponent:photoDirectoryName];
    
    NSString *imagePath = [photoDirectory stringByAppendingPathComponent:@"image.jpg"];
    return imagePath;
}




@end
