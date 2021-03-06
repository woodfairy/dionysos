#import <Foundation/Foundation.h>
#import "Converter/DionysosConverter.h"
#import "Downloader/DionysosDownloader.h"
#import "../shared/NSTask.h"
#import <MRYIPCCenter.h>

MRYIPCCenter *center;

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

%ctor {
    NSLog(@"Injecting into SB");
	// Set variables on start up
	notificationCallback(NULL, NULL, NULL, NULL, NULL);

	// Register for 'PostNotification' notifications
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, notificationCallback, (CFStringRef)nsNotificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);
    
	// Add any personal initializations
	if (enabled) {
        center = [MRYIPCCenter centerNamed:@"0xcc.woodfairy.DionysosServer"];
        [center addTarget:^NSString* (NSDictionary* args){
            DionysosDownloader *downloader = [[DionysosDownloader alloc] init];
            NSString *output = [downloader downloadFrom:args[@"url"] destination:@"/var/mobile/Downloads" title:args[@"title"]];
            DionysosConverter *converter = [[DionysosConverter alloc] init];
            int rc = [
						converter 
						convert: [NSString stringWithFormat:@"/var/mobile/Downloads/%@.mp4", args[@"title"]] 
						toTarget: [NSString stringWithFormat:@"/var/mobile/Downloads/%@.mp3", args[@"title"]]
					];
            NSLog(@"<Dionysos> Conversion finished with rc %d", rc);
            return output;
	    } forSelector:@selector(downloadAndConvert:)];
	}
}
