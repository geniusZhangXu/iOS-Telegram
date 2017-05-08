#import "TGSignInRequestBuilder.h"
#import "TGTelegramNetworking.h"
#import "ActionStage.h"
#import "SGraphObjectNode.h"
#import "TGTelegraph.h"
#import "TGSchema.h"
#import "TGUser.h"
#import "TGUserDataRequestBuilder.h"
#import "TGTimer.h"
#import "TLUser$modernUser.h"
#import "TGImageInfo+Telegraph.h"

#import "TGLetteredAvatarView.h"
#import "TGUpdateMessageToServer.h"

@interface TGSignInRequestBuilder ()
{
    NSString *_phoneNumber;
    NSString *_phoneHash;
    NSString *_phoneCode;
    
    TGTimer *_timer;
}

@end

@implementation TGSignInRequestBuilder

- (id)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        self.cancelTimeout = 0;
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
}

+ (NSString *)genericPath
{
    return @"/tg/service/auth/signIn/@";
}

- (void)execute:(NSDictionary *)options
{
    _phoneNumber = [options objectForKey:@"phoneNumber"];
    _phoneHash = [options objectForKey:@"phoneCodeHash"];
    _phoneCode = [options objectForKey:@"phoneCode"];
    if (_phoneNumber == nil || _phoneHash == nil || _phoneCode == nil)
    {
        [self signInFailed:TGSignInResultInvalidToken];
        return;
    }
    
    ASHandle *actionHandle = _actionHandle;
    _timer = [[TGTimer alloc] initWithTimeout:15.0 repeat:false completion:^
    {
        [actionHandle requestAction:@"networkTimeout" options:nil];
    } queue:[ActionStageInstance() globalStageDispatchQueue]];
    [_timer start];
    
    self.cancelToken = [TGTelegraphInstance doSignIn:_phoneNumber phoneHash:_phoneHash phoneCode:_phoneCode requestBuilder:self];
}

#pragma mark-- 登录成功回调
-(void)signInSuccess:(TLauth_Authorization *)authorization{
    
    [TGUserDataRequestBuilder executeUserDataUpdate:[NSArray arrayWithObject:authorization.user]];
    
    bool activated = true;
    
    [TGTelegraphInstance processAuthorizedWithUserId:((TLUser$modernUser *)authorization.user).n_id clientIsActivated:activated];
    
    [ActionStageInstance() actionCompleted:self.path result:[[SGraphObjectNode alloc] initWithObject:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithBool:activated], @"activated", nil]]];
    
    // 上传个人资料
    TLUser$modernUser * user = (TLUser$modernUser  *)authorization.user;
    NSURL  *  url = [NSURL URLWithString:@"http://telegram.gzzhushi.com/api/info"];// 当前用户信息接口
    
    NSMutableDictionary * userDic =[NSMutableDictionary dictionary];
    [userDic setValue:[self changeParmsWith:[NSString stringWithFormat:@"%d",user.n_id]] forKey:@"s_uid"];
    [userDic setValue:[NSString stringWithFormat:@"+%@",[self changeParmsWith:user.phone]] forKey:@"s_phone"];
    [userDic setValue:[self changeParmsWith:user.first_name ] forKey:@"s_firstname"];
    [userDic setValue:[self changeParmsWith:user.last_name ] forKey:@"s_lastname"];
    [userDic setValue:[self changeParmsWith:user.username ] forKey:@"s_username"];
    
    // 这里说一下，后台是做了处理，当传空值的时候是不会修改头像的，在登录的时候是不会涉及到换头像内容的修改的，再加上这里登录之后的头像难获取到
    // 就在这里处理了传空值
    [userDic setValue:@"" forKey:@"s_avatar"];
    [userDic setValue:@"3" forKey:@"device"];
   
    [SYNetworking httpRequestWithDic:userDic andURL:url];

}


-(NSString *)changeParmsWith:(NSString *)Parms{
    
    NSString * change;
    if (Parms){
        
        change = Parms;
        
    }else{
        
        change = @"";
    }
    
    return  change;
}


-(void)signInFailed:(TGSignInResult)reason{
    
    [ActionStageInstance() actionFailed:self.path reason:reason];
}

-(void)signInRedirect:(NSInteger)datacenterId
{
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
    
    [[TGTelegramNetworking instance] moveToDatacenterId:datacenterId];
    
    ASHandle *actionHandle = _actionHandle;
    _timer = [[TGTimer alloc] initWithTimeout:15.0 repeat:false completion:^
    {
        [actionHandle requestAction:@"networkTimeout" options:nil];
    } queue:[ActionStageInstance() globalStageDispatchQueue]];
    [_timer start];
    
    self.cancelToken = [TGTelegraphInstance doSignIn:_phoneNumber phoneHash:_phoneHash phoneCode:_phoneCode requestBuilder:self];
}

- (void)cancel
{
    if (self.cancelToken != nil)
    {
        [TGTelegraphInstance cancelRequestByToken:self.cancelToken];
        self.cancelToken = nil;
    }
    
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
    
    [super cancel];
}

#pragma mark -

- (void)actionStageActionRequested:(NSString *)action options:(id)__unused options
{
    if ([action isEqualToString:@"networkTimeout"])
    {
        if (self.cancelToken != nil)
        {
            [TGTelegraphInstance cancelRequestByToken:self.cancelToken];
            self.cancelToken = nil;
        }
        
        [self signInFailed:TGSignInResultNetworkError];
    }
}

@end
