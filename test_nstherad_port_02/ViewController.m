//
//  ViewController.m
//  test_nstherad_port_02
//
//  Created by cdd on 16/7/25.
//  Copyright © 2016年 jeffasd. All rights reserved.
//

#import "ViewController.h"
#import "NetWorkRequest.h"

@interface ViewController ()

@property (nonatomic, strong) NSThread *thread;

@property (nonatomic, strong) NetWorkRequest *request;

@end

@implementation ViewController
{
    int var;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _request = [NetWorkRequest new];
//    [_request start];
    
    NSLog(@"_request is %@", _request);
    
    NetWorkRequest *request1 = [NetWorkRequest shareNetRequest];
    NSLog(@"request1 is %@", request1);
    
    NetWorkRequest *request2 = [[NetWorkRequest alloc] init];
    NSLog(@"request1 is %@", request2);

//    [request2 doActionWithSEL:@selector(showInfo) AndSelInObject:self];
    [request2 doActionWithSEL:@selector(showInfoBLock:) AndSelInObject:self BLock:^(int a, int b) {
      
        NSLog(@"self is %@ class is %@", self, [self class]);
        
        NSLog(@"thread is %@", [NSThread currentThread]);
        
        NSLog(@"var is %d", var);
        
        NSLog(@"a is %d", a);
        
    }];
    
}

//此方法在NetWorkRequest对象中并且在NetworkRequestThread子线程中运行
//注意不能访问 当前对象内的成员变量和方法 能访问但是赋的值无法传给当前对象 此方法相当于是NetWorkRequest对象的方法
//- (void)showInfoBLock:(NetWorkBLock)block{
//    
//    NSTimer *timer = (NSTimer *)block;
//    block = [timer userInfo];
//    
//    
//    NSLog(@"self is %@ class is %@", self, [self class]);
//    
//    NSLog(@"thread is %@", [NSThread currentThread]);
//    
//    NSLog(@"this is test show info message");
//    
//    block(3, 5);
//}


- (void)showInfoBLock:(NSTimer *)timer{
    

    NetWorkBLock block = [timer userInfo];
    
    NSLog(@"self is %@ class is %@", self, [self class]);
    
    NSLog(@"thread is %@", [NSThread currentThread]);
    
    NSLog(@"this is test show info message");
    
    block(3, 5);
}


#if 0
- (void)threadEntryPoint{
    
    NSLog(@"ththh");
    
    [[NSThread currentThread] setName:@"customThread"];
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    [runloop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
//    [runloop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    
    [runloop run];
    
    
    
    
}

- (void)start {
//    [self.lock lock];
//    if ([self isCancelled]) {
//        [self performSelector:@selector(cancelConnection) onThread:[[self class] networkRequestThread] withObject:nil waitUntilDone:NO modes:[self.runLoopModes allObjects]];
//    } else if ([self isReady]) {
//        self.state = AFOperationExecutingState;
//        [self performSelector:@selector(operationDidStart) onThread:[[self class] networkRequestThread] withObject:nil waitUntilDone:NO modes:[self.runLoopModes allObjects]];
//    }
//    [self.lock unlock];
    
    [self performSelector:@selector(showSomething) onThread:_thread withObject:nil waitUntilDone:NO];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [_request cancel];
}

- (void)showSomething{
    
    NSThread *thread = [NSThread currentThread];
    NSLog(@"thread is %@", thread);
    
    NSLog(@"showSomething");
    
    
}
#endif

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
