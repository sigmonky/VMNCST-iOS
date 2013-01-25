#import "VMNSocialMediaBlockerView.h"
#import "VMNSocialMediaUIBlocker.h"
#import "VMNSocialMediaModalBlocker.h"


@implementation VMNSocialMediaBlockerView

static VMNSocialMediaBlockerView *sharedBlocker = nil;

#pragma mark -
#pragma mark Singleton methods
+ (id)sharedBlocker {
    @synchronized(self) {
        if(sharedBlocker == nil)
            sharedBlocker = [[super allocWithZone:NULL] init];
    }
    return sharedBlocker;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedBlocker] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX; //denotes an object that cannot be released
}

- (void)release {
    // never release
}

- (id)autorelease {
    return self;
}

- (id)init {
    if (self = [super init]) {

    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
    [super dealloc];
}


- (void)releaseMemory{
	[[VMNSocialMediaUIBlocker sharedUIBlocker] releaseMemory];
}

#pragma mark -
#pragma mark Simple Block Methods

- (void)blockUI{
	[[VMNSocialMediaUIBlocker sharedUIBlocker] showBlockView];
}

- (void)blockFrame:(CGRect)frame{
	[[VMNSocialMediaUIBlocker sharedUIBlocker] showBlockViewWithFrame:frame];
}

- (void)blockView:(UIView *)view {
	[[VMNSocialMediaUIBlocker sharedUIBlocker] showBlockViewForView:view];
}

- (void)unblockUI{
	[[VMNSocialMediaUIBlocker sharedUIBlocker] hideBlockView];
}

- (BOOL)uiIsBlocked{
	return [[VMNSocialMediaUIBlocker sharedUIBlocker] isActive];
}

- (void)blockSpinerEnabled:(BOOL)newValue{
	[[VMNSocialMediaUIBlocker sharedUIBlocker] setBlockSpinnerEnabled:newValue];
}

- (void)blockTextEnabled:(BOOL)newValue{
	[[VMNSocialMediaUIBlocker sharedUIBlocker] setBlockTextEnabled:newValue];
}

- (void)setBlockText:(NSString *)text{
	[[VMNSocialMediaUIBlocker sharedUIBlocker] setText:text];
}

- (void)setBlockColor:(UIColor *)newColor{
	[[VMNSocialMediaUIBlocker sharedUIBlocker] setBlockColor:newColor];
}

- (UIColor*)blockColor{
	return [[VMNSocialMediaUIBlocker sharedUIBlocker] blockColor];
}

- (void)setBlockAlpha:(float)newAlpha{
	[[VMNSocialMediaUIBlocker sharedUIBlocker] setBlockAlpha:newAlpha];
}

- (float)blockAlpha{
	return [[VMNSocialMediaUIBlocker sharedUIBlocker] blockAlpha];
}

#pragma mark -
#pragma mark Modal View Block Methods

- (void)showModalViewWithView:(UIView *)view{
	[[VMNSocialMediaModalBlocker sharedModalBlocker] showView:view withTarged:nil andAction:nil];
}

- (void)showModalViewWithView:(UIView *)view target:(id)target andCallback:(SEL)callback{
	[[VMNSocialMediaModalBlocker sharedModalBlocker] showView:view withTarged:target andAction:callback];
}

- (void)hideModalView{
	[[VMNSocialMediaModalBlocker sharedModalBlocker] close];
}

- (void)setModalViewBGColor:(UIColor *)newColor{
	[[VMNSocialMediaModalBlocker sharedModalBlocker] setBGColor:newColor];
}

- (UIColor*)modalViewBGColor{
	return [[VMNSocialMediaModalBlocker sharedModalBlocker] bgColor];
}

- (void)setModalViewBGAlpha:(float)newAlpha{
	[[VMNSocialMediaModalBlocker sharedModalBlocker] setBGAlpha:newAlpha];
}

- (float)modalViewBGAlpha{
	return [[VMNSocialMediaModalBlocker sharedModalBlocker] bgAlpha];
}

@end
