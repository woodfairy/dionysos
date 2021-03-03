#import <Foundation/Foundation.h>
#import <mobileffmpeg/MobileFFmpegConfig.h>
#import <mobileffmpeg/MobileFFmpeg.h>


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
	int rc = [MobileFFmpeg execute: @"-i test.mp4 -c:v mpeg4 test2.mp4"];

	if (rc == RETURN_CODE_SUCCESS) {
		NSLog(@"Command execution completed successfully.\n");
	} else if (rc == RETURN_CODE_CANCEL) {
		NSLog(@"Command execution cancelled by user.\n");
	} else {
		NSLog(@"Command execution failed with rc=%d and output=%@.\n", rc, [MobileFFmpegConfig getLastCommandOutput]);
	}
	// Set variables on start up
	notificationCallback(NULL, NULL, NULL, NULL, NULL);

	// Register for 'PostNotification' notifications
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, notificationCallback, (CFStringRef)nsNotificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);

	// Add any personal initializations

}
