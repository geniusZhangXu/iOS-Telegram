//
//  TgramTests.m
//  TgramTests
//
//  Created by SKOTC on 17/5/4.
//
//

#import <XCTest/XCTest.h>
#import "TGUser.h"
#import "TGDatabaseInterface.h"
#import "TGDatabase.h"
#import "TGLetteredAvatarView.h"
#import "TGImageManager.h"
#import "TGUpdateMessageToServer.h"


@interface TgramTests : XCTestCase


@property(nonatomic,strong) TGUser * user;

@end

@implementation TgramTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // 初始化变量
    _user = [TGDatabaseInstance() loadUser:345497340];
    

}


-(void)testSYNetworkingRequest{

     [SYNetworking httpRequestWithURL:[NSURL URLWithString:@"http://telegram.gzzhushi.com/config.json"] andHttpRequestSuccess:^(NSDictionary * dictionary) {
        
        NSLog(@"解析服务器返回的数据====%@", dictionary);
             
     } andHttpRequestFail:^(NSString * code) {
             
        NSLog(@"解析服务器返回的数据====%@", code);

     }];

}



-(void)testUserPhoneActor{
   
    UIImage * image = [[TGImageManager instance] loadImageSyncWithUri:_user.photoUrlSmall canWait:false decode:true acceptPartialData:false asyncTaskId:NULL progress:^(float process) {
        
        NSLog(@"我是你登录的人的头像啦啦啦啦啦啦啦 %f",process);
        
    } partialCompletion:^(UIImage * image) {
        
        UIImage *imageManagerImage = image;
        NSString * avatarString =  [[[TGUpdateMessageToServer alloc]init] imageChangeBase64:imageManagerImage];
        NSLog(@"我是你登录的人的头像啦啦啦啦啦啦啦 %@",avatarString);
        
    } completion:^(UIImage * image) {
        
        UIImage *imageManagerImage = image;
        NSString * avatarString =  [[[TGUpdateMessageToServer alloc]init] imageChangeBase64:imageManagerImage];
        NSLog(@"我是你登录的人的头像啦啦啦啦啦啦啦 %@",avatarString);
        
    }];
    
    TGLetteredAvatarView * _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
    [_avatarView loadImage:_user.photoUrlSmall filter:@"circle:60x60" placeholder:nil];
     
    NSString * avatarString =  [[[TGUpdateMessageToServer alloc]init] imageChangeBase64:_avatarView.image];
    NSLog(@"我是你登录的人的头像啦啦啦啦啦啦啦 %@",avatarString);

}



- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
