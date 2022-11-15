//
//  HXSocketManager.m
//  IFWebSocketKit_Example
//
//  Created by MrGLZh on 2022/8/31.
//  Copyright © 2022 张高磊. All rights reserved.
//

#import "IFSocketManager.h"
#import "AFNetworkReachabilityManager.h"
#import "NSURLRequest+SRWebSocket.h"
 
@interface IFSocketManager ()<SRWebSocketDelegate>
 
@property(nonatomic, strong) SRWebSocket *webSocket;
 
@property(nonatomic, weak) NSTimer *timer;
 
@property(nonatomic, strong) NSTimer *pingTimer;  //每10秒钟发送一次ping消息
 
@property(nonatomic, assign) NSUInteger currentCount;  //当前重连次数
 
@end
 

static NSString *WSUrl = @"wss://app-gateway-dev.ifyou.net/ws/info";
@implementation IFSocketManager
 
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static IFSocketManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
        instance.overtime = 3;
        instance.heartbeatTime = 10;
        instance.reconnectCount = NSUIntegerMax;
        instance.serverIP = WSUrl;
        instance.status = IFSocketStatusUnknown;
    });
    return instance;
}
 
+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}
 
/**
 开始连接
 */
- (void)connect {
    //先关闭
    [self.webSocket close];
    self.webSocket.delegate = nil;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.serverIP]];
    if (self.certificates) {
//        NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"myOwnCertificate" ofType:@"cer"];
//        NSData *certData = [[NSData alloc] initWithContentsOfFile:cerPath];
//        CFDataRef certDataRef = (__bridge CFDataRef)certData;
//        SecCertificateRef certRef = SecCertificateCreateWithData(NULL, certDataRef);
//        id certificate = (__bridge id)certRef;
        
        [request setSR_SSLPinnedCertificates:self.certificates];
    }
    if (self.protocols.count > 0) {
        self.webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.serverIP]] protocols:self.protocols];
    }else {
        self.webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.serverIP]]];
    }
    
    self.webSocket.delegate = self;
    self.status = IFSocketStatusConnecting;
    
    [self.webSocket open];
}
 
/**
 关闭连接
 */
- (void)close {
    [self.webSocket close];
    self.webSocket = nil;
    
    [self.pingTimer invalidate];
    self.pingTimer = nil;
    [self.timer invalidate];
    self.timer = nil;
}
 
/**
 重新连接
 */
- (void)reconnect {
    if (self.currentCount < self.reconnectCount) {
        
        //计数器+1
        self.currentCount ++;
        
        NSLog(@"%lf秒后进行第%zd次重试连接……",self.overtime,self.currentCount);
        
        // 开启定时器
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.overtime target:self selector:@selector(connect) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        self.timer = timer;
    }
    else{
        NSLog(@"重连次数已用完……");
        
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
    }
}
 
/**
 发送一条消息
 @param message 消息体
 */
- (void)sendMessage:(NSString *)message {
    if (self.status != IFSocketStatusConnected) {
        return;
    }
    
    if (message) {
        NSError *error;
        [self.webSocket sendString: message error:&error];
        if (error) {
            NSLog(@"发送消息失败！");
        }else{
            NSLog(@"消息已发送");
        }
    }
}

- (void)sendData:(NSData *)data {
    if (self.status != IFSocketStatusConnected) {
        return;
    }
    if (data) {
        NSError *error;
        [self.webSocket sendData:data error:&error];
        if (error) {
            NSLog(@"发送消息失败！");
        }else{
            NSLog(@"消息已发送");
        }
    }
}


- (void)startHeartbeat {
    // 开启ping定时器
    self.pingTimer = [NSTimer scheduledTimerWithTimeInterval:self.heartbeatTime target:self selector:@selector(sendPingMessage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.pingTimer forMode:NSRunLoopCommonModes];
}
 
/**
 发送ping消息
 */
- (void)sendPingMessage {
    NSError *error;
    [self.webSocket sendPing:[NSData data] error:&error];
    if (error) {
        NSLog(@"发送心跳包失败！");
    }else {
        NSLog(@"发送心跳包");
    }
}
 
#pragma mark - SRWebSocketDelegate
 
/**
 Called when a frame was received from a web socket.
 
 @param webSocket An instance of `SRWebSocket` that received a message.
 @param string    Received text in a form of UTF-8 `String`.
 */
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithString:(NSString *)string {
    if (self.delegate && [self.delegate respondsToSelector:@selector(socket:receiveMessageWithString:)]) {
        [self.delegate socket:webSocket receiveMessageWithString:string];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if (self.delegate && [self.delegate respondsToSelector:@selector(socket:receiveMessage:)]) {
        [self.delegate socket:webSocket receiveMessage:message];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithData:(NSData *)data {
    if (self.delegate && [self.delegate respondsToSelector:@selector(socket:receiveMessageWithData:)]) {
        [self.delegate socket:webSocket receiveMessageWithData:data];
    }
}
 
/**
 Called when a given web socket was open and authenticated.
 
 @param webSocket An instance of `SRWebSocket` that was open.
 */
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    
    NSLog(@"已链接服务器：%@",webSocket.url);
    if (!self.pingTimer) {
        [self startHeartbeat];
    }
    //重置计数器
    self.currentCount = 0;
    
    self.status = IFSocketStatusConnected;
}
 
/**
 Called when a given web socket encountered an error.
 
 @param webSocket An instance of `SRWebSocket` that failed with an error.
 @param error     An instance of `NSError`.
 */
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"链接失败：%@",error.localizedDescription);
    self.status = IFSocketStatusFailed;
    if (error.code == 50 || ![AFNetworkReachabilityManager sharedManager].reachable) {
        // 网络异常不重连
        return;
    }
    
    //尝试重新连接
    [self reconnect];
}
 
/**
 Called when a given web socket was closed.
 
 @param webSocket An instance of `SRWebSocket` that was closed.
 @param code      Code reported by the server.
 @param reason    Reason in a form of a String that was reported by the server or `nil`.
 @param wasClean  Boolean value indicating whether a socket was closed in a clean state.
 */
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(nullable NSString *)reason wasClean:(BOOL)wasClean {
    
    NSLog(@"链接已关闭：code:%zd   reason:%@",code,reason);
    
    if (code == SRStatusCodeNormal) {
        self.status = IFSocketStatusClosedByUser;
    }else {
        self.status = IFSocketStatusClosedByServer;
        //尝试重新连接
        [self reconnect];
    }
}
 
/**
 Called on receive of a ping message from the server.
 
 @param webSocket An instance of `SRWebSocket` that received a ping frame.
 @param data      Payload that was received or `nil` if there was no payload.
 */
- (void)webSocket:(SRWebSocket *)webSocket didReceivePingWithData:(nullable NSData *)data {
    
    NSLog(@"收到 Ping");
}
 
/**
 Called when a pong data was received in response to ping.
 
 @param webSocket An instance of `SRWebSocket` that received a pong frame.
 @param pongData  Payload that was received or `nil` if there was no payload.
 */
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(nullable NSData *)pongData {
    
    NSLog(@"收到 Pong");
}
 
@end


