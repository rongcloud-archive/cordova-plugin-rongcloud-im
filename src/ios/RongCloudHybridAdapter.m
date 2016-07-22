//
//  RongCloudModule.m
//  UZApp
//
//  Created by xugang on 14/12/17.
//  Copyright (c) 2014年 APICloud. All rights reserved.
//

#import "RongCloudHybridAdapter.h"
#import "RongCloudModel.h"
#import "RongCloudConstant.h"
#import "RongCloudApplicationHandler.h"
#import <objc/runtime.h>

#ifdef RC_SUPPORT_IMKIT
#import <RongIMKit/RongIMKit.h>
#import <RongCallKit/RongCallKit.h>
#endif

#define BAD_PARAMETER_CODE -10002
#define BAD_PARAMETER_MSG @"Argument Exception"

#define NOT_INIT_CODE -10000
#define NOT_INIT_MSG @"Not Init"

#define NOT_CONNECT_CODE -10001
#define NOT_CONNECT_MSG @"Not Connected"

#define UNKNOWN_CODE -10003
#define UNKNOWN_MSG @"Unknown"

static BOOL isInited = NO;
static BOOL isConnected = NO;

@interface RongCloudHybridAdapter ()

@property (nonatomic, strong) id connectionCallbackId;
@property (nonatomic,strong) id receiveMessageCbId;
@property (nonatomic, assign)BOOL disableLocalNotification;

@property (nonatomic, weak)id<RongCloud2HybridDelegation> commandDelegate;
@end


@implementation RongCloudHybridAdapter

- (instancetype)initWithDelegate:(id<RongCloud2HybridDelegation>) commandDelegate {
    self = [super init];
    if (self) {
        self.commandDelegate = commandDelegate;
        self.disableLocalNotification = NO;
    }
    return self;
}

/**
 * initialize & connection
 */
-(void)init:(NSString *)appKey callbackId:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![appKey isKindOfClass:[NSString class]]) {
        
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err    = @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        
        return;
    }
    
#ifdef RC_SUPPORT_IMKIT
    [[RCIM sharedRCIM] initWithAppKey:appKey];
#else
    [[RCIMClient sharedRCIMClient] initWithAppKey:appKey];
#endif
    isInited = YES;
        
    NSDictionary *_result = @{@"status":SUCCESS};
    [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
}


- (void)connectWithToken:(NSString *)token callbackId:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);

    
    if (NO == isInited) {
        NSDictionary *_result   =   @{@"status": ERROR};
        NSDictionary *_err      =   @{@"code":@(NOT_INIT_CODE), @"msg": NOT_INIT_MSG};
        
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        return;
    }

    
    if (![token isKindOfClass:[NSString class]]) {
        
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err    = @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        return;
    }

#ifdef RC_SUPPORT_IMKIT
#else
#endif
    void (^successBlock)(NSString *userId) = ^(NSString *userId){
        NSLog(@"%s", __FUNCTION__);
        isConnected           = YES;
        NSDictionary *_result = @{@"status": SUCCESS, @"result": @{@"userId":userId}};
        
        [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
        
    };
    
    void (^errorBlock)(RCConnectErrorCode status) = ^(RCConnectErrorCode status) {
        NSLog(@"%s, errorCode> %ld", __FUNCTION__, (long)status);
        
        isConnected           = YES;
        NSDictionary *_result = @{@"status": ERROR};
        NSDictionary *_err    = @{@"code":@(status), @"msg": @""};
        
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
    };
    
    void (^tokenIncorrectBlock)() = ^{
        NSLog(@"%s, errorCode> %d", __FUNCTION__, 31004);
        
        isConnected           = YES;
        NSDictionary *_result = @{@"status": ERROR};
        NSDictionary *_err    = @{@"code":@(31004), @"msg": @""};
        
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
    };
    
#ifdef RC_SUPPORT_IMKIT
    [[RCIM sharedRCIM] connectWithToken:token success:successBlock error:errorBlock tokenIncorrect:tokenIncorrectBlock];
#else
    [[RCIMClient sharedRCIMClient] connectWithToken:token success:successBlock error:errorBlock tokenIncorrect:tokenIncorrectBlock];
#endif
}


- (BOOL)checkIsInitOrConnect:(id)callbackId doDelete:(BOOL) isDelete
{
    BOOL isContinue = YES;
    if (callbackId) {
        if (NO == isInited) {
            
            NSDictionary *_result = @{@"status": ERROR};
            NSDictionary *_err    = @{@"code":@(NOT_INIT_CODE), @"msg": NOT_INIT_MSG};
            isContinue            = NO;
            
            [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:isDelete];
        }else if (NO == isConnected) {
            NSDictionary *_result = @{@"status": ERROR};
            NSDictionary *_err    = @{@"code":@(NOT_CONNECT_CODE), @"msg": NOT_CONNECT_MSG};
            isContinue            = NO;
            
            [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:isDelete];
        }
    }
    return isContinue;
}

- (BOOL)checkIsInit:(id)callbackId doDelete:(BOOL) isDelete
{
    BOOL isContinue = YES;
    if (callbackId) {
        if (NO == isInited) {
            
            NSDictionary *_result = @{@"status": ERROR};
            NSDictionary *_err    = @{@"code":@(NOT_INIT_CODE), @"msg": NOT_INIT_MSG};
            isContinue            = NO;
            
            [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:isDelete];
            
        }
    }
    return isContinue;
}

- (void)disconnect:(NSNumber *)isReceivePush callbackId:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);

    if (NO == isInited) {
        NSDictionary *_result   =   @{@"status": ERROR};
        NSDictionary *_err      =   @{@"code":@(NOT_INIT_CODE), @"msg": NOT_INIT_MSG};
        
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        return;
    }
    
    if (![isReceivePush isKindOfClass:[NSNumber class]]) {
        
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err    = @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        return;
    }
    
    if (isReceivePush) {
        
        if (1 == isReceivePush.integerValue) {
            [[RCIMClient sharedRCIMClient]disconnect:YES];
        }
        else{
            [[RCIMClient sharedRCIMClient]disconnect:NO];
        }
    }
    else{
        [[RCIMClient sharedRCIMClient]disconnect:YES];
    }
    
    isConnected           = NO;
    NSDictionary *_result = @{@"status": SUCCESS};
    [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];

}

- (void)setConnectionStatusListener:(id)connectionCallbackId
{
    NSLog(@"%s", __FUNCTION__);
    self.connectionCallbackId = connectionCallbackId;
    [[RCIMClient sharedRCIMClient]setRCConnectionStatusChangeDelegate:self];
}

