#import "DionysosDownloader.h"

@implementation DionysosDownloader : NSObject
-(NSString *) download:(NSString *)url format:(NSString *)format destination:(NSString *)dest {
    NSLog(@"<Dionysos> Starting download for URL %@ - %@", url, format);
	NSTask *youtubeDownloadTask = [[NSTask alloc] init];
    NSPipe *out = [NSPipe pipe];
    [youtubeDownloadTask setStandardOutput:out];
    NSLog(@"<Dionysos> Created task %@", youtubeDownloadTask);
    [youtubeDownloadTask setLaunchPath:@"/usr/bin/python3"];
    [youtubeDownloadTask setCurrentDirectoryPath:dest];
    [youtubeDownloadTask 
        setArguments:@[
            @"-m", 
            @"youtube_dl", 
            url, 
            @"-f", 
            format,
            @"--restrict-filenames",
            @"--no-continue",
            //@"-o", 
            //[NSString stringWithFormat:@"%@.%@", filename, suffix]
        ]
    ];
    NSLog(@"<Dionysos> Launching NSTask");
    [youtubeDownloadTask launch];
    [youtubeDownloadTask waitUntilExit];
    NSFileHandle *readHandle = [out fileHandleForReading];
    NSData *data = [readHandle readDataToEndOfFile];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
-(NSString *) getFilename:(NSString *)url format:(NSString *)format {
	NSTask *youtubeDownloadTask = [[NSTask alloc] init];
    NSPipe *out = [NSPipe pipe];
    [youtubeDownloadTask setStandardOutput:out];
    [youtubeDownloadTask setLaunchPath:@"/usr/bin/python3"];
    [youtubeDownloadTask 
        setArguments:@[
            @"-m", 
            @"youtube_dl", 
            url, 
            @"-f", 
            format,
            @"--restrict-filenames",
            @"--get-filename",
        ]
    ];
    [youtubeDownloadTask launch];
    [youtubeDownloadTask waitUntilExit];
    NSFileHandle *readHandle = [out fileHandleForReading];
    NSData *data = [readHandle readDataToEndOfFile];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
@end