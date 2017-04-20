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

-(void)updateReceiveMessageTableWithmessageID:(NSString *)messageID andContentId:(NSString *)contentId;

-(NSString *)selectReceiveMessageTableForMessageIdWithContentId:(NSString *)contentId;

-(BOOL)deleteReceiveMessageTableWithContentId:(NSString *)contentId;

-(BOOL)deleteReceiveMessageTableWithMessageId:(NSString *)messageId;
@end