- (void)onConnectionStatusChanged:(RCConnectionStatus)status
{
    if (self.connectionCallbackId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *_result = @{@"result":@{@"connectionStatus":[RongCloudModel RCTransferConnectionStatus:status]}};
            [self.commandDelegate sendResult:_result error:nil withCallbackId:self.connectionCallbackId doDelete:NO];
        });
    }
}

- (void)_sendMessage:(RCConversationType)conversationType withTargetId:(NSString *)targetId withContent:(RCMessageContent *)messageContent withPushContent:(NSString *)pushContent withCallBackId:(id)cbId
{
    __weak __typeof(self)weakSelf = self;
    RCMessage *rcMessage = [[RCIMClient sharedRCIMClient]sendMessage:conversationType
                                                            targetId:targetId
                                                             content:messageContent
                                                         pushContent:pushContent
                                                             success:^(long messageId) {
                                                                 NSLog(@"success");
                                                                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                     NSLog(@"%s", __FUNCTION__);
                                                                     NSLog(@"callback success");
                                                                     NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                                                                     
                                                                     [dic setObject:[NSNumber numberWithLong:messageId] forKey:@"messageId"];
                                                                     
                                                                     [dic setObject:[NSNumber numberWithBool:YES] forKey:@"isSuccess"];
                                                                     
                                                                     NSDictionary *_result = @{@"status":SUCCESS, @"result":@{@"message":@{@"messageId":@(messageId)}}};
                                                                     [weakSelf.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
                                                                 });
                                                             }
                                                               error:^(RCErrorCode nErrorCode, long messageId) {
                                                                   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                       NSLog(@"%s", __FUNCTION__);
                                                                       NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                                                                       
                                                                       [dic setObject:[NSNumber numberWithLong:messageId] forKey:@"messageId"];
                                                                       
                                                                       [dic setObject:[NSNumber numberWithBool:NO] forKey:@"isSuccess"];
                                                                       
                                                                       NSDictionary *_result = @{@"status":ERROR, @"result":@{@"message": @{@"messageId":@(messageId)}}};
                                                                       NSDictionary *_err = @{@"code": @(nErrorCode), @"msg": @""};
                                                                       [weakSelf.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
                                                                   });
                                                               }];
    NSLog(@"perpare");
    NSDictionary *_message = [RongCloudModel RCGenerateMessageModel:rcMessage];
    NSDictionary *_result = @{@"status":PREPARE, @"result": @{@"message":_message}};
    
    [weakSelf.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:NO];
}

/**
 * message send & receive
 */
- (void)sendTextMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId content:(NSString *)textContent extra:(NSString *)extra callbackId:(id)callbackId
{
    
    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }

    NSLog(@"%s", __FUNCTION__);

    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![textContent isKindOfClass:[NSString class]] ||
        ![extra isKindOfClass:[NSString class]]
        ) {
        
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err    = @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];

        return;
    }
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    RCTextMessage *rcTextMessage         = [RCTextMessage messageWithContent:textContent];
    rcTextMessage.extra                  = extra;
    
    [self _sendMessage:_conversationType withTargetId:targetId withContent:rcTextMessage withPushContent:nil withCallBackId:callbackId];

}

- (void)sendImageMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId imagePath:(NSString *)imagePath extra:(NSString *)extra  callbackId:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);

    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }
    
  
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![imagePath isKindOfClass:[NSString class]] ||
        ![extra isKindOfClass:[NSString class]]
        ) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err    = @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        return;
    }
    
    NSString *_truePath = [self.commandDelegate getAbsolutePath:imagePath];
    NSLog(@"_truePath > %@", _truePath);
    
    NSData *imageData   = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:_truePath]];
    UIImage* image      = [UIImage imageWithData:imageData];
    
    if (![image isKindOfClass:[UIImage class]]) {
        
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err    = @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        
        return;
    }
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    
    RCImageMessage *imageMessage         = [RCImageMessage messageWithImage:image];
    imageMessage.extra                   = extra;
    imageMessage.thumbnailImage          = [UIImage imageWithData:[RongCloudModel compressedImageAndScalingSize:image targetSize:CGSizeMake(360.0f, 360.0f) percent:0.4f]];
    
    __weak __typeof(self)weakSelf = self;
    RCMessage *rcMessage = [[RCIMClient sharedRCIMClient] sendImageMessage:_conversationType
                                                                  targetId:targetId
                                                                   content:imageMessage
                                                               pushContent:nil
                                                                  progress:^(int progress, long messageId) {
                                                                      if (0 == progress) {
                                                                          NSDictionary *_result = @{@"status":PROGRESS, @"result": @{@"message":@{@"messageId":@(messageId)}, @"progress":@(0)}};
          
                                                                          [weakSelf.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:NO];
                                                                      }else if (50 == progress)
                                                                      {
                                                                          NSDictionary *_result = @{@"status":PROGRESS, @"result": @{@"message":@{@"messageId":@(messageId)}, @"progress":@(50)}};
                                                                          
                                                                          [weakSelf.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:NO];
                                                                      }else if (100 == progress)
                                                                      {
                                                                          NSDictionary *_result = @{@"status":PROGRESS, @"result": @{@"message":@{@"messageId":@(messageId)}, @"progress":@(100)}};
                                                                          
                                                                          [weakSelf.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:NO];
                                                                      }
                                                                  } success:^(long messageId) {
                                                                      NSLog(@"%s", __FUNCTION__);
                                                                      
                                                                      NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                                                                      
                                                                      [dic setObject:[NSNumber numberWithLong:messageId] forKey:@"messageId"];
                                                                      
                                                                      [dic setObject:[NSNumber numberWithBool:YES] forKey:@"isSuccess"];
                                                                      
                                                                      
                                                                      NSDictionary *_result = @{@"status":SUCCESS, @"result":@{@"message":@{@"messageId":@(messageId)}}};
                                                                      [weakSelf.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
                                                                  } error:^(RCErrorCode errorCode, long messageId) {
                                                                      NSLog(@"%s", __FUNCTION__);
                                                                      NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                                                                      
                                                                      [dic setObject:[NSNumber numberWithLong:messageId] forKey:@"messageId"];
                                                                      
                                                                      [dic setObject:[NSNumber numberWithBool:NO] forKey:@"isSuccess"];
                                                                      
                                                                      NSDictionary *_result = @{@"status":ERROR, @"result":@{@"message": @{@"messageId":@(messageId)}}};
                                                                      NSDictionary *_err = @{@"code": @(errorCode), @"msg": @""};
                                                                      [weakSelf.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
                                            
                                                                  }];
    
    NSDictionary *_message = [RongCloudModel RCGenerateMessageModel:rcMessage];
    NSDictionary *_result = @{@"status":PREPARE, @"result": @{@"message":_message}};

    [weakSelf.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:NO];
}

- (void)sendVoiceMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId voicePath:(NSString *)voicePath duration:(NSNumber *)duration extra:(NSString *)extra  callbackId:(id)callbackId

{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }

    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![voicePath isKindOfClass:[NSString class]] ||
        ![duration isKindOfClass:[NSNumber class]]||
        ![extra isKindOfClass:[NSString class]]
        ) {
        
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err    = @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        return;
    }
    
    NSString *_truePath = [self.commandDelegate getAbsolutePath:voicePath];
    NSLog(@"_truePath > %@", _truePath);
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    
//    NSBundle *myBundle = [NSBundle mainBundle];
//    NSString *testArm = [myBundle pathForResource:@"testVoice" ofType:@"amr"];

    NSData *amrData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:_truePath]];

    if (amrData == nil) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err    = @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        return;
    }
    NSData *wavData ;
    if (amrData.length > 6 && ((unsigned char*)amrData.bytes)[0] == 0x23 && ((unsigned char*)amrData.bytes)[1] == 0x21 && ((unsigned char*)amrData.bytes)[2] == 0x41 && ((unsigned char*)amrData.bytes)[3] == 0x4d && ((unsigned char*)amrData.bytes)[4] == 0x52) {
        //amr first 6 byte are 0x23 0x21 0x41 0x4d 0x52 0X0A(#!AMR.)
        wavData                = [[RCAMRDataConverter sharedAMRDataConverter]decodeAMRToWAVE:amrData];
    } else {
        wavData = amrData;
    }

    RCVoiceMessage *rcVoiceMessage = [RCVoiceMessage messageWithAudio:wavData duration:duration.intValue];
    rcVoiceMessage.extra           = extra;
    [self _sendMessage:_conversationType withTargetId:targetId withContent:rcVoiceMessage withPushContent:nil withCallBackId:callbackId];
}

