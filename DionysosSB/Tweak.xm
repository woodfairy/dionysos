#import "DionysosSB.h"
#import "FakeNotifier/BBServer.h"
#import "FakeNotifier/FakeNotifier.h"

MRYIPCCenter *center;
NSOperationQueue *operationQueue;
DionysosDownloader *downloader;
DionysosConverter *converter;
static FakeNotifier *fakeNotifier = nil;

@interface NSUserDefaults (Tweak_Category)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

static NSString *nsDomainString = @"0xcc.woodfairy.dionysos";
static NSString *nsNotificationString = @"0xcc.woodfairy.dionysos/preferences.changed";
static BOOL enabled;

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	NSNumber *enabledValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled" inDomain:nsDomainString];
	enabled = (enabledValue) ? [enabledValue boolValue] : YES;
}

%hook BBServer
- (id)initWithQueue:(id)arg1 {
    BBServer *bbServer = %orig;
    if (fakeNotifier) [fakeNotifier setBbServer:bbServer];
    return bbServer;
}

- (id)initWithQueue:(id)arg1 dataProviderManager:(id)arg2 syncService:(id)arg3 dismissalSyncCache:(id)arg4 observerListener:(id)arg5 utilitiesListener:(id)arg6 conduitListener:(id)arg7 systemStateListener:(id)arg8 settingsListener:(id)arg9 {
    BBServer *bbServer = %orig;
    if (fakeNotifier) [fakeNotifier setBbServer:bbServer];
    return bbServer;
}

- (void)dealloc {
    if ([fakeNotifier bbServer] == self) [fakeNotifier setBbServer:nil];
    %orig;
}
%end


%ctor {
    NSLog(@"Injecting into SB");
	// Set variables on start up
	notificationCallback(NULL, NULL, NULL, NULL, NULL);

	// Register for 'PostNotification' notifications
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, notificationCallback, (CFStringRef)nsNotificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);
    
    fakeNotifier = [[FakeNotifier alloc] init];

    center = [MRYIPCCenter centerNamed:@"0xcc.woodfairy.DionysosServer"];
    operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = 4;
    downloader = [[DionysosDownloader alloc] init];
    converter = [[DionysosConverter alloc] init];

    if (enabled) {
        [center addTarget:^NSString* (NSDictionary* args){
        NSLog(@"<DionysosSB> IPC works");
        [fakeNotifier fakeNotification:@"com.google.ios.youtube" 
                      title:args[@"title"] 
                      date:[NSDate date]
                      message:@"Added to download queue." 
                      banner:YES
        ];

        [operationQueue addOperationWithBlock:^{
            NSLog(@"<DionysosSB> IPC dispatch works");
            [fakeNotifier fakeNotification:@"com.google.ios.youtube" 
                          title:args[@"title"] 
                          date:[NSDate date]
                          message:@"Download started"
                          banner:YES
            ];
            //NSString *audioFilename = [[downloader getFilename:args[@"url"] format:@"bestaudio"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            //NSString *output = [[downloader download:args[@"url"] format:@"bestaudio" destination:@"/var/tmp"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *videoFilename = [[downloader getFilename:args[@"url"] format:@"best"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *output = [downloader download:args[@"url"] format:@"best" destination:@"/var/tmp"];
            [fakeNotifier fakeNotification:@"com.google.ios.youtube" 
                          title:args[@"title"] 
                          date:[NSDate date]
                          message:@"Download finished. Converting and exporting to camera roll..."
                          banner:YES
            ];
            NSLog(@"<DionysosSB> Saving %@ to camera roll", videoFilename);
            NSString *videoPath = [NSString stringWithFormat:@"/var/tmp/%@", videoFilename];
            UISaveVideoAtPathToSavedPhotosAlbum(videoPath, converter, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            [fakeNotifier fakeNotification:@"com.google.ios.youtube" 
                          title:args[@"title"]
                          date:[NSDate date]
                          message:@"Saved to camera roll."
                          banner:YES
            ];
            
            /*int rc = [
                converter
                mergeVideo: [NSString stringWithFormat:@"/var/tmp/%@", videoFilename]
                withAudio: [NSString stringWithFormat:@"/var/tmp/%@", audioFilename]
                out: [NSString stringWithFormat:@"/var/tmp/%@", args[@"title"]]
            ];*
            
            NSLog(@"<Dionysos> Merge finished with rc %d", rc);
            fakeNotification(@"com.google.ios.youtube", args[@"title"], [NSDate date], @"Saved to camera roll.", true);
            /*rc = [
                converter 
                convert: [NSString stringWithFormat:@"/var/mobile/Downloads/%@.mp4", args[@"title"]]
                toTarget: [NSString stringWithFormat:@"/var/mobile/Downloads/%@.mp3", args[@"title"]]
            ];
            NSLog(@"<Dionysos> Conversion finished with rc %d", rc);

            fakeNotification(@"com.google.ios.youtube", [NSDate date], [NSString stringWithFormat:@"%@ converted succesfully.", args[@"title"]], true);*/
            NSLog(@"Finished download call with result %@", output);
        }];

            return @"end>>>>>>>>>>>>>>>>>>>>>>"; // TODO: retval
        } forSelector:@selector(downloadAndConvert:)];
    }
        
}
