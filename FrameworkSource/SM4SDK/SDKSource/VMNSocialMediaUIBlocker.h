#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VMNSocialMediaUIBlocker : NSObject {
	UIView *view;
	UIView *baseView;
	UILabel *textLabel;
	UIActivityIndicatorView *spinner;
	
	BOOL isActive;
	BOOL blockSpinnerEnabled;
	BOOL blockTextEnabled;
	UIColor* blockColor;
	float blockAlpha;
}

@property(nonatomic,readonly,assign) BOOL isActive;
@property(nonatomic,assign) BOOL blockSpinnerEnabled;
@property(nonatomic,assign) BOOL blockTextEnabled;
@property(nonatomic,retain) UIView *baseView;
@property(nonatomic,retain) UIView *view;
@property(nonatomic,retain) UIColor* blockColor;
@property(nonatomic,assign) float blockAlpha;


+ (VMNSocialMediaUIBlocker *)sharedUIBlocker;
- (id)init;
- (id)initWitBaseView:(UIView *)_baseView andColor:(UIColor *)_color;
- (CGRect)spinnerFrameWithViewFrame:(CGRect)viewFrame;
- (void)setBlockSpinnerEnabled:(BOOL)newValue;

- (void)setText:(NSString *)textMessage;
- (void)setBlockTextEnabled:(BOOL)newValue;
- (CGRect)textFrameWithViewFrame:(CGRect)viewFrame;

- (void)showBlockView;
- (void)showBlockViewWithFrame:(CGRect)frame;
- (void)showBlockViewForView:(UIView *)_view;
- (void)hideBlockView;
- (void)updateSpinnerFrame;

- (void)releaseMemory;

@end
