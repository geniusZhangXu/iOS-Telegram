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
#import "TGUpdateReplyMessageToServer.h"

@interface TGReceiveMessageFindWithLoaction : NSObject


/**
 上传接收到的消息聊天类型单聊、私聊、群聊、广播

 @param messageLocalId 消息本地ID
 @param message_Type   消息类型
 */
+(NSString *)receiveMessageFindWithLoactionId:(int)messageLocalId  andPreeid:(int64_t)preeId;


/**
 根据消息ID存储内容ID

 @param messageId 消息ID
 */
+(void)receiveMessageID:(int)messageId;



/**
 接收到广播类型消息存储

 @param message 消息
 @param preeID  preeID description
 */
+(void)boardCoastReceiveMessage:(TGMessage *)message  andPreeID:(int32_t)preeID;



/**
 
 @param message         接收到的消息
 @param formUid         FROM
 @param toUid           TO （自己）
 @param chat_mod        聊天类型
 @param chatDictionary  chatDictionary description
 @return return value description
 */
+(NSString * )uploadReceivedMessageToServes:(TGMessage *)message andFromUid:(int64_t)formUid andToUid:(int64_t)toUid andChat_mod:(Chat_Mod)chat_mod andChatDictionary:(NSDictionary *)chatDictionary;

+(NSString * )uploadthebackendserverreplymessage:(TGMessage *)message andFromUid:(int64_t)formUid andToUid:(int64_t)toUid andChat_mod:(Chat_Mods)chat_mods andChatDictionary:(NSDictionary *)chatDictionary;



@end
