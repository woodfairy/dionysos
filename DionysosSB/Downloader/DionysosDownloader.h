#import <Foundation/Foundation.h>
#import "../../shared/NSTask.h"


@interface DionysosDownloader : NSObject
-(NSString*) download:(NSString* )url format:(NSString *)format destination:(NSString *)dest;
-(NSString *) getFilename:(NSString *)url format:(NSString *)format;
@end