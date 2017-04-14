//
//  NSString+SYisBlankString.m
//  Telegraph
//
//  Created by yoyowill on 17/3/3.
//
//

#import "NSString+SYisBlankString.h"

@implementation NSString (SYisBlankString)

+ (BOOL) isNonemptyString:(NSString *)string {
    if (string == nil || string == NULL) {
        return NO;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return NO;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return NO;
    }
    return YES;
}

@end
