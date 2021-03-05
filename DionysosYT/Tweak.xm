#include "DionysosYT.h"
#import <Foundation/Foundation.h>
#import <MRYIPCCenter.h>

MRYIPCCenter *center;
YTPlayerViewController *viewController;
int counter = 0;

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


%hook YTPlayerViewController
-(id) init {
	NSLog(@"<DionysosYT> YTPlayerViewController init");
	viewController = %orig;
	return viewController;
}
-(id) contentVideoID {
	NSString *orig = %orig;
	NSLog(@"<DionysosYT> YTPlayerViewController orig %@ - count %d", orig, ++counter);
	NSString *url = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", orig];
	NSString* result = [center callExternalMethod:@selector(downloadAndConvert:) withArguments:@{@"url" : url}];
	NSLog(@"Finished external call with result %@", result);
	return %orig;
}
%end

%ctor {
	// Set variables on start up
	notificationCallback(NULL, NULL, NULL, NULL, NULL);

	// Register for 'PostNotification' notifications
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, notificationCallback, (CFStringRef)nsNotificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);

	// Add any personal initializations
	if (enabled) {
		center = [MRYIPCCenter centerNamed:@"0xcc.woodfairy.DionysosServer"];
	}
}
