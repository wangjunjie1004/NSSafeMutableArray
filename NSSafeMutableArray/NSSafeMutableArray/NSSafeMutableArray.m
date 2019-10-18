//
//  NSSafeMutableArray.m
//  NSSafeMutableArray
//
//  Created by wjj on 2019/10/18.
//  Copyright © 2019 wjj. All rights reserved.
//

#import "NSSafeMutableArray.h"

@interface NSSafeMutableArray ()
{
    CFMutableArrayRef _array;
}

@property (nonatomic)dispatch_queue_t syncQueue;

@end

@implementation NSSafeMutableArray

- (instancetype)init {
    self = [super init];
    if (self) {
        _array = CFArrayCreateMutable(kCFAllocatorDefault, 10,  &kCFTypeArrayCallBacks);
        NSString *queueName = [NSString stringWithFormat:@"%@.NSSafeMutableArray",[NSProcessInfo processInfo].globallyUniqueString];
        _syncQueue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems
{
    self = [super init];
    if (self) {
        _array = CFArrayCreateMutable(kCFAllocatorDefault, numItems,  &kCFTypeArrayCallBacks);
        NSString *queueName = [NSString stringWithFormat:@"%@.NSSafeMutableArray",[NSProcessInfo processInfo].globallyUniqueString];
        _syncQueue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

#pragma mark - function

- (NSUInteger)count {
    __block NSUInteger result;
    dispatch_sync(self.syncQueue, ^{
        result = CFArrayGetCount(self->_array);
    });
    return result;
}

- (id)objectAtIndex:(NSUInteger)index {
    __block id result;
    dispatch_sync(self.syncQueue, ^{
        NSUInteger count = CFArrayGetCount(self->_array);
        result = index < count ? CFArrayGetValueAtIndex(self->_array, index) : nil;
    });
    return result;
}

- (void)addObject:(id)anObject {
    dispatch_barrier_async(self.syncQueue, ^{
        if (!anObject) {
            return;
        }
        CFArrayAppendValue(self->_array, (__bridge const void *)anObject);
    });
}

- (void)addObjectsFromArray:(NSArray<id> *)otherArray
{
    dispatch_barrier_async(self.syncQueue, ^{
        if (!otherArray) {
            return;
        }
        for (id temp in otherArray) {
            CFArrayAppendValue(self->_array, (__bridge const void *)temp);
        }
    });
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    __block NSUInteger blockIndex = index;
    dispatch_barrier_async(self.syncQueue, ^{
        if (!anObject) {
            return;
        }
        
        NSUInteger count = CFArrayGetCount(self->_array);
        blockIndex = blockIndex > count ? count : blockIndex;
        
        CFArrayInsertValueAtIndex(self->_array, blockIndex, (__bridge const void *)anObject);
    });
}

- (void)removeLastObject {
    dispatch_barrier_async(self.syncQueue, ^{
        NSUInteger count = CFArrayGetCount(self->_array);
        if (count > 0) {
            CFArrayRemoveValueAtIndex(self->_array, count-1);
        }
    });
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    dispatch_barrier_async(self.syncQueue, ^{
        NSUInteger count = CFArrayGetCount(self->_array);
        if (index < count) {
            CFArrayRemoveValueAtIndex(self->_array, index);
        }
    });
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    dispatch_barrier_async(self.syncQueue, ^{
        if (!anObject) {
            return;
        }
        
        NSUInteger count = CFArrayGetCount(self->_array);
        if (index >= count) {
            return;
        }
        
        CFArraySetValueAtIndex(self->_array, index, (__bridge const void*)anObject);
    });
}

- (void)removeAllObjects {
    dispatch_barrier_async(self.syncQueue, ^{
        CFArrayRemoveAllValues(self->_array);
    });
}

- (NSUInteger)indexOfObject:(id)anObject {
    if (!anObject) {
        return NSNotFound;
    }
    
    __block NSUInteger result;
    dispatch_sync(self.syncQueue, ^{
        NSUInteger count = CFArrayGetCount(self->_array);
        result = CFArrayGetFirstIndexOfValue(self->_array, CFRangeMake(0, count), (__bridge const void *)(anObject));
    });
    return result;
}

@end
