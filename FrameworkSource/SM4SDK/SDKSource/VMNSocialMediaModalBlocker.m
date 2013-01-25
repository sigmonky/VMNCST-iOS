#import "VMNSocialMediaModalBlocker.h"


@implementation VMNSocialMediaModalBlocker

static VMNSocialMediaModalBlocker* sharedModalBlocker = nil;

+ (id)sharedModalBlocker {
    @synchronized(self) {
        if(sharedModalBlocker == nil)
            sharedModalBlocker = [[[VMNSocialMediaModalBlocker alloc] init] retain];
    }
    return sharedModalBlocker;
}

- (id)init{
	self = [super init];
	
	view = nil;
	target = nil;
	action = nil;
	
	baseView = [[UIApplication sharedApplication] keyWindow];	
	backgroundView = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	backgroundView.frame = baseView.frame;
	self.bgColor = [UIColor grayColor];
	self.bgAlpha = 0.1f;
	backgroundView.opaque = YES;
	//[backgroundView addTarget:self action:@selector(performActionOnClosing) forControlEvents:UIControlEventTouchUpInside];
	[backgroundView addTarget:self action:@selector(backgroundTouched) forControlEvents:UIControlEventTouchUpInside];
	
	[backgroundView addSubview:view];
	
	return self;
}

- (void)showView:(UIView*)_view withTarged:(id)_target andAction:(SEL)_action{
	view = _view;
	target = _target;
	action = _action;
	
	[backgroundView addSubview:view];
	[baseView addSubview:backgroundView];
}

- (void) backgroundTouched {
	if([target respondsToSelector:action])
	{
		[target performSelector:action];
	}
}

- (void) close {
	[view removeFromSuperview];
	view = nil;
	target = nil;
	action = nil;
	[backgroundView removeFromSuperview];
}

/*- (void)performActionOnClosing{
	if([target respondsToSelector:action])
	{
		[target performSelector:action];
	}
	[view removeFromSuperview];
	[backgroundView removeFromSuperview];
}*/

/*- (void)close{
	[self performActionOnClosing];
}*/

- (void)setBGColor:(UIColor *)newColor{
	bgColor = [newColor colorWithAlphaComponent:bgAlpha];
	backgroundView.backgroundColor = bgColor;
}

- (UIColor*)bgColor{
	return bgColor;
}

- (void)setBGAlpha:(float)newAlpha{
	bgAlpha = newAlpha;
	backgroundView.backgroundColor = [bgColor colorWithAlphaComponent:bgAlpha];
}

- (float)bgAlpha{
	return bgAlpha;
}

#pragma mark -
#pragma mark Memory management
- (void)releaseMemory{
	[sharedModalBlocker release];
	sharedModalBlocker = nil;
}

- (void)dealloc{
	[sharedModalBlocker release];
	[backgroundView release];
	[super dealloc];
}

@end
