#include <stdio.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "../shared/NSTask.h"

void ensurePip();
void installYoutubeDl();

int main(int argc, char *argv[], char *envp[]) {
    ensurePip();
    installYoutubeDl();
	return 0;
}

// TODO: squeeze until DRY 
void ensurePip() {
    @autoreleasepool {
        NSLog(@"<Dionysos> (postinst) Installing pip...");
        NSTask *ensurePipTask = [[NSTask alloc] init];
        [ensurePipTask setLaunchPath:@"/usr/bin/python3"];
        [ensurePipTask setArguments:@[@"-m", @"ensurepip"]];

        NSPipe *pipe = [NSPipe pipe];
        [ensurePipTask setStandardOutput:pipe];

        [ensurePipTask launch];
        NSLog(@"<Dionysos> (postinst) pip installation task launched");
        [ensurePipTask waitUntilExit];

        NSFileHandle *readFileHandle = [pipe fileHandleForReading];
        NSData *data = [readFileHandle readDataToEndOfFile];
        NSString *taskOutput = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"<Dionysos> (postinst) Task finished with output %@", taskOutput);
    }
}

void installYoutubeDl() {
    @autoreleasepool {
        NSLog(@"<Dionysos> (postinst) Installing pip module youtube-dl...");
        NSTask *pipInstallTask = [[NSTask alloc] init];
        [pipInstallTask setLaunchPath:@"/usr/bin/python3"];
        [pipInstallTask setArguments:@[@"-m", @"pip", @"install", @"youtube-dl"]];

        NSPipe *pipe = [NSPipe pipe];
        [pipInstallTask setStandardOutput:pipe];

        [pipInstallTask launch];
        NSLog(@"<Dionysos> (postinst) youtube-dl installation task launched");
        [pipInstallTask waitUntilExit];

        NSFileHandle *readFileHandle = [pipe fileHandleForReading];
        NSData *data = [readFileHandle readDataToEndOfFile];
        NSString *taskOutput = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"<Dionysos> (postinst) Task finished with output %@", taskOutput);
    }
}