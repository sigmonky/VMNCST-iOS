#import <UIKit/UIKit.h>
@class VMNSocialMediaBrowserView;

@protocol VMNSocialMediaBrowserViewDelegate
- (void)closeBrowser:(VMNSocialMediaBrowserView *)browserView;
@end


@interface VMNSocialMediaBrowserView : UIView <UIWebViewDelegate> {
	
}

- (id)initWithFrame:(CGRect)frame url:(NSURL *)url delegate:(id<VMNSocialMediaBrowserViewDelegate>)delegate;
- (void)setTitle:(NSString *)title;
- (void)setColor:(UIColor *)color;

@end
