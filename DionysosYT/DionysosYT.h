#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MRYIPCCenter.h>

@interface YTPlayerViewController
-(id)contentVideoID;
@end

@interface YTSlimVideoDetailsActionView : UIView
-(void)didTapButton:(id)arg1;
-(id)visibilityDelegate;
-(id)label;
@end

@interface YTISlimVideoInformationRenderer : NSObject
-(void)setTitle:(id)title;
-(id)title;
@end

@interface YTIFormattedString : NSString
-(id)dropdownOptionTitle;
@end

@interface YTSlimVideoScrollableDetailsActionView : UIView
-(id)offlineActionView;
@end