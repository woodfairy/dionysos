#import <Foundation/Foundation.h>

@interface DionysosQueue : NSObject
@property NSOperationQueue *queue;
-(void)createWithMaxConcurrentOperationCount:(int) maxCount;
@end