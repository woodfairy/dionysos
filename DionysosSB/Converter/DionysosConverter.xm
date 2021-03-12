#import "DionysosConverter.h"

@implementation DionysosConverter
-(int)convert:(NSString *)source toTarget:(NSString *)dest {
	// TODO: remove log noise of mobileffmpeg
	NSLog(@"<Dionysos> convertToMp3 - source: %@ - dest: %@", source, dest);
	NSString *ffmpegCommand = [NSString stringWithFormat:@"-y -i '%@' -q:a 0 -map a '%@'", source, dest];
	NSLog(@"<Dionysos> executing > %@", ffmpegCommand);
    int rc = [MobileFFmpeg execute:ffmpegCommand];
	NSLog(@"<Dionysos> rc %d", rc);

	if (rc == RETURN_CODE_SUCCESS) { // 0
		NSLog(@"<Dionysos> Command execution completed successfully.\n");
	} else if (rc == RETURN_CODE_CANCEL) { // TODO: dunno yet, probably 2 (?)
		NSLog(@"<Dionysos> Command execution cancelled by user.\n");
	} else { // 1 or anything else. How do we get the last command output? 
		NSLog(@"<Dionysos> Command execution failed with rc %d.\n", rc);
	}

	NSLog(@"<Dionysos> END ---------------------------------------------------------------->");

    return rc;
}

-(int)mergeVideo:(NSString *)videoFilename withAudio:(NSString *)audioFilename out:(NSString *)outputFilename {
	NSLog(@"<Dionysos> merging - video: %@ - audio: %@", videoFilename, audioFilename);

	if ([videoFilename rangeOfString:@"mp4"].location != NSNotFound) {
		outputFilename = [NSString stringWithFormat:@"%@.mp4", outputFilename];
	} else if ([videoFilename rangeOfString:@"webm"].location != NSNotFound) {
		outputFilename = [NSString stringWithFormat:@"%@.mkv", outputFilename];
	} else {
		return -1;
	}

	NSArray *arguments = @[
		@"-loglevel",
		@"error",
		@"-strict",
		@"experimental",
		@"-i",
		videoFilename,
		@"-i",
		audioFilename,
		@"-c:v",
		@"copy",
		@"-c:a",
		@"copy",
		outputFilename
	];

	NSLog(@"<Dionysos> executing > %@", arguments);
    int rc = [MobileFFmpeg executeWithArguments:arguments];
	NSLog(@"<Dionysos> rc %d", rc);

	if (rc == RETURN_CODE_SUCCESS) { // 0
		NSLog(@"<Dionysos> Command execution completed successfully.\n");
	} else if (rc == RETURN_CODE_CANCEL) { // TODO: dunno yet, probably 2 (?)
		NSLog(@"<Dionysos> Command execution cancelled by user.\n");
	} else { // 1 or anything else. How do we get the last command output? 
		NSLog(@"<Dionysos> Command execution failed with rc %d.\n", rc);
	}
	
	// TODO: shall we delete them here? 
	NSError *error = nil;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:videoFilename error:&error];
	[fileManager removeItemAtPath:audioFilename error:&error];

	NSLog(@"Deleted single audio and video file %@", error);

	NSLog(@"<Dionysos> END ---------------------------------------------------------------->");

    return rc;
}
@end