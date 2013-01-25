#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VMNSocialMediaModalBlocker : NSObject {
	UIButton *backgroundView;
	UIView *view;
	UIView *baseView;
	SEL action;
	id target;
	
	UIColor* bgColor;
	float bgAlpha;
}
@property(nonatomic,retain,setter=setBGColor:) UIColor* bgColor;
@property(nonatomic,assign,setter=setBGAlpha:) float bgAlpha;

+ (id)sharedModalBlocker;

- (void)showView:(UIView*)_view withTarged:(id)_target andAction:(SEL)_action;

//- (void)performActionOnClosing;
- (void) backgroundTouched;

- (void)close;

@end