- (void)sendLocationMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId imagePath:(NSString *)imagePath latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude locationName:(NSString *)locationName extra:(NSString *)extra  callbackId:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:callbackId doDelete:NO]) {
        return;
    }

    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![latitude isKindOfClass:[NSNumber class]] ||
        ![longitude isKindOfClass:[NSNumber class]] ||
        ![locationName isKindOfClass:[NSString class]] ||
        ![imagePath isKindOfClass:[NSString class]]||
        ![extra isKindOfClass:[NSString class]]
        ) {
        
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        return;
    }
    
    NSString *_truePath = [self.commandDelegate getAbsolutePath:imagePath];
    NSLog(@"_truePath > %@", _truePath);
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    CLLocationCoordinate2D location;
    location.latitude                    = (CLLocationDegrees)[latitude doubleValue];
    location.longitude                   = (CLLocationDegrees)[longitude doubleValue];
    
    NSData *thumbnailData                = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:_truePath]];
    
    UIImage *thumbnailImage              = [UIImage imageWithData:thumbnailData];
    
    RCLocationMessage *locationMessage = [RCLocationMessage messageWithLocationImage:thumbnailImage location:location locationName:locationName];
    locationMessage.extra              = extra;
    [self _sendMessage:_conversationType withTargetId:targetId withContent:locationMessage withPushContent:nil withCallBackId:callbackId];
}

- (void)sendRichContentMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId title:(NSString *)title content:(NSString *)content imageUrl:(NSString *)imageUrl extra:(NSString *)extra  callbackId:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }

    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![title isKindOfClass:[NSString class]] ||
        ![content isKindOfClass:[NSString class]] ||
        ![imageUrl isKindOfClass:[NSString class]] ||
        ![extra isKindOfClass:[NSString class]]
        ) {
        
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        return;
    }
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    
    if (nil == extra) {
        extra = @"";
    }
    RCRichContentMessage  * rcRichMessage = [RCRichContentMessage messageWithTitle:title
                                                                            digest:content
                                                                          imageURL:imageUrl
                                                                             extra:extra];
    
    [self _sendMessage:_conversationType withTargetId:targetId withContent:rcRichMessage withPushContent:nil withCallBackId:callbackId];

}
-(void)sendCommandNotificationMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId name:(NSString *)name data:(NSString *)data callbackId:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);

    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }
        
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![name isKindOfClass:[NSString class]] ||
        ![data isKindOfClass:[NSString class]]
        ) {
        
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        return;
    }
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    RCCommandNotificationMessage *msg    = [RCCommandNotificationMessage notificationWithName:name data:data];
    [self _sendMessage:_conversationType withTargetId:targetId withContent:msg withPushContent:nil withCallBackId:callbackId];
}

-(void)sendCommandMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId name:(NSString *)name data:(NSString *)data callbackId:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }
    
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![name isKindOfClass:[NSString class]] ||
        ![data isKindOfClass:[NSString class]]
        ) {
        
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        return;
    }
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    RCCommandMessage *msg    = [RCCommandMessage messageWithName:name data:data];
    [self _sendMessage:_conversationType withTargetId:targetId withContent:msg withPushContent:nil withCallBackId:callbackId];
}

- (void)setOnReceiveMessageListener:(id)receiveMessageCbId
{
    NSLog(@"%s", __FUNCTION__);
    self.receiveMessageCbId = receiveMessageCbId;
    [[RCIMClient sharedRCIMClient]setReceiveMessageDelegate:self object:nil];
}

- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object
{
    NSLog(@"%s, isMainThread > %d", __FUNCTION__, [NSThread isMainThread]);
    
    if (self.receiveMessageCbId) {
        NSDictionary *_message = [RongCloudModel RCGenerateMessageModel:message];
        NSDictionary *_result = @{@"result": @{@"message":_message, @"left":@(nLeft)}};
        
        [self.commandDelegate sendResult:_result error:nil withCallbackId:self.receiveMessageCbId doDelete:NO];
    }
    
    /**
     *  Add Local Notification Event
     */
    if (!self.disableLocalNotification) {
        NSNumber *nAppbackgroundMode = [[NSUserDefaults standardUserDefaults]objectForKey:kAppBackgroundMode];
        BOOL _bAppBackgroundMode = [nAppbackgroundMode boolValue];
        if (YES == _bAppBackgroundMode && 0 == nLeft) {
            //post local notification
            [[RCIMClient sharedRCIMClient]getConversationNotificationStatus:message.conversationType targetId:message.targetId success:^(RCConversationNotificationStatus nStatus) {
                if (NOTIFY == nStatus) {
                    NSString *_notificationMessae = @"您收到了一条新消息";
                    
                    [RongCloudModel postLocalNotification:_notificationMessae];
                    
                }
            } error:^(RCErrorCode status) {
                NSLog(@"notification error code= %d",(int)status);
            }];
        }
    }
}

