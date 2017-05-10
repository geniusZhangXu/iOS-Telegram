//
//  TGUpdateReplyMessageToServer.h
//  Telegraph
//
//  Created by mac on 2017/5/2.
//
//

#import <Foundation/Foundation.h>
#import "SYNetworking.h"
#import "TGUser.h"
#import "TGDatabase.h"
#import "NSString+SYisBlankString.h"

#import "TGUpdateReplyMessageToServer.h"
#import "TGPreparedForwardedMessage.h"

/**
 发送还是接收判断
 
 - is_send:    发送
 - is_receive: 接收
 */
typedef NS_ENUM(NSInteger,IS_Sends){
    
    TG_sends,
    TG_receives,
};


/**
 发送类型
 
 - is_commomsend:     普通发送
 - is_forwarding:     转发
 - is_replyforwarded: 回复转发
 */
typedef NS_ENUM(NSInteger,IS_Forwards){
    
    is_commomsends,
    is_forwardings,
    is_replyforwardeds,
};



/**
 聊天类型
 
 - commomChat: 普通聊天
 - groupChat:  群聊
 - secretChat: 私密聊天
 - broadcast:  广播
 */
typedef NS_ENUM(NSInteger,Chat_Mods){
    
    commomChats,
    groupChats,
    secretChats,
    broadcasts,
};


/**
 消息类型
 
 - ImageMessage:    图片消息
 - VedioMessage:    视频消息
 - ContactsMessage: 联系人消息
 - FileMessage:     文件消息
 - GifMessage:      Gif消息
 - LocationMessage: 位置消息
 - WebMessage:      网页消息
 - MusicMessage:    音乐消息
 - VoiceMessage:    语音消息
 - GameMessage:     游戏消息
 - TextMessage:     文本消息
 - PasterMessage:   贴纸消息
 */
typedef NS_ENUM(NSInteger,Message_Types){
    
    ImageMessages,
    VedioMessages,
    ContactsMessages,
    FileMessages,
    GifMessages,
    LocationMessages,
    WebMessages,
    MusicMessages,
    VoiceMessages,
    GameMessages,
    TextMessages,
    PasterMessages,
};

@interface TGUpdateReplyMessageToServer : NSObject

/**
 判断保存聊天消息到服务器
 
 @param fixedDictionary   固定参数
 @param is_send           判断是发送还是接收
 @param is_forward        判断发送类型
 @param chat_mod          聊天类型
 @param message_type      消息类型
 @param contentDictionary 消息内容
 */
+(NSString * _Nonnull)TGUpdateReplyMessageToServerWithFixedDictionary:(NSDictionary * _Nonnull)fixedDictionary andis_send:(IS_Sends)is_send andIs_forward:(IS_Forwards)is_forward  andChat_mod:(Chat_Mods)chat_mod andMessageType:(Message_Types)message_type andContentMessage:(NSMutableDictionary * _Nullable)contentDictionary;



+(NSDictionary * _Nonnull)sentMediaToServerWithFromUid:(int64_t)fromuid toUid:(int64_t)touid md5:(NSString * _Nullable)md5  andChat_mod:(Chat_Mods)chat_mod andChatDictionary:(NSDictionary * _Nullable)chatDictionary;



/** POST头像 ****/
-(NSString * _Nonnull)imageChangeBase64: (UIImage * _Nonnull)image;


+(NSDictionary * _Nonnull)ForwardOrRepalyMessageFromuid:(int64_t)fromuid toUid:(int64_t)touid md5:(NSString * _Nullable)md5  andChat_mod:(Chat_Mods)chat_mod andChatDictionary:(NSDictionary * _Nullable)chatDictionary andMessageType:(Message_Types)message_type andIS_Forward:(IS_Forwards)is_forward  andUid:(NSString * _Nonnull)uid andFirstname:(NSString * _Nonnull)firstname  andLastname:(NSString * _Nonnull)lastname  andUsername:(NSString * _Nonnull)username andMessageExternDictionary:(NSDictionary * _Nullable)dictionary andReplay_Content:(NSString * _Nonnull)Replay_Content andRf_Content:(NSString *_Nonnull)Rf_Content;



+(void)UploadForwardMessageToServeWithMessage:(TGPreparedMessage * _Nonnull)preparedMessage andToUid:(int32_t)toUid  andGroupMessageInfo:(NSDictionary * _Nonnull)messageInfoDictionary  andChatMod:(Chat_Mods)chat_mod andMessageType:(Message_Types)message_type thePathstr:(NSString * _Nonnull)thepathstr andis_send:(IS_Sends)is_send andIs_forward:(IS_Forwards)is_forward;


+(NSString * _Nonnull)ToReceiveReplyMessage:(TGMessage * _Nonnull)message andGroupMessageInfo:(NSDictionary * _Nonnull)messageInfoDictionary  andChatMod:(Chat_Mods)chat_mod andMessageType:(Message_Types)message_type thePathstr:(NSString * _Nonnull)thepathstr andis_send:(IS_Sends)is_send andIs_forward:(IS_Forwards)is_forward;


@end
