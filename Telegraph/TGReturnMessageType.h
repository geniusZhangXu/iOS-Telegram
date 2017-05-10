//
//  TGReturnMessageType.h
//  Telegraph
//
//  Created by mac on 2017/4/28.
//
//

#import <Foundation/Foundation.h>

#import "TGMessage.h"
#import "TGAppDelegate.h"
#import "TGVideoDownloadActor.h"

@interface TGReturnMessageType : NSObject


+ (NSString *)judgeReplyTypeMessage:(TGMessage *)message;

+ (Message_Types)replyTypeMessage:(TGMessage *)message;

@end