/**
 * conversation
 */
- (void)getConversationList:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }

    NSArray *typeList                       = [[NSArray alloc]initWithObjects:[NSNumber numberWithInt:ConversationType_PRIVATE],
                                               [NSNumber numberWithInt:ConversationType_DISCUSSION],
                                               [NSNumber numberWithInt:ConversationType_GROUP],
                                               [NSNumber numberWithInt:ConversationType_SYSTEM],nil];
    
    NSArray *_conversationList              = [[RCIMClient sharedRCIMClient]getConversationList:typeList];
    
    NSMutableArray * _conversationListModel = nil;
    _conversationListModel                  = [RongCloudModel RCGenerateConversationListModel:_conversationList];
    
    NSDictionary *_result                   = @{@"status":SUCCESS, @"result": _conversationListModel};
    [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
}

- (void)getConversation:(NSString *)conversationTypeString targetId:(NSString *)targetId callbackId:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);

    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }

    
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]]
        ) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err    = @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        return;
    }
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    RCConversation *_rcConversion        = [[RCIMClient sharedRCIMClient]getConversation:_conversationType targetId:targetId];
    NSDictionary *_ret                   = nil;
    _ret                                 = [RongCloudModel RCGenerateConversationModel:_rcConversion];
    
    if (!_ret) {
        _ret = [NSDictionary new];
    }
    NSDictionary *_result = @{@"status":SUCCESS, @"result": _ret};
    [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
}

- (void)removeConversation:(NSString *)conversationTypeString targetId:(NSString *)targetId callbackId:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }
        
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]]
        ) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err    = @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        return;
    }
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    
    BOOL isRemoved = [[RCIMClient sharedRCIMClient] removeConversation:_conversationType targetId:targetId];
    if(isRemoved)
    {
        NSDictionary *_result = @{@"status":SUCCESS};
        [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
    }else{
        NSDictionary *_result = @{@"status":ERROR};
        [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
    }
}

- (void)clearConversations:(NSArray *)conversationTypes callbackId:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }

    if (![conversationTypes isKindOfClass:[NSArray class]]) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        return;
    }
    
    if (nil != conversationTypes && [conversationTypes count] > 0) {
        
        NSUInteger _count      = [conversationTypes count];
        NSMutableArray *argums = [[NSMutableArray alloc] init];
        for (NSUInteger i=0; i< _count; i++) {
            RCConversationType _type = [RongCloudModel RCTransferConversationType:[conversationTypes objectAtIndex:i]];
            [argums addObject:@(_type)];
        }
        
        BOOL __ret =[[RCIMClient sharedRCIMClient]clearConversations:argums];
        
        if(__ret)
        {
            NSDictionary *_result = @{@"status":SUCCESS};
            [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
        }else{
            NSDictionary *_result = @{@"status":ERROR};
            [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
        }
    }
}

- (void)setConversationToTop:(NSString *)conversationTypeString targetId:(NSString *)targetId isTop:(NSNumber *)isTop callbackId:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);

    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }
    
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![isTop isKindOfClass:[NSNumber class]]
        ) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        return;
    }
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    BOOL isSetted = [[RCIMClient sharedRCIMClient] setConversationToTop:_conversationType targetId:targetId isTop:[isTop boolValue]];
    if(isSetted)
    {
        NSDictionary *_result = @{@"status":SUCCESS};
        [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
    }else{
        NSDictionary *_result = @{@"status":ERROR};
        [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
    }
}

/**
 * conversation notification
 */
- (void)getConversationNotificationStatus:(NSString *)conversationTypeString targetId:(NSString *)targetId callbackId:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }

    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]]
        ) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err    = @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        return;
    }
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    
    __weak __typeof(&*self) blockSelf = self;
    [[RCIMClient sharedRCIMClient]getConversationNotificationStatus:_conversationType targetId:targetId success:^(RCConversationNotificationStatus nStatus) {
        NSDictionary *_result = @{@"status":SUCCESS, @"result":@{@"code": @(nStatus), @"notificationStatus": nStatus?@"NOTIFY":@"DO_NOT_DISTURB"}};
        
        [blockSelf.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
    } error:^(RCErrorCode status) {
        NSLog(@"notification error code= %d",(int)status);
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err = @{@"code": @(status), @"msg": @""};
        
        [blockSelf.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
    }];
}
- (void)setConversationNotificationStatus:(NSString *)conversationTypeString targetId:(NSString *)targetId conversationnotificationStatus:(NSString *)conversationnotificationStatus callbackId:(id)callbackId

{
    NSLog(@"%s", __FUNCTION__);

    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }

    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![conversationnotificationStatus isKindOfClass:[NSString class]]
        ) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        return;
    }
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    BOOL _isBlocked = NO;
    if ([conversationnotificationStatus isEqualToString:@"DO_NOT_DISTURB"]) {
        _isBlocked = YES;
    }
    __weak __typeof(&*self) blockSelf = self;
    [[RCIMClient sharedRCIMClient]setConversationNotificationStatus:_conversationType targetId:targetId isBlocked:_isBlocked success:^(RCConversationNotificationStatus nStatus) {
        
        NSDictionary *_result = @{@"status":SUCCESS, @"result":@{@"code": @(nStatus), @"notificationStatus": nStatus?@"NOTIFY":@"DO_NOT_DISTURB"}};
        
        [blockSelf.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
        
    } error:^(RCErrorCode status) {
        NSDictionary *_result   =   @{@"status":ERROR};
        NSDictionary *_err      =   @{@"code": @(status), @"status": @""};
        
        [blockSelf.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
    }];
}

/**
 * read message & delete
 */
- (void)getLatestMessages:(NSString *)conversationTypeString targetId:(NSString *)targetId count:(NSNumber *)count callbackId:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);

    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }

    
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![count isKindOfClass:[NSNumber class]]
        ) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        return;
    }
    RCConversationType _conversationType     = [RongCloudModel RCTransferConversationType:conversationTypeString];
    NSArray *_latestMessages                 = [[RCIMClient sharedRCIMClient]getLatestMessages:_conversationType targetId:targetId count:[count intValue]];
    NSMutableArray * _latestMessageListModel = nil;
    
    _latestMessageListModel                  = [RongCloudModel RCGenerateMessageListModel:_latestMessages];
    
    NSDictionary *_result = @{@"status":SUCCESS, @"result": _latestMessageListModel};
    [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
}

