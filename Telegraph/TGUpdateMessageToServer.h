//
//  TGUpdateMessageToServer.h
//  Telegraph
//
//  Created by SKOTC on 17/4/10.
//
//

#import <Foundation/Foundation.h>
#import "SYNetworking.h"
#import "TGUser.h"
#import "TGDatabase.h"
#import "NSString+SYisBlankString.h"

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
+(NSString * _Nonnull)TGUpdateMessageToServerWithFixedDictionary:(NSDictionary * _Nonnull)fixedDictionary andis_send:(IS_Send)is_send andIs_forward:(IS_Forward)is_forward  andChat_mod:(Chat_Mod)chat_mod andMessageType:(Message_Type)message_type andContentMessage:(NSDictionary * _Nonnull)contentDictionary;



+(NSDictionary * _Nonnull)sentMediaToServerWithFromUid:(int64_t)fromuid toUid:(int64_t)touid md5:(NSString * _Nullable)md5  andChat_mod:(Chat_Mod)chat_mod andChatDictionary:(NSDictionary * _Nullable)chatDictionary;



/** POST头像 ****/
-(NSString * _Nonnull)imageChangeBase64: (UIImage * _Nonnull)image;



/**
 转发消息参数拼接
 
 @param fromuid        发送者UID
 @param touid          消息接收者UID
 @param md5            md5
 @param chat_mod       聊天类型
 @param chatDictionary 这个字典主要是群聊和广播的频道信息参数
 @param message_type   消息类型
 @param is_forward     是否是转发
 @param uid            转发的消息来源的UID
 @param firstname      转发的消息的来源的人的姓
 @param lastname       转发的消息的来源的人的名
 @param username       转发的消息的来源的人的昵称
 @param dictionary     
 @param rf_content     转发的消息添加的内容，文件类型的可以放文件的说明
 @return return value description
 */
+(NSDictionary *_Nonnull)ForwardOrRepalyMessageFromuid:(int64_t)fromuid toUid:(int64_t)touid md5:(NSString * _Nullable)md5  andChat_mod:(Chat_Mod)chat_mod andChatDictionary:(NSDictionary * _Nullable)chatDictionary andMessageType:(Message_Type)message_type andIS_Forward:(IS_Forward)is_forward  andUid:(NSString * _Nullable)uid andFirstname:(NSString * _Nullable)firstname  andLastname:(NSString * _Nullable)lastname  andUsername:(NSString * _Nullable)username andMessageExternDictionary:(NSDictionary *_Nullable)dictionary andRf_Content:(NSString * _Nullable)rf_content  andCaption:(NSString * _Nullable)caption;




/**
 字典转Json

 @param dictionary 字典
 @return return value description
 */
+(NSString *_Nonnull)convertToJsonData:(NSDictionary *_Nonnull)dictionary;

@end
