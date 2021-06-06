#import "DionysosQueue.h"

@implementation DionysosQueue : NSObject
-(void)createWithMaxConcurrentOperationCount:(int) maxCount {
    _queue = [[NSOperationQueue alloc] init];
    _queue.maxConcurrentOperationCount = maxCount;
}
@end