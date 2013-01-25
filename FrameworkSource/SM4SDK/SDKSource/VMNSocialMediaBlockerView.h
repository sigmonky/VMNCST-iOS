#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VMNSocialMediaBlockerView : NSObject {
}

+ (id)sharedBlocker;
- (void)releaseMemory;

//UIBlocker 
- (void)blockUI;
- (void)blockFrame:(CGRect)frame;
- (void)blockView:(UIView *)view;
- (void)unblockUI;
- (BOOL)uiIsBlocked;
- (void)blockSpinerEnabled:(BOOL)newValue;
- (void)blockTextEnabled:(BOOL)newValue;
- (void)setBlockText:(NSString *)text;
@property(nonatomic,retain) UIColor* blockColor;
@property(nonatomic,assign) float blockAlpha;


//ModalBlocker
- (void)showModalViewWithView:(UIView *)view;
- (void)showModalViewWithView:(UIView *)view target:(id)target andCallback:(SEL)callback;
- (void)hideModalView;
@property(nonatomic,retain) UIColor* modalViewBGColor;
@property(nonatomic,assign) float modalViewBGAlpha;

@end