#include <stdio.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "../shared/NSTask.h"


void setPipCacheDirectoryOwner(NSString *owner);
void ensurePip();
void installYoutubeDl();
NSString* launchTask(NSString *launchPath, NSArray *arguments);


int main(int argc, char *argv[], char *envp[]) {
    setPipCacheDirectoryOwner(@"root");
    ensurePip();
    setPipCacheDirectoryOwner(@"root");
    installYoutubeDl();
    setPipCacheDirectoryOwner(@"mobile");
	return 0;
}

void setPipCacheDirectoryOwner(NSString *owner) {
    NSLog(@"<Dionysos> (postinst) Setting pip cache directory ownership to %@...", owner);
    launchTask(@"/usr/bin/chown", @[@"-R", owner, @"/private/var/mobile/Library/Caches/pip"]);
}


void ensurePip() {
    NSLog(@"<Dionysos> (postinst) Installing pip...");
    NSString *output = launchTask(@"/usr/bin/python3", @[@"-m", @"ensurepip"]);
    NSLog(@"pip installation finished with output %@", output);

}

void installYoutubeDl() {
    NSLog(@"<Dionysos> (postinst) Installing pip module youtube-dl...");
    NSString *output = launchTask(@"/usr/bin/python3", @[@"-m", @"pip", @"install", @"youtube-dl"]);
    NSLog(@"<Dionysos> (postinst) youtube-dl installation finished with output %@", output);
}

NSString* launchTask(NSString *launchPath, NSArray *arguments) {
    @autoreleasepool {
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:launchPath];
        [task setArguments:arguments];

        NSPipe *pipe = [NSPipe pipe];
        [task setStandardOutput:pipe];

        [task launch];
        [task waitUntilExit];

        NSFileHandle *readFileHandle = [pipe fileHandleForReading];
        NSData *data = [readFileHandle readDataToEndOfFile];
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
}
