#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import "BBServer.h"

@interface FakeNotifier : NSObject
@property(retain) BBServer *bbServer;
-(void)fakeNotification:(NSString *)sectionID title:(NSString *)title date:(NSDate *)date message:(NSString *)message banner:(BOOL) banner;
@end
