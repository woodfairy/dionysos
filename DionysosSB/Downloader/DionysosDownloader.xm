#import "DionysosDownloader.h"

@implementation DionysosDownloader : NSObject
-(NSString*) downloadFrom:(NSString* )url destination:(NSString *)dest {
    NSLog(@"<Dionysos> Starting download for URL %@", url);
	NSTask *youtubeDownloadTask = [[NSTask alloc] init];
    NSPipe *out = [NSPipe pipe];
    [youtubeDownloadTask setStandardOutput:out];
    NSLog(@"<Dionysos> Created task %@", youtubeDownloadTask);
    [youtubeDownloadTask setLaunchPath:@"/usr/bin/python3"];
    [youtubeDownloadTask setCurrentDirectoryPath:dest];
    [youtubeDownloadTask setArguments:@[@"-m", @"youtube_dl", url, @"-f", @"best[ext=mp4]", @"--no-continue", @"-o", @"DionysosDownloader.mp4"]];
    NSLog(@"<Dionysos> Launching NSTask");
    [youtubeDownloadTask launch];
    [youtubeDownloadTask waitUntilExit];
    NSFileHandle *readHandle = [out fileHandleForReading];
    NSData *data = [readHandle readDataToEndOfFile];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
@end