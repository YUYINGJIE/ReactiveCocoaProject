//
//  YJLoginViewModel.h
//  ReactiveCocoaUse
//
//  Created by 于英杰 on 2019/3/31.
//  Copyright © 2019 YYJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YJLoginModel.h"
#import <ReactiveObjC.h>
@interface YJLoginViewModel : NSObject
@property(nonatomic,strong)YJLoginModel*LoginModel;
@property(nonatomic,strong,readonly)RACSignal*enablesing;
@property(nonatomic,strong,readonly)RACCommand*loginConmand;

@end
