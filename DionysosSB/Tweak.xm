#import "DionysosSB.h"


MRYIPCCenter *center;
// test notifications
static BBServer* bbServer = nil;

static dispatch_queue_t getBBServerQueue() {
    static dispatch_queue_t queue;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
    void* handle = dlopen(NULL, RTLD_GLOBAL);
        if (handle) {
            dispatch_queue_t __weak *pointer = (__weak dispatch_queue_t *) dlsym(handle, "__BBServerQueue");
            if (pointer) queue = *pointer;
            dlclose(handle);
        }
    });

    return queue;
}

static void fakeNotification(NSString *sectionID, NSDate *date, NSString *message, bool banner) {
	BBBulletin* bulletin = [[%c(BBBulletin) alloc] init];
	bulletin.title = @"Dionysos";
    bulletin.message = message;
    bulletin.sectionID = sectionID;
    bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.publisherBulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.date = date;
    bulletin.defaultAction = [%c(BBAction) actionWithLaunchBundleID:sectionID callblock:nil];
    bulletin.clearable = YES;
    bulletin.showsMessagePreview = YES;
    bulletin.publicationDate = date;
    bulletin.lastInterruptDate = date;

    if (banner) {
        if ([bbServer respondsToSelector:@selector(publishBulletin:destinations:)]) {
            dispatch_sync(getBBServerQueue(), ^{
                [bbServer publishBulletin:bulletin destinations:15];
            });
        }
    } else {
        if ([bbServer respondsToSelector:@selector(publishBulletin:destinations:alwaysToLockScreen:)]) {
            dispatch_sync(getBBServerQueue(), ^{
                [bbServer publishBulletin:bulletin destinations:4 alwaysToLockScreen:YES];
            });
        } else if ([bbServer respondsToSelector:@selector(publishBulletin:destinations:)]) {
            dispatch_sync(getBBServerQueue(), ^{
                [bbServer publishBulletin:bulletin destinations:4];
            });
        }
    }

}


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
    bbServer = %orig;
    return bbServer;
}

- (id)initWithQueue:(id)arg1 dataProviderManager:(id)arg2 syncService:(id)arg3 dismissalSyncCache:(id)arg4 observerListener:(id)arg5 utilitiesListener:(id)arg6 conduitListener:(id)arg7 systemStateListener:(id)arg8 settingsListener:(id)arg9 {
    bbServer = %orig;
    return bbServer;
}

- (void)dealloc {
    if (bbServer == self) bbServer = nil;
    %orig;
}
%end


%ctor {
    NSLog(@"Injecting into SB");
	// Set variables on start up
	notificationCallback(NULL, NULL, NULL, NULL, NULL);

	// Register for 'PostNotification' notifications
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, notificationCallback, (CFStringRef)nsNotificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);
    
	// Add any personal initializations
	if (enabled) { // TODO: put converter and downloader into separate processes / daemon
        center = [MRYIPCCenter centerNamed:@"0xcc.woodfairy.DionysosServer"];
        [center addTarget:^NSString* (NSDictionary* args){
			fakeNotification(@"com.google.ios.youtube", [NSDate date], [NSString stringWithFormat:@"%@\nDownload started.", args[@"title"]], true);
            DionysosDownloader *downloader = [[DionysosDownloader alloc] init];
            NSString *audioFilename = [[downloader getFilename:args[@"url"] format:@"bestaudio"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *output = [[downloader download:args[@"url"] format:@"bestaudio" destination:@"/var/mobile/Downloads"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *videoFilename = [[downloader getFilename:args[@"url"] format:@"bestvideo"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            output = [downloader download:args[@"url"] format:@"bestvideo" destination:@"/var/mobile/Downloads"];
			fakeNotification(@"com.google.ios.youtube", [NSDate date], [NSString stringWithFormat:@"%@ downloaded succesfully.", args[@"title"]], true);
            DionysosConverter *converter = [[DionysosConverter alloc] init];
            int rc = [
                converter
                mergeVideo: [NSString stringWithFormat:@"/var/mobile/Downloads/%@", videoFilename]
                withAudio: [NSString stringWithFormat:@"/var/mobile/Downloads/%@", audioFilename]
                out: [NSString stringWithFormat:@"/var/mobile/Downloads/%@", args[@"title"]]
            ];
            NSLog(@"<Dionysos> Merge finished with rc %d", rc);
			fakeNotification(@"com.google.ios.youtube", [NSDate date], [NSString stringWithFormat:@"%@ merged succesfully.", args[@"title"]], true);
            /*rc = [
				converter 
				convert: [NSString stringWithFormat:@"/var/mobile/Downloads/%@.mp4", args[@"title"]]
				toTarget: [NSString stringWithFormat:@"/var/mobile/Downloads/%@.mp3", args[@"title"]]
			];
            NSLog(@"<Dionysos> Conversion finished with rc %d", rc);
			fakeNotification(@"com.google.ios.youtube", [NSDate date], [NSString stringWithFormat:@"%@ converted succesfully.", args[@"title"]], true);*/
            return output;
	    } forSelector:@selector(downloadAndConvert:)];
	}
}
