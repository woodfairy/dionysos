#import <Foundation/Foundation.h>
#import "Converter/DionysosConverter.h"
#import "Downloader/DionysosDownloader.h"
#import "Queue/DionysosQueue.h"
#import "../shared/NSTask.h"
#import "FakeNotifier/BBServer.h"
#import "FakeNotifier/FakeNotifier.h"
#import <MRYIPCCenter.h>


MRYIPCCenter *center;
NSOperationQueue *operationQueue;
DionysosDownloader *downloader;
DionysosConverter *converter;
DionysosQueue *queue;
static FakeNotifier *fakeNotifier = nil;

@interface NSUserDefaults (Tweak_Category)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

static NSString *nsDomainString = @"0xcc.woodfairy.dionysos";
static NSString *nsNotificationString = @"0xcc.woodfairy.dionysos/preferences.changed";
static BOOL enabled;

