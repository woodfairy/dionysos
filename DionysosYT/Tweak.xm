#include "DionysosYT.h"

MRYIPCCenter *center;


int counter = 0;

@interface NSUserDefaults (Tweak_Category)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

static NSString *nsDomainString = @"0xcc.woodfairy.dionysos";
static NSString *nsNotificationString = @"0xcc.woodfairy.dionysos/preferences.changed";
static BOOL enabled;
//static BOOL downloading = NO;

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	NSNumber *enabledValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled" inDomain:nsDomainString];
	enabled = (enabledValue) ? [enabledValue boolValue] : YES;
}


%hook YTPlayerViewController
-(id)contentVideoID {
	NSString *orig = %orig;
	NSLog(@"<DionysosYT> Starting download for ID %@ - count %d", orig, ++counter);
/*
	if (!downloading) {
		downloading = YES;
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSString *url = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", orig];
			NSString *result = [center callExternalMethod:@selector(downloadAndConvert:) withArguments:@{@"url" : url}];
			NSLog(@"Finished external call with result %@", result);
			downloading = NO;
		});
	}*/
	return %orig;
}
%end


%hook YTSlimVideoDetailsActionView
-(void)didTapButton:(id)arg1 {
	NSLog(@"<DionysosYT> didTapButton");
	YTFormattedStringLabel *label = [self label];
	NSAttributedString *attributedString = label.attributedText;
	NSString *strLabel = attributedString.string;
	NSLog(@"<DionysosYT> Label: %@", strLabel);
	if ([strLabel isEqualToString:@"Download"]) {
		NSLog(@"<DionysosYT> Download button triggered!");
	} else {
		%orig;
	}

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
