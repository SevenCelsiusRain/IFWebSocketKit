//
//  HXSocketManager.h
//  IFWebSocketKit_Example
//
//  Created by MrGLZh on 2022/8/31.
//  Copyright © 2022 张高磊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"
 
typedef enum : NSUInteger {
    IFSocketStatusUnknown,         // 状态未知
    IFSocketStatusConnecting,      // 正在连接
    IFSocketStatusConnected,       // 已连接
    IFSocketStatusFailed,          // 失败
    IFSocketStatusClosedByServer,  // 系统关闭
    IFSocketStatusClosedByUser,    // 用户关闭
    IFSocketStatusReceived,        // 接收消息
} IFSocketStatus;


@protocol IFSocketDelegate <NSObject>

@optional
- (void)socket:(SRWebSocket *)socket receiveMessage:(id)message;

- (void)socket:(SRWebSocket *)socket receiveMessageWithString:(NSString *)string;

- (void)socket:(SRWebSocket *)socket receiveMessageWithData:(NSData *)data;

@end
 
@interface IFSocketManager : NSObject

@property (nonatomic, weak) id<IFSocketDelegate> delegate;
 
/**
 重连时间间隔，默认3秒钟
 */
@property(nonatomic, assign) NSTimeInterval overtime;
 
/**
 重连次数，默认无限次 -- NSUIntegerMax
 */
@property(nonatomic, assign) NSUInteger reconnectCount;
/**
  An array of strings that turn into `Sec-WebSocket-Protocol`. Default: `nil`.
 */
@property (nonatomic, copy) NSArray *protocols;

/**
 心跳时间 默认 10秒
 */
@property(nonatomic, assign) NSTimeInterval heartbeatTime;
 
/**
 当前链接状态
 */
@property(nonatomic, assign) IFSocketStatus status;
/**
 服务器IP
 */
@property (nonatomic, copy) NSString *serverIP;
@property (nonatomic, copy) NSArray <NSString*>*certificates;

 
+ (instancetype)sharedInstance;
 
/**
 开始连接
 */
- (void)connect;
 
/**
 关闭连接
 */
- (void)close;
 
/**
 发送一条消息
 
 @param message 消息体
 */
- (void)sendMessage:(NSString *)message;


/**
 发送一条消息
 
 @param data 消息体
 */
- (void)sendData:(NSData *)data;
 
@end


