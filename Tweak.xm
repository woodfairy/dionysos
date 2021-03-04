#import <Foundation/Foundation.h>
#import "Dionysos/DionysosConverter.h"


@interface NSUserDefaults (Tweak_Category)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

static NSString * nsDomainString = @"0xcc.woodfairy.dionysos";
static NSString * nsNotificationString = @"0xcc.woodfairy.dionysos/preferences.changed";
static BOOL enabled;

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	NSNumber * enabledValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled" inDomain:nsDomainString];
	enabled = (enabledValue) ? [enabledValue boolValue] : YES;
}

%ctor {
	// Set variables on start up
	notificationCallback(NULL, NULL, NULL, NULL, NULL);

	// Register for 'PostNotification' notifications
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, notificationCallback, (CFStringRef)nsNotificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);

	// Add any personal initializations
	if (enabled) {
		DionysosConverter *converter = [[DionysosConverter alloc] init];
		NSLog(@"<Dionysos> Created converter %@", converter);
		int rc = [converter convertToMp3:@"/var/mobile/Documents/sample-mp4-file.mp4" forTarget:@"/var/mobile/Downloads/AAAAAAAAtarget.mp4"];
		NSLog(@"<Dionysos> Converting finished with rc %d", rc);
	}
}