- (void)getHistoryMessages:(NSString *)conversationTypeString targetId:(NSString *)targetId count:(NSNumber *)count oldestMessageId:(NSNumber *)oldestMessageId callbackId:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);

    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }
        
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![count isKindOfClass:[NSNumber class]] ||
        ![oldestMessageId isKindOfClass:[NSNumber class]]
        ) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        return;
    }
    RCConversationType _conversationType      = [RongCloudModel RCTransferConversationType:conversationTypeString];
    NSArray *_historyMessages                 = [[RCIMClient sharedRCIMClient] getHistoryMessages:_conversationType targetId:targetId oldestMessageId:[oldestMessageId longValue] count:[count intValue]];
    NSMutableArray * _historyMessageListModel = nil;
    
    _historyMessageListModel                  = [RongCloudModel RCGenerateMessageListModel:_historyMessages];
    
    NSDictionary *_result = @{@"status":SUCCESS, @"result": _historyMessageListModel};
    [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
}
- (void)getHistoryMessagesByObjectName:(NSString *)conversationTypeString targetId:(NSString *)targetId count:(NSNumber *)count oldestMessageId:(NSNumber *)oldestMessageId objectName:(NSString *)objectName callbackId:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);

    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }
        
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![count isKindOfClass:[NSNumber class]] ||
        ![oldestMessageId isKindOfClass:[NSNumber class]] ||
        ![objectName isKindOfClass:[NSString class]]
        ) {
        
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        return;
    }
    
    RCConversationType _conversationType      = [RongCloudModel RCTransferConversationType:conversationTypeString];
    
    NSArray *_historyMessages = [[RCIMClient sharedRCIMClient] getHistoryMessages:_conversationType targetId:targetId objectName:objectName oldestMessageId:[oldestMessageId longValue] count:[count intValue]];
    NSMutableArray * _historyMessageListModel = nil;
    
    _historyMessageListModel = [RongCloudModel RCGenerateMessageListModel:_historyMessages];
    
    NSDictionary *_result = @{@"status":SUCCESS, @"result": _historyMessageListModel};
    [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
}
- (void) deleteMessages:(NSArray *)messageIds callbackId:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);

    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }
    
    if (![messageIds isKindOfClass:[NSArray class]]
        ) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        return;
    }
    BOOL isDeleted = [[RCIMClient sharedRCIMClient]deleteMessages:messageIds];
    if(isDeleted)
    {
        NSDictionary *_result = @{@"status":SUCCESS};
        [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
    }else{
        NSDictionary *_result = @{@"status":ERROR};
        [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
    }
}
- (void) clearMessages:(NSString *)conversationTypeString targetId:(NSString *)targetId callbackId:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);

    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }
        
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]]
        ) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        return;
    }
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    BOOL isCleared = [[RCIMClient sharedRCIMClient]clearMessages:_conversationType targetId:targetId];
    if(isCleared)
    {
        NSDictionary *_result = @{@"status":SUCCESS};
        [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
    }else{
        NSDictionary *_result = @{@"status":ERROR};
        [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
    }
}

/**
 * unread message count
 */
- (void) getTotalUnreadCount:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);

    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }

    int totalUnReadCount = (int)[[RCIMClient sharedRCIMClient]getTotalUnreadCount];
    
    NSDictionary *_result = @{@"status":SUCCESS, @"result": @(totalUnReadCount)};
    [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
}

- (void) getUnreadCount:(NSString *)conversationTypeString targetId:(NSString *)targetId callbackId:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }
        
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]]
        ) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        return;
    }
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    NSInteger unReadCount = [[RCIMClient sharedRCIMClient]getUnreadCount:_conversationType targetId:targetId];
    NSDictionary *_result = @{@"status":SUCCESS, @"result": @(unReadCount)};
    [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
}
-(void)getUnreadCountByConversationTypes:(NSArray *)conversationTypes callbackId:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }

    if (![conversationTypes isKindOfClass:[NSArray class]]
        ) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        return;
    }
    
    NSMutableArray * _conversationTypes = [NSMutableArray new];
    for(int i=0; i< [conversationTypes count]; i++)
    {
        RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypes[i]];
        [_conversationTypes addObject:@(_conversationType)];
    }
    
    NSInteger _unread_count = [[RCIMClient sharedRCIMClient]getUnreadCount:_conversationTypes];
    
    
    NSDictionary *_result = @{@"status":SUCCESS, @"result": @(_unread_count)};
    [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
}

