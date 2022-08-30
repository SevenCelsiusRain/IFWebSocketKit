//
//  IFViewController.m
//  IFWebSocketKit
//
//  Created by 张高磊 on 08/30/2022.
//  Copyright (c) 2022 张高磊. All rights reserved.
//

#import "IFViewController.h"
#import "IFSocketManager.h"
#import "Masonry.h"
#import "Toast.h"

@interface IFViewController ()<IFSocketDelegate>
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) IFSocketManager *manager;

@end

@implementation IFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setupViews];
}


#pragma mark - delegate

- (void)setupViews {
    IFSocketManager *manager = [IFSocketManager sharedInstance];
    manager.delegate = self;
    manager.serverIP = @"wss://ifyouteam-dev.ifyou.net/ws/info";
    [manager connect];
    self.manager = manager;
    
    [self.view addSubview:self.textField];
    [self.view addSubview:self.sendButton];
    [self.view addSubview:self.closeButton];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(200, 50));
    }];
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textField.mas_bottom).offset(40);
        make.size.mas_equalTo(CGSizeMake(100, 50));
        make.centerX.equalTo(self.view);
    }];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sendButton.mas_bottom).offset(30);
        make.size.equalTo(self.sendButton);
        make.left.equalTo(self.sendButton);
    }];
}


#pragma mark - event handler

- (void)sendButtonAction {
    if (self.textField.text.length > 0) {
        [self.manager sendMessage:self.textField.text];
    }
}

- (void)closeButtonAction {
    [self.manager close];
}


#pragma mark - delegate

- (void)socket:(SRWebSocket *)socket receiveMessageWithString:(NSString *)string {
    
    [self.view makeToast:string];
}


#pragma mark - getter

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.clearButtonMode = UITextFieldViewModeAlways;
        _textField.borderStyle = UITextBorderStyleRoundedRect;
    }
    return _textField;
}

- (UIButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(sendButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _sendButton.layer.cornerRadius = 4;
        _sendButton.clipsToBounds = YES;
        _sendButton.backgroundColor = [UIColor colorWithRed:255/255.f green:68/255.f blue:0 alpha:1];
    }
    
    return _sendButton;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setTitle:@"断开连接" forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.layer.cornerRadius = 4;
        _closeButton.clipsToBounds = YES;
        _closeButton.backgroundColor = [UIColor colorWithRed:255/255.f green:68/255.f blue:0 alpha:1];
    }
    return _closeButton;
}

@end
