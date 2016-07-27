//
//  NetWorkRequestThread.h
//  test_nstherad_port_02
//  Created by jeffasd on 16/7/25.
//  Copyright © 2016年 jeffasd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^NetWorkBLock)(int a, int b);

@interface NetWorkRequest : NSObject

+ (instancetype)shareNetRequest;

- (void)cancel;

- (void)doActionWithSEL:(SEL)sel AndSelInObject:(id)obj BLock:(NetWorkBLock)block;

@end