-(void)setMessageReceivedStatus:(NSNumber *)messageId
             withReceivedStatus:(NSString *)receivedStatus
                 withCallBackId:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }
    
    if (![messageId isKindOfClass:[NSNumber class]] ||
        ![receivedStatus isKindOfClass:[NSString class]]) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
        return;
    }
    
    BOOL __ret = [[RCIMClient sharedRCIMClient]setMessageReceivedStatus:messageId.intValue
                                                         receivedStatus:[RongCloudModel RCTransferReceivedStatusFromString:receivedStatus]];
    if(__ret)
    {
        NSDictionary *_result = @{@"status":SUCCESS};
        [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
    }else{
        NSDictionary *_result = @{@"status":ERROR};
        [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
    }
}

- (void) clearMessagesUnreadStatus: (NSString*)conversationTypeString
                      withTargetId:(NSString *)targetId
                    withCallBackId:(id)cbId

{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:cbId doDelete:YES]) {
        return;
    }
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]]
        ) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
        return;
    }
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    BOOL __ret = [[RCIMClient sharedRCIMClient]clearMessagesUnreadStatus:_conversationType targetId:targetId];
    if(__ret)
    {
        NSDictionary *_result = @{@"status":SUCCESS};
        [self.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
    }else{
        NSDictionary *_result = @{@"status":ERROR};
        [self.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
    }
    
}
-(void) setMessageExtra : (NSNumber *)messageId
               withValue:(NSString *)value
          withCallBackId:(id)cbId
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:cbId doDelete:YES]) {
        return;
    }
    if (![messageId isKindOfClass:[NSNumber class]] ||
        ![value isKindOfClass:[NSString class]]
        ) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
        return;
    }
    
    BOOL __ret = [[RCIMClient sharedRCIMClient]setMessageExtra:messageId.longValue value:value];
    if(__ret)
    {
        NSDictionary *_result = @{@"status":SUCCESS};
        [self.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
    }else{
        NSDictionary *_result = @{@"status":ERROR};
        [self.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
    }
}

/**
 * message draft
 */
-(void) getTextMessageDraft :(NSString*)conversationTypeString
                withTargetId:(NSString *)targetId
              withCallBackId:(id)cbId
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:cbId doDelete:YES]) {
        return;
    }
   
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]]
        ) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
        return;
    }
    RCConversationType conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    NSString *__draft = [[RCIMClient sharedRCIMClient]getTextMessageDraft:conversationType targetId:targetId];
    if (nil == __draft) {
        __draft = @"";
    }
    NSDictionary *_result = @{@"status":SUCCESS, @"result": __draft};
    [self.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];

    
}
-(void) saveTextMessageDraft:(NSString *)conversationTypeString
                withTargetId:(NSString *)targetId
                 withContent:(NSString *)content
              withCallBackId:(id)cbId
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:cbId doDelete:YES]) {
        return;
    }
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![content isKindOfClass:[NSString class]]
        ) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
        return;
    }
    RCConversationType conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    BOOL __ret = [[RCIMClient sharedRCIMClient] saveTextMessageDraft:conversationType
                                                            targetId:targetId
                                                             content:content];
    if(__ret)
    {
        NSDictionary *_result = @{@"status":SUCCESS};
        [self.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
    }else{
        NSDictionary *_result = @{@"status":ERROR};
        [self.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
    }
}
-(void)clearTextMessageDraft:(NSString *)conversationTypeString
                withTargetId:(NSString *)targetId
              withCallBackId:(id)cbId
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:cbId doDelete:YES]) {
        return;
    }
    
        if (![conversationTypeString isKindOfClass:[NSString class]] ||
            ![targetId isKindOfClass:[NSString class]]
            ) {
            NSDictionary *_result = @{@"status":ERROR};
            NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
            [self.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
            return;
        }
        RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
        BOOL __ret = [[RCIMClient sharedRCIMClient] clearTextMessageDraft:_conversationType targetId:targetId];
        if(__ret)
        {
            NSDictionary *_result = @{@"status":SUCCESS};
            [self.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
        }else{
            NSDictionary *_result = @{@"status":ERROR};
            [self.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
        }
}

/**
 * discussion
 */
- (void) createDiscussion:(NSString *)name
           withUserIdList:(NSArray *)userIdList
           withCallBackId:(id)cbId
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:cbId doDelete:YES]) {
        return;
    }
    if (![name isKindOfClass:[NSString class]] ||
        ![userIdList isKindOfClass:[NSArray class]]
        ) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
        return;
    }
    
    __weak __typeof(self)blockSelf = self;
    
    [[RCIMClient sharedRCIMClient]createDiscussion:name userIdList:userIdList success:^(RCDiscussion *discussion) {
        NSDictionary *_result = @{@"status":SUCCESS, @"result": @{@"discussionId": discussion.discussionId}};
         [blockSelf.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
    } error:^(RCErrorCode status) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(status), @"msg": @""};
         [blockSelf.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
    }];
        
    
}

-(void)getDiscussion:(NSString *)discussionId
      withCallBackId:(id)cbId
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:cbId doDelete:YES]) {
        return;
    }
    if (![discussionId isKindOfClass:[NSString class]]
        ) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
        return;
    }
    __weak __typeof(self)blockSelf = self;
    [[RCIMClient sharedRCIMClient]getDiscussion:discussionId success:^(RCDiscussion *discussion) {
        NSDictionary *_dic = [RongCloudModel RCGenerateDiscussionModel:discussion];
        NSDictionary *_result = @{@"status":SUCCESS, @"result": _dic};
        [blockSelf.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
    } error:^(RCErrorCode status) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(status), @"msg": @""};
        [blockSelf.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
    }];
}

-(void)setDiscussionName:(NSString *)discussionId
                withName:(NSString *)name
          withCallBackId:(id)cbId
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:cbId doDelete:YES]) {
        return;
    }
    if (cbId) {
        if (![discussionId isKindOfClass:[NSString class]] ||
            ![name isKindOfClass:[NSString class]]
            ) {
            NSDictionary *_result = @{@"status":ERROR};
            NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
            [self.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
            return;
        }
        
        __weak __typeof(self)blockSelf = self;
        
        [[RCIMClient sharedRCIMClient]setDiscussionName:discussionId name:name success:^{
            NSDictionary *_result = @{@"status":SUCCESS};
            [blockSelf.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
        } error:^(RCErrorCode status) {
            NSDictionary *_result = @{@"status":ERROR};
            [blockSelf.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
        }];
    }
}

- (void) addMemberToDiscussion:(NSString *)discussionId
                withUserIdList:(NSArray *)userIdList
                withCallBackId:(id)cbId
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:cbId doDelete:YES]) {
        return;
    }
    if (![discussionId isKindOfClass:[NSString class]] ||
        ![userIdList isKindOfClass:[NSArray class]]
        ) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
        return;
    }
    __weak __typeof(self)blockSelf = self;
    [[RCIMClient sharedRCIMClient] addMemberToDiscussion:discussionId userIdList:userIdList success:^(RCDiscussion *discussion){
        NSDictionary *_result = @{@"status":SUCCESS};
        [blockSelf.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
    } error:^(RCErrorCode status) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(status), @"msg": @""};
        [blockSelf.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
    }];
}
- (void) removeMemberFromDiscussion:(NSString *)discussionId
                        withUserIds:(NSString *)userIds
                     withCallBackId:(id)cbId
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:cbId doDelete:YES]) {
        return;
    }
    if (![discussionId isKindOfClass:[NSString class]] ||
        ![userIds isKindOfClass:[NSString class]]
        ) {
        
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
        return;
    }
    
    __weak __typeof(self)blockSelf = self;
    [[RCIMClient sharedRCIMClient] removeMemberFromDiscussion:discussionId userId:userIds success:^(RCDiscussion *discussion) {
        
        NSDictionary *_result = @{@"status":SUCCESS};
        [blockSelf.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
        
    } error:^(RCErrorCode status) {
        
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(status), @"msg": @""};
        [blockSelf.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
        
    }];
}
- (void) quitDiscussion:(NSString *)discussionId
         withCallBackId:(id)cbId
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:cbId doDelete:YES]) {
        return;
    }
    if (![discussionId isKindOfClass:[NSString class]]
        ) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
        return;
    }
    __weak __typeof(self)blockSelf = self;
    [[RCIMClient sharedRCIMClient] quitDiscussion:discussionId success:^(RCDiscussion *discussion) {
        NSDictionary *_result = @{@"status":SUCCESS};
        [blockSelf.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
    } error:^(RCErrorCode status) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(status), @"msg": @""};
        [blockSelf.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];

    }];
}
- (void) setDiscussionInviteStatus:(NSString *)discussionId
                  withInviteStatus:(NSString *)inviteStatus
                    withCallBackId:(id)cbId
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:cbId doDelete:YES]) {
        return;
    }
    
    if (![inviteStatus isKindOfClass:[NSString class]] ||
        ![discussionId isKindOfClass:[NSString class]]
        ) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
        return;
    }
    
    BOOL _isOpen = YES;
    
    if ([inviteStatus isEqualToString:@"CLOSED"]) {
        _isOpen = NO;
    }
    __weak __typeof(self)blockSelf = self;
    
    [[RCIMClient sharedRCIMClient]setDiscussionInviteStatus:discussionId isOpen:_isOpen success:^{
        NSDictionary *_result = @{@"status":SUCCESS};
        [blockSelf.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
    } error:^(RCErrorCode status) {
        
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(status), @"msg": @""};
        [blockSelf.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
    }];
}

