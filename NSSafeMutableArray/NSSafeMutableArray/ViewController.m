//
//  ViewController.m
//  NSSafeMutableArray
//
//  Created by wjj on 2019/10/18.
//  Copyright © 2019 wjj. All rights reserved.
//

#import "ViewController.h"
#import "NSSafeMutableArray.h"

@interface ViewController ()

@property (nonatomic, strong)NSSafeMutableArray *safeArray1;
@property (nonatomic, strong)NSSafeMutableArray *safeArray2;
@property (nonatomic, strong)NSSafeMutableArray *safeArray3;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for ( int i = 0; i < 50; i ++) {
        dispatch_async(queue, ^{
            
            NSLog(@"----添加第%d个",i);
            [self.safeArray1 addObject:[NSString stringWithFormat:@"%d",i]];
            
        });
        
        dispatch_async(queue, ^{
            
            NSLog(@"++++添加第%d个",i);
            [self.safeArray2 addObject:[NSString stringWithFormat:@"%d",i]];
            
        });
        
        dispatch_async(queue, ^{
            
            NSLog(@"0000添加第%d个",i);
            [self.safeArray3 addObject:[NSString stringWithFormat:@"%d",i]];
            
        });
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self sort];
    });
}

- (void)sort
{
    [self.safeArray1 sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([(NSString *)obj1 integerValue] > [(NSString *)obj2 integerValue]) {
            return NSOrderedDescending;
        }
        if ([(NSString *)obj1 integerValue] < [(NSString *)obj2 integerValue]) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    
    [self.safeArray2 sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([(NSString *)obj1 integerValue] > [(NSString *)obj2 integerValue]) {
            return NSOrderedDescending;
        }
        if ([(NSString *)obj1 integerValue] < [(NSString *)obj2 integerValue]) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    
    [self.safeArray3 sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([(NSString *)obj1 integerValue] > [(NSString *)obj2 integerValue]) {
            return NSOrderedAscending;
        }
        if ([(NSString *)obj1 integerValue] < [(NSString *)obj2 integerValue]) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
}

@end
