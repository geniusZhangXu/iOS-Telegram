//
//  TGReceiveMessageDatabase.m
//  Telegraph
//
//  Created by SKOTC on 17/4/19.
//
//

#import "TGReceiveMessageDatabase.h"
#import "FMDatabase.h"

@interface TGReceiveMessageDatabase()
{
    FMDatabase * dataBase;
}
@end

@implementation TGReceiveMessageDatabase

static id _instance;


+(instancetype)allocWithZone:(struct _NSZone *)zone{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+(instancetype)sharedInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        
        [self creatReceiveMessageDatabaseTable];
    }
    return self;
}

/**
   打开数据库创建receiveMessage表
 */
-(void)creatReceiveMessageDatabaseTable{

    NSString * path  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString * sqlFilePath = [path stringByAppendingPathComponent:@"receiveMessage.sqlite"];
    dataBase = [FMDatabase databaseWithPath:sqlFilePath];
    if ([dataBase open]) {
        
        NSLog(@"数据库打开成功");
    }
    
    BOOL success = [dataBase executeUpdate:@"CREATE TABLE IF NOT EXISTS receiveMessage (messageId TEXT, contentId TEXT)"];
    
    if (success) {
        
         NSLog(@"数据表创建成功");
        
    }else{
        
          NSLog(@"数据表创建失败");
    }
}


/**
 插入一条数据

 @param messageID 插入的消息ID
 @param contentId 内容ID（这个图片就是图片ID，视频就是视频ID，语音和贴纸表情都是相应的ID）
 */
-(void)updateReceiveMessageTableWithmessageID:(NSString *)messageID andContentId:(NSString *)contentId{
   
    if (![self selectReceiveMessageTableWithContentId:contentId]) {
       
        BOOL insert = [dataBase executeUpdate:@"INSERT INTO receiveMessage(messageID,contentId) VALUES (?,?)",messageID,contentId];
        if (insert) {
            
            NSLog(@"插入成功");
        }else{
            NSLog(@"插入失败");
        }
    }
}



/**
 查询表里面有没有存储该内容ID

 @param contentId contentId description
 @return return value description
 */
-(BOOL)selectReceiveMessageTableWithContentId:(NSString *)contentId{
   
    FMResultSet * result = [dataBase executeQuery:@"SELECT * FROM receiveMessage WHERE contentId = ?",contentId];
    return [result next];
    
}



/**
 通过contentId找到相应的消息ID

 @param  contentId contentId description
 @return return value description
 */
-(NSString *)selectReceiveMessageTableForMessageIdWithContentId:(NSString *)contentId{
    
    FMResultSet * result = [dataBase executeQuery:@"SELECT messageID FROM receiveMessage WHERE contentId = ?",contentId];
    while ([result next]) {
        
        NSString * messageid  = [result stringForColumn:@"messageID"];
        return messageid;
    }
    return nil;
}


/**
 删除相应的contentId对应的数据

 @param contentId contentId description
 @return          return value description
 */
-(BOOL)deleteReceiveMessageTableWithContentId:(NSString *)contentId{
    
    BOOL result =[dataBase executeUpdate:@"delete from  receiveMessage where contentId=?",contentId];
    if (result) {
        
        NSLog(@"删除成功");
    }else
        NSLog(@"删除失败");
    
    return result;
}



/**
 删除相应的messageId对应的数据源

 @param messageId messageId description
 @return return value description
 */
-(BOOL)deleteReceiveMessageTableWithMessageId:(NSString *)messageId{
    
    BOOL result =[dataBase executeUpdate:@"delete from  receiveMessage where messageID=?",messageId];
    if (result) {
        
        NSLog(@"删除成功");
    }else
        NSLog(@"删除失败");
    
    return result;
}

@end
