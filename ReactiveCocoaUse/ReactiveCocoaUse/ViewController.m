//
//  ViewController.m
//  ReactiveCocoaUse
//
//  Created by 于英杰 on 2019/3/31.
//  Copyright © 2019 YYJ. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

/**
 响应式编程  ReactiveCocoa
 简易用法 及说明
 */

    [self RACSignalTest];
    [self RACSubjectTest];



}

/**
 
 RACSignal 基础用法
 
 */

-(void)RACSignalTest{
    
    // 1 创建个信号。这个信号会有发送的内容
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        //发送信号
        [subscriber sendNext:@"sendOneMessage"];
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:1001 userInfo:@{@"errorMsg":@"this is a error message"}];
        [subscriber sendError:error];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"signal已销毁");
        }];
      //  此处  也可直接写为  return nil;
    }];
    
    // 既然信号有发送内容 怎么接收呢
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x); // 输出打印下 看看神马东西
    }];
    [signal subscribeError:^(NSError * _Nullable error) {
        NSLog(@"%@",error); // 输出打印下 看看神马东西
    }];
   // 或者直接
//    [signal subscribeNext:^(id  _Nullable x) {
//        <#code#>
//    } error:^(NSError * _Nullable error) {
//        <#code#>
//    }];
    
    
   // 加上线程的话 直接这样 方式1 这里简单说下 线程方面底部封装的 GCD
//    [signal.deliverOnMainThread subscribeNext:^(id  _Nullable x) {
//        <#code#>
//    } error:^(NSError * _Nullable error) {
//        <#code#>
//    }];
    // 加上线程的话 直接这样 方式2
//    [[signal deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id  _Nullable x) {
//        <#code#>
//    } error:^(NSError * _Nullable error) {
//        <#code#>
//    }];
//
    //------------------------------------------------------------------
// OK进入 稍复杂的 编写

    // 现在 我创建俩个 信号
    
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@0];
        // [subscriber sendCompleted]; //信号发送完成
        return nil;
    }];
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        return nil;
    }];
   // 操作1
    // 把signalA拼接到signalB后，signalA发送完成，signalB才会被激活。
    // 以后只需要面对拼接信号开发。
    // 订阅拼接的信号，不需要单独订阅signalA，signalB
    // 内部会自动订阅。
    // 注意：第一个信号必须发送完成，第二个信号才会被激活
    
    // concat底层实现:
    // 1.当拼接信号被订阅，就会调用拼接信号的didSubscribe
    // 2.didSubscribe中，会先订阅第一个源信号（signalA）
    // 3.会执行第一个源信号（signalA）的didSubscribe
    // 4.第一个源信号（signalA）didSubscribe中发送值，就会调用第一个源信号（signalA）订阅者的nextBlock,通过拼接信号的订阅者把值发送出来.
    // 5.第一个源信号（signalA）didSubscribe中发送完成，就会调用第一个源信号（signalA）订阅者的completedBlock,订阅第二个源信号（signalB）这时候才激活（signalB）。
    // 6.订阅第二个源信号（signalB）,执行第二个源信号（signalB）的didSubscribe
    // 7.第二个源信号（signalA）didSubscribe中发送值,就会通过拼接信号的订阅者把值发送出来.
    RACSignal *concatSignal = [signalA concat:signalB];
    [concatSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"--concatSignal--%@",x);
    }];
    
    // then:用于连接两个信号，当第一个信号完成，才会连接then返回的信号
    // 注意使用then，之前信号的值会被忽略掉.
    // 底层实现：1、先过滤掉之前的信号发出的值。2.使用concat连接then返回的信号
    // then:用于连接两个信号，当第一个信号完成，才会连接then返回的信号
    // 注意使用then，之前信号的值会被忽略掉.
    // 底层实现：1、先过滤掉之前的信号发出的值。2.使用concat连接then返回的信号
    
    [[signalA then:^RACSignal * _Nonnull{
        return signalB;
    }]subscribeNext:^(id  _Nullable x) {
        NSLog(@"---then---%@",x);
    }];
    
    // 合并信号,任何一个信号发送数据，都能监听到.
    RACSignal *mergeSignal = [signalA merge:signalB];
    [mergeSignal subscribeNext:^(id x) {
        NSLog(@"--mergeSignal----%@",x);
    }];
    
    
    //zipWith:把两个信号压缩成一个信号，只有当两个信号同时发出信号内容时，并且把两个信号的内容合并成一个元组RACTwoTuple，才会触发压缩流的next事件。
    // 压缩信号A，信号B
    RACSignal *zipSignal = [signalA zipWith:signalB];
    [zipSignal subscribeNext:^(id x) {
        NSLog(@"---zipSignal---%@",x);
    }];
    
    
    // 聚合
    // 常见的用法，（先组合在聚合）。combineLatest:(id<NSFastEnumeration>)signals reduce:(id (^)())reduceBlock
    // reduce中的block简介:
    // reduceblcok中的参数，有多少信号组合，reduceblcok就有多少参数，每个参数就是之前信号发出的内容
    // reduceblcok的返回值：聚合信号之后的内容。
    [[RACSignal combineLatest:@[signalA,signalB] reduce:^id(NSNumber*a,NSNumber*b){
    return @(a.boolValue && b.boolValue); //此处自行百度 @(a,b) @(a&&b) 等等
    }]subscribeNext:^(id  _Nullable x) {
        NSLog(@"--聚合------%@",x);
    }];
    
    // 再来一个 牛的 （个人很少用这个）
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        return nil;
    }] doNext:^(id x) {
        // 执行[subscriber sendNext:@1];之前会调用这个Block
        NSLog(@"doNext");;
    }] doCompleted:^{
        // 执行[subscriber sendCompleted];之前会调用这个Block
        NSLog(@"doCompleted");
    }]subscribeNext:^(id  _Nullable x) {
        NSLog(@"----%@",x);
    }];
    
    
    //timeout：超时，可以让一个信号在一定的时间后，自动报错。
    RACSignal *signalc = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        return nil;
    }] timeout:1 onScheduler:[RACScheduler currentScheduler]];
    [signalc subscribeNext:^(id x) {
        NSLog(@"%@",x);
    } error:^(NSError *error) {
        // 1秒后会自动调用
        NSLog(@"----timeout--%@",error);
    }];
    
    
    //interval 定时：每隔一段时间发出信号
    
    [[RACSignal interval:1 onScheduler:[RACScheduler currentScheduler]] subscribeNext:^(id x) {
        NSLog(@"---interval---%@",x);
    }];
    
    // delay 延迟发送next。
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        return nil;
    }] delay:2] subscribeNext:^(id x) {
        NSLog(@"---delay----%@",x);
    }];
    
   // 还有比较厉害的一个操作 但不知道 你是否用的上
    //retry重试 ：只要失败，就会重新执行创建信号中的block,直到成功.
    __block int i = 0;
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (i == 10) {
            [subscriber sendNext:@1];
        }else{
            NSLog(@"接收到错误");
            [subscriber sendError:nil];
        }
        i++;
        return nil;
    }] retry] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    } error:^(NSError *error) {
    }];
    
    // 还有一个 replay 的操作 自行查看一下吧
    
    //------------------------------------------------------------------
}



