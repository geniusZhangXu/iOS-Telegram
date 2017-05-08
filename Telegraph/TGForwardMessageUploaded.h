//
//  TGForwardMessageUploaded.h
//  Telegraph
//
//  Created by SKOTC on 17/4/25.
//
//

#import <Foundation/Foundation.h>
#import "TGPreparedForwardedMessage.h"
#import "TGUser.h"
#import "TGDatabase.h"
#import "TGPreparedLocalDocumentMessage.h"
#import "TGAppDelegate.h"
#import "TGPeerIdAdapter.h"
#import "TGUpdateMessageToServer.h"
#import "TGImageUtils.h"
#import "TGTelegraph.h"


@interface TGForwardMessageUploaded : NSObject


/**
 判断转发的消息类型拼接参数调用上传方法
 
 @param preparedMessage        发送的消息
 @param toUid                  接收者的UID
 @param messageInfoDictionary  这个字典传的是群聊或者广播消息的群名称，频道ID等相关的信息
 @param chat_mod               聊天的类型
 */
+(void)UploadForwardMessageToServeWithMessage:(TGPreparedForwardedMessage *)preparedMessage andToUid:(int32_t)toUid  andGroupMessageInfo:(NSDictionary *)messageInfoDictionary  andChatMod:(Chat_Mod)chat_mod;

@end
