#include "DionysosYT.h"

@interface NSUserDefaults (Tweak_Category)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

static MRYIPCCenter *center;
static int counter = 0;
static NSString *contentVideoID;
static NSString *videoTitle;
static NSString *nsDomainString = @"0xcc.woodfairy.dionysos";
static NSString *nsNotificationString = @"0xcc.woodfairy.dionysos/preferences.changed";
static BOOL enabled;

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	NSNumber *enabledValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled" inDomain:nsDomainString];
	enabled = (enabledValue) ? [enabledValue boolValue] : YES;
}

static NSString* sanitizeFileNameString(NSString *fileName) {
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>"];
    return [[[fileName componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
}

static void download(NSString *contentVideoID, NSString *videoTitle) {
	if (!contentVideoID) return;
	NSLog(@"<DionysosYT> Download button triggered! video id %@ / %@", contentVideoID, videoTitle);
	NSString *url = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", contentVideoID];
	NSString *result = [center callExternalMethod:@selector(downloadAndConvert:) withArguments:@{@"url" : url, @"title": videoTitle}];
	NSLog(@"Finished external call with result %@", result);
}


%hook YTPlayerViewController
-(id)contentVideoID {
	contentVideoID = %orig;
	NSLog(@"<DionysosYT> Setting video ID %@ - count %d", contentVideoID, ++counter);
	return %orig;
}
%end

%hook YTSlimVideoDetailsActionView
-(void)didTapButton:(id)arg1 {
	NSLog(@"<DionysosYT> didTapButton");
	YTSlimVideoScrollableDetailsActionView *visibilityDelegate = [self visibilityDelegate];
	NSLog(@"<DionysosYT> visibilityDelegate %@", visibilityDelegate);
	NSLog(@"<DionysosYT> offlineActionView %@", [visibilityDelegate offlineActionView]);
	NSLog(@"<DionysosYT> self %@", self);
	if ([visibilityDelegate offlineActionView] == self) {
		NSLog(@"<DionysosYT> Download button triggered! video id %@ / %@", contentVideoID, videoTitle);
		download(contentVideoID, sanitizeFileNameString(videoTitle));
	} else {
		%orig;
	}

}
%end

%hook YTISlimVideoInformationRenderer
-(id)title {
	YTIFormattedString *formattedTitle = %orig;
	videoTitle = [formattedTitle dropdownOptionTitle];
	NSLog(@"<DionysosYT> title %@", videoTitle);
	
	return formattedTitle;
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
