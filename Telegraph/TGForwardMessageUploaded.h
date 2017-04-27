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

@interface TGForwardMessageUploaded : NSObject


+(void)UploadForwardMessageToServeWithMessage:(TGPreparedForwardedMessage *)preparedMessage andConversationId:(int)conversationId;

@end
