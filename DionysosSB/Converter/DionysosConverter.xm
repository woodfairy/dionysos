#import "DionysosConverter.h"

@implementation DionysosConverter
-(int)convertVideo:(NSString *)source toAudio:(NSString *)dest {
	NSLog(@"<Dionysos> convertToMp3 - source: %@ - dest: %@", source, dest);
	NSArray *arguments = @[@"-y", @"-i", source, @"-q:a", @"0", @"-map", @"a", dest];
	return [self ffmpegWithArguments:arguments];
}

-(int)mergeVideo:(NSString *)videoFilename withAudio:(NSString *)audioFilename out:(NSString *)outputFilename {
	NSLog(@"<Dionysos> merging - video: %@ - audio: %@", videoFilename, audioFilename);

	BOOL outputIsMkv = NO;

	if ([videoFilename rangeOfString:@"mp4"].location != NSNotFound) {
		outputFilename = [NSString stringWithFormat:@"%@.mp4", outputFilename];
	} else if ([videoFilename rangeOfString:@"webm"].location != NSNotFound) {
		outputFilename = [NSString stringWithFormat:@"%@.mkv", outputFilename];
		outputIsMkv = YES;
	} else {
		return -1;
	}

	NSArray *arguments = @[
		@"-y",
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
		@"aac",
		outputFilename
	];

	int rc = [self ffmpegWithArguments:arguments];
	
	// TODO: shall we delete them here? 
	NSError *error = nil;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:videoFilename error:&error];
	[fileManager removeItemAtPath:audioFilename error:&error];
	NSLog(@"Deleted single audio and video file %@", error);
	if (outputIsMkv && rc == RETURN_CODE_SUCCESS) {
		[self convertMkv:outputFilename to:@".mp4"];
		UISaveVideoAtPathToSavedPhotosAlbum([outputFilename stringByReplacingOccurrencesOfString:@".mkv" withString:@".mp4"], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
		[fileManager removeItemAtPath:outputFilename error:&error];
	} else {
		UISaveVideoAtPathToSavedPhotosAlbum(outputFilename, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
	}

	
    return rc;
}

-(int)convertMkv:(NSString *)videoFilename to:(NSString *) format {
	NSLog(@"<Dionysos> converting: %@ to: %@", videoFilename, format);

	NSArray *arguments = @[
		@"-y",
		@"-loglevel",
		@"error",
		@"-threads",
		@"1",
		@"-strict",
		@"experimental",
		@"-i",
		videoFilename,
		@"-map",
		@"0",
		@"-preset",
		@"ultrafast",
		@"-c:v",
		@"libx264",
		@"-c:a",
		@"copy",
		
		[videoFilename stringByReplacingOccurrencesOfString:@".mkv" withString:format]
	];

	return [self ffmpegWithArguments:arguments];
}

-(int)ffmpegWithArguments:(NSArray *)arguments {
	NSLog(@"<Dionysos> <ffmpeg> executing > %@", arguments);
    int rc = [MobileFFmpeg executeWithArguments:arguments];
	NSLog(@"<Dionysos> <ffmpeg> executed");
	if (rc == RETURN_CODE_SUCCESS) { // 0
		NSLog(@"<Dionysos> ffmpeg execution completed successfully.\n");
	} else if (rc == RETURN_CODE_CANCEL) { // TODO: dunno yet, probably 2 (?)
		NSLog(@"<Dionysos> ffmpeg execution cancelled by user.\n");
	} else { // 1 or anything else. How do we get the last command output? 
		NSLog(@"<Dionysos> ffmpeg failed with rc %d.\n", rc);
	}

	return rc;
}

- (void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    if (error) {
        NSLog(@"<DionsosSB> Saving to camera roll failed!");
    } else {
		NSLog(@"<DionysosSB> Saving to camera roll succesful!");
    }
}
@end