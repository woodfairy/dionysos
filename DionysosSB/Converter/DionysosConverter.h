#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <GameController/GameController.h>
#import <VideoToolbox/VideoToolbox.h>
#import <Accelerate/Accelerate.h>
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AvFoundation/AvFoundation.h>
#import <MobileFFmpegConfig.h>
#import <MobileFFmpeg.h>
#import <UIKit/UIKit.h>

@interface DionysosConverter : NSObject
-(int)convertVideo:(NSString *)source toAudio:(NSString *)target;
-(int)mergeVideo:(NSString *)videoFilename withAudio:(NSString *)audioFilename out:(NSString *)outputFilename;
-(int)convertMkv:(NSString *)videoFilename to:(NSString *) format;
-(int)ffmpegWithArguments:(NSArray *)arguments;
-(void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo;
@end