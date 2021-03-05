#import <Foundation/Foundation.h>
#import "../../shared/NSTask.h"


@interface DionysosDownloader : NSObject
-(NSString*)downloadFrom:(NSString* )url destination:(NSString *) dest;
@end