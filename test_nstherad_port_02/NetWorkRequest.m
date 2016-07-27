//
//  NetWorkRequestThread.m
//  test_nstherad_port_02
//  Created by jeffasd on 16/7/25.
//  Copyright © 2016年 jeffasd. All rights reserved.
//  创建一个和app生命周期相同的线程并一直请求发起网络请求

#import "NetWorkRequest.h"
#import <objc/runtime.h>

void *kBlockUniqueKey = &kBlockUniqueKey;

@interface NetWorkRequest () <NSCopying, NSMutableCopying>

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation NetWorkRequest

static NetWorkRequest *_networkRequest = nil;

+ (instancetype)shareNetRequest{
    
    if (_networkRequest == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _networkRequest = [[self alloc] init];
        });
    }
    return _networkRequest;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _networkRequest = [super allocWithZone:zone];
    });
    return _networkRequest;
}

- (instancetype)init{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _networkRequest = [super init];
    });
    return _networkRequest;
}

- (id)copyWithZone:(NSZone *)zone{
    return _networkRequest;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    return _networkRequest;
}

+ (NSThread *)shareNetworkRequestThread{
    
    static NSThread *_networkRequestThread = nil;
    if (_networkRequestThread == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _networkRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkrRequestThreadEntryPoint:) object:nil];
            [_networkRequestThread start];
        });
    }
    return _networkRequestThread;
}

+(void)networkrRequestThreadEntryPoint:(id)__unused object{
    
    [[NSThread currentThread] setName:@"networkRequestThread"];
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    //添加一个port监听让runloop一直处于运行状态 好让thread不被回收
    [runloop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
#if 0
    BOOL isRuning = YES;
    while (isRuning) {
        //此方法添加的runloop可以用CFRunLoopStop(runLoopRef)来停止RunLoop的运行
        //子线程中的runmode不能使用NSRunLoopCommonModes
        //    [runloop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        //一直监听线程是否有消息输入（default模式），有当前线程就开始工作，没有就休眠。进行一次消息轮询，如果没有任务需要处理的消息源，则直接返回
        BOOL isRuning = [runloop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        //此方法停止runloop要设置isRuning为NO 不是很方便 使用 CFRunLoopRun(); 方法来代替
        NSLog(@"isRuning is %@", isRuning ? @"YES" : @"NO");
    }
#endif
    
    //可以很方便暂停runloop循环
    CFRunLoopRun();
    
}

- (void)start{
    
    [self performSelector:@selector(startNetWorkRequest) onThread:[[self class] shareNetworkRequestThread] withObject:nil waitUntilDone:NO];
}

- (void)startNetWorkRequest{
    
//    NSThread *currentThread = [NSThread currentThread];
//    NSLog(@"currentThread is %@", currentThread);
//    NSLog(@"runLoop is %@", [NSRunLoop currentRunLoop]);
    NSLog(@"do Something");
    
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(getMessageFormRemoteService) userInfo:nil repeats:YES];

    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    
}

- (void)getMessageFormRemoteService{
    
    NSLog(@"currentThread is %@", [NSThread currentThread]);
    NSLog(@"service -- ");
}

- (void)cancel{
    
    NSThread *therad = [[self class] shareNetworkRequestThread];
    
    NSLog(@"the thread is %@", therad.executing ? @"YES" : @"NO");
    NSLog(@"the thread is %@", therad.finished ? @"YES" : @"NO");
    NSLog(@"the thread is %@", therad.cancelled ? @"YES" : @"NO");
    
    NSLog(@"the thread is %@", therad);
    
    [self performSelector:@selector(cancelNetWorkRequest) onThread:[[self class] shareNetworkRequestThread] withObject:nil waitUntilDone:NO];
}

//在networkRequestThread线程中执行其他对象的方法
- (void)doActionWithSEL:(SEL)sel AndSelInObject:(id)obj BLock:(NetWorkBLock)block{
    
    IMP imp = [obj methodForSelector:sel];
    Method origMethod = class_getInstanceMethod([obj class], sel);
    const char * types = method_getTypeEncoding(origMethod);
    class_addMethod([self class], sel, imp, types);
    NSString *selName = [NSString stringWithUTF8String:sel_getName(sel)];
    objc_setAssociatedObject(self, _cmd, selName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, kBlockUniqueKey, block, OBJC_ASSOCIATION_COPY);
    
    if ([self respondsToSelector:sel]) {
        //直接在子线程调用
//        [self performSelector:sel onThread:[[self class] shareNetworkRequestThread] withObject:block waitUntilDone:NO];
        //添加定时器并在子线程调用
        [self performSelector:@selector(startNetWorkRequestTimerWithBlock:) onThread:[[self class] shareNetworkRequestThread] withObject:nil waitUntilDone:NO];
    }
    
}

- (void)startNetWorkRequestTimerWithBlock:(NetWorkBLock)block{
    
    NSString *selName = objc_getAssociatedObject(self, @selector(doActionWithSEL:AndSelInObject:BLock:));
    SEL sel = NSSelectorFromString(selName);
    block = objc_getAssociatedObject(self, kBlockUniqueKey);
    
    //添加定时器调用
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:sel userInfo:block repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    
}

- (void)cancelNetWorkRequest{
    
    NSThread *currentThread = [NSThread currentThread];
    NSLog(@"currentThread is %@", currentThread);
    
    CFRunLoopStop([NSRunLoop currentRunLoop].getCFRunLoop);
//    CFRunLoopStop(CFRunLoopGetCurrent());
}

@end
