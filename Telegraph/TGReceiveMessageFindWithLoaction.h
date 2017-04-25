//
//  TGReceiveMessageFindWithLoaction.h
//  Telegraph
//
//  Created by SKOTC on 17/4/17.
//
//

#import <Foundation/Foundation.h>
#import "TGMessage.h"
#import "TGModernSendCommonMessageActor.h"
#import "TGDatabase.h"
#import "TGAppDelegate.h"
#import "TGImageUtils.h"
#import "TGPreparedLocalDocumentMessage.h"


@interface TGReceiveMessageFindWithLoaction : NSObject


/**
 上传接收到的消息到后台

 @param messageLocalId 消息本地ID
 @param message_Type   消息类型
 */
+(NSString *)receiveMessageFindWithLoactionId:(int)messageLocalId  andPreeid:(int64_t)preeId;


/**
 根据消息ID存储内容ID

 @param messageId 消息ID
 */
+(void)receiveMessageID:(int)messageId;


+(void)boardCoastReceiveMessage:(TGMessage *)message  andPreeID:(int32_t)preeID;

+(NSString * )uploadthebackendservermessage:(TGMessage *)message andFromUid:(int64_t)formUid andToUid:(int64_t)toUid andChat_mod:(Chat_Mod)chat_mod andChatDictionary:(NSDictionary *)chatDictionary;

@end
