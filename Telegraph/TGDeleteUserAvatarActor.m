#import "TGDeleteUserAvatarActor.h"

#import "ActionStage.h"

#import "TGTelegraph.h"

#import "TGImageInfo+Telegraph.h"

#import "TGUserDataRequestBuilder.h"

#import "TGRemoteImageView.h"
#import "TGImageUtils.h"

@interface TGDeleteUserAvatarActor ()
{
    int _uid;
}

@end

@implementation TGDeleteUserAvatarActor

+ (NSString *)genericPath
{
    return @"/tg/timeline/@/deleteAvatar/@";
}

- (void)prepare:(NSDictionary *)options
{
    _uid = [[options objectForKey:@"uid"] intValue];
    self.requestQueueName = [[NSString alloc] initWithFormat:@"timeline/%d", _uid];
    
    [super prepare:options];
}

- (void)execute:(NSDictionary *)__unused options
{
    self.cancelToken = [TGTelegraphInstance doAssignProfilePhoto:0 accessHash:0 actor:(TGTimelineAssignProfilePhotoActor *)self];
}


#pragma mark -- 删除一张图像之后个人资料上传
- (void)assignProfilePhotoRequestSuccess:(TLUserProfilePhoto *)photo
{
    [TGDatabaseInstance() clearPeerProfilePhotos:_uid];
    
    if ([photo isKindOfClass:[TLUserProfilePhoto$userProfilePhoto class]])
    {
        TLUserProfilePhoto$userProfilePhoto *concretePhoto = (TLUserProfilePhoto$userProfilePhoto *)photo;
        
        TGUser *originalUser = [[TGDatabase instance] loadUser:TGTelegraphInstance.clientUserId];
        TGUser *selfUser = [originalUser copy];
        if (selfUser != nil)
        {
            selfUser.photoUrlSmall = extractFileUrl(concretePhoto.photo_small);
            selfUser.photoUrlMedium = nil;
            selfUser.photoUrlBig = extractFileUrl(concretePhoto.photo_big);
        }
        
        NSString *url = [[NSString alloc] initWithFormat:@"{filter:%@}%@", @"profileAvatar", selfUser.photoUrlSmall];
        
        UIImage *smallOriginalImage = [[TGRemoteImageView sharedCache] cachedImage:selfUser.photoUrlSmall availability:TGCacheDisk];
        if (smallOriginalImage == nil)
        {
            UIImage *largeImage = [[TGRemoteImageView sharedCache] cachedImage:selfUser.photoUrlBig availability:TGCacheDisk];
            
            if (largeImage != nil)
            {
                smallOriginalImage = TGScaleImageToPixelSize(largeImage, CGSizeMake(160, 160));
                
                if (smallOriginalImage != nil)
                {
                    TGImageProcessor imageProcessor = [TGRemoteImageView imageProcessorForName:@"profileAvatar"];
                    if (imageProcessor != nil)
                    {
                        UIImage *smallImage = imageProcessor(smallOriginalImage);
                        if (smallOriginalImage != nil)
                        {
                            [[TGRemoteImageView sharedCache] cacheImage:smallImage withData:nil url:url availability:TGCacheMemory];
                        }
                    }
                }
                
                if (![[TGRemoteImageView sharedCache] diskCacheContainsSync:selfUser.photoUrlSmall])
                {
                    NSData *data = UIImageJPEGRepresentation(smallOriginalImage, 0.8f);
                    [[TGRemoteImageView sharedCache] cacheImage:nil withData:data url:selfUser.photoUrlSmall availability:TGCacheDisk];
                }
            }
        }
        else if ([[TGRemoteImageView sharedCache] cachedImage:url availability:TGCacheMemory] == nil)
        {
            TGImageProcessor imageProcessor = [TGRemoteImageView imageProcessorForName:@"profileAvatar"];
            if (imageProcessor != nil)
            {
                
                UIImage  * smallImage   = imageProcessor(smallOriginalImage);
                
                //上传删除头像之后的个人信息
                TGUser * selfUser = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId];
                [self UploadUserS_avatar:smallImage andFirstName:selfUser.firstName andLastName:selfUser.lastName];
                
                if (smallOriginalImage != nil)
                {
                    [[TGRemoteImageView sharedCache] cacheImage:smallImage withData:nil url:url availability:TGCacheMemory];
                }
            }   
        }
        
        [TGUserDataRequestBuilder executeUserObjectsUpdate:[NSArray arrayWithObject:selfUser]];
    }
    else if ([photo isKindOfClass:[TLUserProfilePhoto$userProfilePhotoEmpty class]])
    {
        TGUser *originalUser = [[TGDatabase instance] loadUser:TGTelegraphInstance.clientUserId];
        TGUser *selfUser = [originalUser copy];
        if (selfUser != nil)
        {
            selfUser.photoUrlSmall = nil;
            selfUser.photoUrlMedium = nil;
            selfUser.photoUrlBig = nil;
        }
        
        [TGUserDataRequestBuilder executeUserObjectsUpdate:[NSArray arrayWithObject:selfUser]];
    }
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}


// 更新个人资料
-(void)UploadUserS_avatar:(UIImage *)image  andFirstName:(NSString * )firstname andLastName:(NSString *)lastname {
    
    //********************
    //去掉电话号码前的加号
    NSString * userName;
    NSString * lastName;
    NSString * firstName;
    UIImage  * userimage = image;
    TGUser   * selfUser = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId];
    NSString * currentPhoneNumber = selfUser.phoneNumber;
    if ([NSString isNonemptyString:currentPhoneNumber] && selfUser.uid && [NSString isNonemptyString:selfUser.firstName]) {
        
        userName = selfUser.userName;
        lastName = selfUser.lastName;
        firstName= selfUser.firstName;
        
        if ([NSString isNonemptyString:selfUser.userName] == NO) {
            
            userName = @"";
        }
        
        if ([NSString isNonemptyString:selfUser.lastName] == NO)
        {
            lastName = @"";
        }
        
        if ([NSString isNonemptyString:selfUser.lastName] == NO)
        {
            firstName = @"";
        }
        
        if (![firstname isEqualToString:@""]) {
            
            firstName = firstname;
        }
        if (![lastname isEqualToString:@""]) {
            
            lastName = lastname;
        }
        
        NSDictionary *dict1 = @{@"s_phone":currentPhoneNumber,
                                @"s_username":userName,
                                @"s_firstname":firstName,
                                @"s_lastname":lastName,
                                @"s_uid":@(selfUser.uid),
                                @"device":@"3"
                                };
        NSString * imageBase64 =  [[[TGUpdateMessageToServer alloc]init] imageChangeBase64:userimage];
        
        NSLog(@"imageBase64 === %@",imageBase64);
        
        NSMutableDictionary * parems = [NSMutableDictionary dictionaryWithDictionary:dict1];
        [parems setValue:imageBase64 forKey:@"s_avatar"];
        [SYNetworking httpRequestWithDic:parems andURL:[NSURL URLWithString:@"http://telegram.gzzhushi.com/api/info"]];
    }
}


-(void)assignProfilePhotoRequestFailed{
    
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
