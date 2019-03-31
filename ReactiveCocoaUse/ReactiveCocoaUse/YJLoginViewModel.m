//
//  YJLoginViewModel.m
//  ReactiveCocoaUse
//
//  Created by 于英杰 on 2019/3/31.
//  Copyright © 2019 YYJ. All rights reserved.
//

#import "YJLoginViewModel.h"

@implementation YJLoginViewModel

-(YJLoginModel*)LoginModel{
    
    if (_LoginModel==nil) {
        
        _LoginModel = [[YJLoginModel alloc]init];
    }
    return _LoginModel;
}
-(instancetype)init{
    
    if (self=[super init]) {
        [self initloginconmand];
    }
    return self;
    
}

-(void)initloginconmand{

    _enablesing = [RACSignal combineLatest:@[RACObserve(self.LoginModel, userNum),RACObserve(self.LoginModel, userPsw)] reduce:^id (NSString*name,NSString*PSW){
        return @(name.length && PSW.length);
    }];

    _loginConmand = [[RACCommand alloc]initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [subscriber sendNext:@"登录成功"];
                [subscriber sendCompleted];
            });
            return nil;
        }];
    }];
    
    
}

@end
