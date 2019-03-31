//
//  YJViewController.m
//  ReactiveCocoaUse
//
//  Created by 于英杰 on 2019/3/31.
//  Copyright © 2019 YYJ. All rights reserved.
//

#import "YJViewController.h"
#import "YJLoginViewModel.h"
#import <MBProgressHUD.h>
@interface YJViewController ()
@property (weak, nonatomic) IBOutlet UIButton *LoginBtn;
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passWordTextfield;

@property(nonatomic,strong)YJLoginViewModel*LoginViewmodel;
@end

@implementation YJViewController

-(YJLoginViewModel*)LoginViewmodel{

    if(_LoginViewmodel==nil){
    
        _LoginViewmodel = [[YJLoginViewModel alloc]init];
    }

    return _LoginViewmodel;

}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    RAC(self.LoginViewmodel.LoginModel,userNum) = _nameTextfield.rac_textSignal;
    RAC(self.LoginViewmodel.LoginModel,userPsw) = _passWordTextfield.rac_textSignal;
    RAC(self.LoginBtn,enabled) = self.LoginViewmodel.enablesing;

    @weakify(self)
    [[self.LoginBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        [self.LoginViewmodel.loginConmand execute:nil];
    } error:^(NSError * _Nullable error) {
        NSLog(@"---%@-",error);
    }];

    [self.LoginViewmodel.loginConmand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        if ([x isEqual:@"登录成功"]) {
            NSLog(@"登录成功");
        }
        else{
            NSLog(@"登录失败");
        }
    }];

    [self.LoginViewmodel.loginConmand.executing subscribeNext:^(NSNumber * _Nullable x) {
        @strongify(self)
        if ([x isEqualToNumber:@1]) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
        else{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
//
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