/**
 * group
 */
- (void) syncGroup:(NSArray *)groups
    withCallBackId:(id)cbId
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:cbId doDelete:YES]) {
        return;
    }
     if (![groups isKindOfClass:[NSArray class]]
        ) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
        return;
    }
    
    NSMutableArray *_groupList = [RongCloudModel RCGenerateGroupList:groups];
    
    if (nil == _groupList) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
        return;
    }
    
    __weak __typeof(self)blockSelf = self;
    [[RCIMClient sharedRCIMClient]syncGroups:_groupList success:^{
        
        NSDictionary *_result = @{@"status":SUCCESS};
        [blockSelf.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
        
    } error:^(RCErrorCode status) {
        
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(status), @"msg": @""};
        [blockSelf.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
        
    }];
}
- (void) joinGroup:(NSString *)groupId
     withGroupName:(NSString *)groupName
    withCallBackId:(id)cbId
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:cbId doDelete:YES]) {
        return;
    }
    if (![groupId isKindOfClass:[NSString class]] ||
        ![groupName isKindOfClass:[NSString class]]
        ) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
        return;
    }
    
    __weak __typeof(self)blockSelf = self;
    [[RCIMClient sharedRCIMClient]joinGroup:groupId groupName:groupName success:^{
        
        NSDictionary *_result = @{@"status":SUCCESS};
        [blockSelf.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
        
    } error:^(RCErrorCode status) {
        
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(status), @"msg": @""};
        [blockSelf.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
    }];
}

- (void) quitGroup:(NSString *)groupId
    withCallBackId:(id)cbId
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:cbId doDelete:YES]) {
        return;
    }
    
    if (![groupId isKindOfClass:[NSString class]]) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
        return;
    }
    
    __weak __typeof(self)blockSelf = self;
    [[RCIMClient sharedRCIMClient]quitGroup:groupId success:^{
        
        NSDictionary *_result = @{@"status":SUCCESS};
        [blockSelf.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
        
    } error:^(RCErrorCode status) {
        
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(status), @"msg": @""};
        [blockSelf.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
    }];
}

/**
 * chatRoom
 */
- (void)joinChatRoom:(NSString *)chatRoomId
        messageCount:(NSNumber *)defMessageCount
      withCallBackId:(id)cbId
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:cbId doDelete:YES]) {
        return;
    }
    
    if (![chatRoomId isKindOfClass:[NSString class]] ||
        ![defMessageCount isKindOfClass:[NSNumber class]]) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
        return;
    }
    
    __weak __typeof(self)blockSelf = self;
    [[RCIMClient sharedRCIMClient]joinChatRoom:chatRoomId messageCount:[defMessageCount intValue] success:^{
        NSDictionary *_result = @{@"status":SUCCESS};
        
        [blockSelf.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
    } error:^(RCErrorCode status) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(status), @"msg": @""};
        
        [blockSelf.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
    }];
}

- (void)quitChatRoom:(NSString *)chatRoomId
      withCallBackId:(id)cbId
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:cbId doDelete:YES]) {
        return;
    }
    
    if (![chatRoomId isKindOfClass:[NSString class]]
        ) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
        return;
    }
    
    __weak __typeof(self)blockSelf = self;
    [[RCIMClient sharedRCIMClient]quitChatRoom:chatRoomId success:^{
        NSDictionary *_result = @{@"status":SUCCESS};
        
        [blockSelf.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
    } error:^(RCErrorCode status) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(status), @"msg": @""};
        
        [blockSelf.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
    }];
}

- (void)getConnectionStatus:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }
    
    RCConnectionStatus status = [[RCIMClient sharedRCIMClient] getConnectionStatus];
    NSDictionary *_result = @{@"status":SUCCESS, @"result": @{@"connectionStatus":[RongCloudModel RCTransferConnectionStatus:status]}};
    
    [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
}

- (void)logout:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }
    
    [[RCIMClient sharedRCIMClient]disconnect:NO];
    isConnected = NO;
    NSDictionary *_result = @{@"status": SUCCESS};
    
    [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
}

- (void)getRemoteHistoryMessages:(NSString *)conversationTypeString
                        targetId:(NSString *)targetId
                      recordTime:(NSNumber *)dateTime
                           count:(NSNumber *)count
                  withCallBackId:(id)cbId
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:cbId doDelete:YES]) {
        return;
    }

    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![dateTime isKindOfClass:[NSNumber class]] ||
        ![count isKindOfClass:[NSNumber class]]) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err    = @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
        return;
    }
    
    __weak __typeof(self)blockSelf = self;
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    NSDate *cur = [[NSDate alloc] init];
    cur = [cur dateByAddingTimeInterval:-30 *24*60 *60];
    [[RCIMClient sharedRCIMClient] getRemoteHistoryMessages:_conversationType targetId:targetId recordTime:0 count:[count intValue] success:^(NSArray *messages) {
        
        NSMutableArray * _historyMessageListModel = nil;
        _historyMessageListModel = [RongCloudModel RCGenerateMessageListModel:messages];
        
        NSDictionary *_result = @{@"status":SUCCESS, @"result": _historyMessageListModel};
        [blockSelf.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
    } error:^(RCErrorCode status) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err    = @{@"code":@(status)};
        [blockSelf.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];

    }];
}