/**
 RACSubject
 */
-(void)RACSubjectTest{
    
    
    // 先订阅 才能收到
    RACSubject *subject = [RACSubject subject];
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"1--%@,type:%s",x,object_getClassName(x));
    }];
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"2--%@,type:%s",x,object_getClassName(x));
    }];
    [subject sendNext:@1];
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"3--%@,type:%s",x,object_getClassName(x));
    }];
    
    // combineLatest 操作
    //只有当两个信号都成功发送过信号的时候打包后的信号才能正常执行订阅后的代码块。

    RACSubject *baseSubjectTwo = [RACSubject subject];
    RACSubject *baseSignal = [RACSubject subject];
    [[RACSignal combineLatest:@[baseSignal,baseSubjectTwo]]subscribeNext:^(id x) {
        RACTupleUnpack(NSNumber*value,NSNumber*value2) =x;
        NSLog(@"信号发送combineLatest--%@---%@-",value,value2);
    }];
    [baseSignal sendNext:@1];
    [baseSubjectTwo sendNext:@3];

    
    //merge 只有有任意一个信号完成信息的发送。那么合并后的信号就可以正常的接收到信号。
    RACSubject*oneSubejct = [RACSubject subject];
    RACSubject *baseSignal1 = [RACSubject subject];
    [[RACSignal merge:@[oneSubejct,baseSignal]]subscribeNext:^(id x) {
        NSLog(@"信号merge发送信号--%@-",x);
    }];
    [baseSignal1 sendNext:@"testBac"];
    
    // 创建信号中的信号
    RACSubject *signalOfsignals1 = [RACSubject subject];
    RACSubject *signal1 = [RACSubject subject];
    
    // 来个 复杂 难理解的
    [[signalOfsignals1 flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        // 当signalOfsignals的signals发出信号才会调用
        return value;
    }]subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@aaa",x);
        // 只有signalOfsignals的signal发出信号才会调用，因为内部订阅了bindBlock中返回的信号，也就是flattenMap返回的信号。
        // 也就是flattenMap返回的信号发出内容，才会调用。
    }];
    // 信号的信号发送信号
    [signalOfsignals1 sendNext:signal1];
    // 信号发送内容
    [signal1 sendNext:@1];
    
    // 个人 是不常用
    RACSubject *signal = [RACSubject subject];
    // 节流，在一定时间（1秒）内，不接收任何信号内容，过了这个时间（1秒）获取最后发送的信号内容发出。
    [[signal throttle:1] subscribeNext:^(id x) {
        NSLog(@"---throttle--%@",x);
    }];
    
    /**
     RACReplaySubject 创建方法：
     （1）创建RACSubject
     （2）订阅信号
     （3）发送信号
     工作流程：
     （1）订阅信号时，内部保存了订阅者，和订阅者响应block
     （2）当发送信号的，遍历订阅者，调用订阅者的nextBlock
     （3）发送的信号会保存起来，当订阅者订阅信号的时，会将之前保存的信号，一个一个作用于新的订阅者，保存信号的容量由capacity决定，这也是有别有RACSubject的
     */
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
