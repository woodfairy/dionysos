#import <Foundation/Foundation.h>
#import "Converter/DionysosConverter.h"
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
            NSLog(@"<Dionysos> Starting download for URL %@", args[@"url"]);
		    NSTask *youtubeDownloadTask = [[NSTask alloc] init];
            NSPipe *out = [NSPipe pipe];
            [youtubeDownloadTask setStandardOutput:out];
            NSLog(@"<Dionysos> Created task %@", youtubeDownloadTask);
            [youtubeDownloadTask setLaunchPath:@"/usr/bin/python3"];
            [youtubeDownloadTask setCurrentDirectoryPath:@"/var/mobile/Downloads"];
            [youtubeDownloadTask setArguments:@[@"-m", @"youtube_dl", args[@"url"], @"-f", @"best[ext=mp4]", @"--no-continue", @"-o", @"DionysosDownloader.mp4"]];
            NSLog(@"<Dionysos> Launching NSTask");
            [youtubeDownloadTask launch];
            [youtubeDownloadTask waitUntilExit];
            NSFileHandle * read = [out fileHandleForReading];
            NSData * dataRead = [read readDataToEndOfFile];
            NSString * stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
            NSLog(@"<Dionysos> ----> NSTask output: %@", stringRead);
            NSLog(@"<Dionysos> Task finished");
            DionysosConverter *converter = [[DionysosConverter alloc] init];
            NSLog(@"<Dionysos> Created converter %@", converter);
            int rc = [converter convert:@"/var/mobile/Downloads/DionysosDownloader.mp4" toTarget:@"/var/mobile/Downloads/DionysosConverter.wav"];
            NSLog(@"<Dionysos> Converting finished with rc %d", rc);

            return stringRead;
	    } forSelector:@selector(downloadAndConvert:)];
	}
}
