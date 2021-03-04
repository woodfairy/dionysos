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

@interface DionysosConverter : NSObject
-(int)convertToMp3:(NSString *)source forTarget:(NSString *)target;
@end