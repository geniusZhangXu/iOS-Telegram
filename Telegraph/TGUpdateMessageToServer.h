//
//  TGUpdateMessageToServer.h
//  Telegraph
//
//  Created by SKOTC on 17/4/10.
//
//

#import <Foundation/Foundation.h>
#import "SYNetworking.h"

/**
 发送还是接收判断

 - is_send:    发送
 - is_receive: 接收
 */
typedef NS_ENUM(NSInteger,IS_Send){
    
    TG_send,
    TG_receive,
};


/**
 发送类型

 - is_commomsend:     普通发送
 - is_forwarding:     转发
 - is_replyforwarded: 回复转发
 */
typedef NS_ENUM(NSInteger,IS_Forward){
    
    is_commomsend,
    is_forwarding,
    is_replyforwarded,
};



/**
 聊天类型

 - commomChat: 普通聊天
 - groupChat:  群聊
 - secretChat: 私密聊天
 - broadcast:  广播
 */
typedef NS_ENUM(NSInteger,Chat_Mod){
    
    commomChat,
    groupChat,
    secretChat,
    broadcast,
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
typedef NS_ENUM(NSInteger,Message_Type){
    
    ImageMessage,
    VedioMessage,
    ContactsMessage,
    FileMessage,
    GifMessage,
    LocationMessage,
    WebMessage,
    MusicMessage,
    VoiceMessage,
    GameMessage,
    TextMessage,
    PasterMessage,
};


typedef void(^UpdataToServeSuccess)();
typedef void(^UpdataToServeFaile)();


@interface TGUpdateMessageToServer : NSObject


/**
 判断保存聊天消息到服务器
 
 @param fixedDictionary   固定参数
 @param is_send           判断是发送还是接收
 @param is_forward        判断发送类型
 @param chat_mod          聊天类型
 @param message_type      消息类型
 @param contentDictionary 消息内容
 */
+(void)TGUpdateMessageToServerWithFixedDictionary:(NSDictionary * _Nonnull)fixedDictionary andis_send:(IS_Send)is_send andIs_forward:(IS_Forward)is_forward  andChat_mod:(Chat_Mod)chat_mod andMessageType:(Message_Type)message_type andContentMessage:(NSDictionary * _Nonnull)contentDictionary;

@end
