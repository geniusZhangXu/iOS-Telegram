//
//  TGReceiveMessageDatabase.h
//  Telegraph
//
//  Created by SKOTC on 17/4/19.
//
//

#import <Foundation/Foundation.h>

@interface TGReceiveMessageDatabase : NSObject

+ (instancetype)sharedInstance;


/**
 给表里面插入消息DI，内容ID，和PreeID,这个preeID 主要是为了在广播的时候能够获取到消息

 @param messageID 消息ID
 @param contentId 内容ID
 @param preeID preeID description
 */
-(void)updateReceiveMessageTableWithmessageID:(NSString *)messageID andContentId:(NSString *)contentId andPreeID:(NSString *)preeID;


/**
 通过内容ID查找到消息ID

 @param contentId 内容ID
 @return return value description
 */
-(NSString *)selectReceiveMessageTableForMessageIdWithContentId:(NSString *)contentId;


/**
 查找表当中是不是有这个内容ID

 @param contentId 内容ID
 @return return value description
 */
-(BOOL)deleteReceiveMessageTableWithContentId:(NSString *)contentId;



/**
 查找表当中是不是有这个消息ID

 @param messageId 消息ID
 @return return value description
 */
-(BOOL)deleteReceiveMessageTableWithMessageId:(NSString *)messageId;



/**
 查找表当中的PreeID 通过内容ID

 @param contentId 内容ID
 @return return value description
 */
-(NSString *)selectReceiveMessageTableForPreeIdWithContentId:(NSString *)contentId;

@end