- (void)setMessageSentStatus:(NSNumber *)messageId
                  sentStatus:(NSString *)statusString
              withCallBackId:(id)cbId
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:cbId doDelete:YES]) {
        return;
    }
    
    if (![statusString isKindOfClass:[NSString class]] ||
        ![messageId isKindOfClass:[NSNumber class]]) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err    = @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
        return;
    }
    
    RCSentStatus status = [RongCloudModel RCTransferSendStatusFromString:statusString];
    BOOL isSuccess = [[RCIMClient sharedRCIMClient] setMessageSentStatus:[messageId longValue] sentStatus:status];
    if (isSuccess) {
        NSDictionary *_result = @{@"status":SUCCESS};
        
        [self.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
    } else {
        NSDictionary *_result = @{@"status": ERROR};
        NSDictionary *_err    = @{@"code":@(UNKNOWN_CODE), @"msg": UNKNOWN_MSG};
        
        [self.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
    }
}

- (void)getCurrentUserId:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }
    
    NSDictionary *_result = @{@"status":SUCCESS, @"result": [RCIMClient sharedRCIMClient].currentUserInfo.userId};
    
    [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
}

- (void)addToBlacklist:(NSString *)userId
        withCallBackId:(id)cbId
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:cbId doDelete:YES]) {
        return;
    }
    
    if (![userId isKindOfClass:[NSString class]]) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err    = @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
        return;
    }
    
    __weak __typeof(self)blockSelf = self;
    [[RCIMClient sharedRCIMClient] addToBlacklist:userId success:^{
        NSDictionary *_result = @{@"status":SUCCESS};
        
        [blockSelf.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
    } error:^(RCErrorCode status) {
        NSDictionary *_result = @{@"status": ERROR};
        NSDictionary *_err    = @{@"code":@(status)};
        
        [blockSelf.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
    }];
}

- (void)removeFromBlacklist:(NSString *)userId
             withCallBackId:(id)cbId
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:cbId doDelete:YES]) {
        return;
    }
    
    if (![userId isKindOfClass:[NSString class]]) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err    = @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
        return;
    }
    
    __weak __typeof(self)blockSelf = self;
    [[RCIMClient sharedRCIMClient] removeFromBlacklist:userId success:^{
        NSDictionary *_result = @{@"status":SUCCESS};
        
        [blockSelf.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
    } error:^(RCErrorCode status) {
        NSDictionary *_result = @{@"status": ERROR};
        NSDictionary *_err    = @{@"code":@(status)};
        
        [blockSelf.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
    }];
}

- (void)getBlacklistStatus:(NSString *)userId
            withCallBackId:(id)cbId
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:cbId doDelete:YES]) {
        return;
    }
    
    if (![userId isKindOfClass:[NSString class]]) {
        NSDictionary *_result = @{@"status":ERROR};
        NSDictionary *_err =  @{@"code":@(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
        return;
    }
    
    __weak __typeof(self)blockSelf = self;
    [[RCIMClient sharedRCIMClient] getBlacklistStatus:userId success:^(int bizStatus) {
        NSDictionary *_result = @{@"status":SUCCESS, @"result": (bizStatus? @(1) : @(0))};
        
        [blockSelf.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
    } error:^(RCErrorCode status) {
        NSDictionary *_result = @{@"status": ERROR};
        NSDictionary *_err    = @{@"code":@(status)};
        
        [blockSelf.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
    }];
}

- (void)getBlacklist:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }
    
    [[RCIMClient sharedRCIMClient] getBlacklist:^(NSArray *blockUserIds) {
        NSDictionary *_result = @{@"status":SUCCESS, @"result": blockUserIds ? blockUserIds : @[]};
        
        [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
    } error:^(RCErrorCode status) {
        NSDictionary *_result = @{@"status": ERROR};
        NSDictionary *_err    = @{@"code":@(status)};
        
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
    }];
}

- (void)setNotificationQuietHours:(NSString *)startTime
                         spanMins:(NSNumber *)spanMinutes
                   withCallBackId:(id)cbId
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:cbId doDelete:YES]) {
        return;
    }
    
    if (![startTime isKindOfClass:[NSString class]]
        || ![spanMinutes isKindOfClass:[NSNumber class]]) {
        NSDictionary *_result = @{@"status": ERROR};
        NSDictionary *_err =  @{@"code": @(BAD_PARAMETER_CODE), @"msg": BAD_PARAMETER_MSG};
        [self.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
        return;
    }
    
    __weak __typeof(self)blockSelf = self;
    [[RCIMClient sharedRCIMClient] setConversationNotificationQuietHours:startTime spanMins:[spanMinutes intValue] success:^{
        NSDictionary *_result = @{@"status":SUCCESS};
        
        [blockSelf.commandDelegate sendResult:_result error:nil withCallbackId:cbId doDelete:YES];
    } error:^(RCErrorCode status) {
        NSDictionary *_result = @{@"status": ERROR};
        NSDictionary *_err    = @{@"code": @(status)};
        
        [blockSelf.commandDelegate sendResult:_result error:_err withCallbackId:cbId doDelete:YES];
    }];
}

- (void)removeNotificationQuietHours:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }
    
    [[RCIMClient sharedRCIMClient] removeConversationNotificationQuietHours:^{
        NSDictionary *_result = @{@"status": SUCCESS};
        
        [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
    } error:^(RCErrorCode status) {
        NSDictionary *_result = @{@"status": ERROR};
        NSDictionary *_err    = @{@"code": @(status)};
        
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
    }];
}

- (void)getNotificationQuietHours:(id)callbackId
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:callbackId doDelete:YES]) {
        return;
    }
    
    [[RCIMClient sharedRCIMClient] getNotificationQuietHours:^(NSString *startTime, int spansMin) {
        NSDictionary *_result = @{@"status": SUCCESS, @"result": @{@"startTime": startTime, @"spanMinutes": @(spansMin)}};
        
        [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
    } error:^(RCErrorCode status) {
        NSDictionary *_result = @{@"status": ERROR};
        NSDictionary *_err    = @{@"code": @(status)};
        
        [self.commandDelegate sendResult:_result error:_err withCallbackId:callbackId doDelete:YES];
    }];
}
- (void)disableLocalNotification:(id)callbackId {
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInit:callbackId doDelete:YES]) {
        return;
    }
    
    self.disableLocalNotification = YES;

    
    NSDictionary *_result = @{@"status": SUCCESS};
    [self.commandDelegate sendResult:_result error:nil withCallbackId:callbackId doDelete:YES];
}

#ifdef RC_SUPPORT_IMKIT
- (void)startSingleCall:(NSString *)calleeId mediaType:(int)mediaType withCallBackId:(id)cbId {
    [[RCCall sharedRCCall] startSingleCall:calleeId mediaType:(RCCallMediaType)mediaType];
}
#endif
@end
