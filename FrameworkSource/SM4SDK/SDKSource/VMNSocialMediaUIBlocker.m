#import "VMNSocialMediaUIBlocker.h"

#define DEFAULT_INDICATOR_SIZE 50
#define DEFAULT_TEXT_WIDTH 200
#define DEFAULT_TEXT_HEIGHT 40


@implementation VMNSocialMediaUIBlocker
@synthesize isActive;
@synthesize baseView, view;

static VMNSocialMediaUIBlocker *sharedUIBlocker = nil;

+ (id)sharedUIBlocker {
    @synchronized(self) {
        if(sharedUIBlocker == nil)
            sharedUIBlocker = [[[VMNSocialMediaUIBlocker alloc] init] retain];
    }
    return sharedUIBlocker;
}

- (id)init{
	self = [super init];
	self.baseView = [[UIApplication sharedApplication] keyWindow];
	view = [[UIView alloc] initWithFrame:baseView.frame];
	view.opaque = YES;
	
	self.blockTextEnabled = NO;
	self.blockSpinnerEnabled = YES;
	self.blockColor = [UIColor grayColor];
	self.blockAlpha = 0.5f;
	
	isActive = NO;
	
	return self;
}

- (id)initWitBaseView:(UIView *)_baseView andColor:(UIColor *)_color{
	self = [self init];
	self.baseView = _baseView;
	view.frame = self.baseView.frame;
	view.backgroundColor = _color;
	
	return self;
}

- (void)showBlockView{
	if (isActive) {
		[self hideBlockView];
	}
	self.baseView = [[UIApplication sharedApplication] keyWindow];
	[baseView addSubview:view];
	[view setFrame:baseView.frame];
	if(blockSpinnerEnabled){
		[self updateSpinnerFrame];
		[spinner startAnimating];
	}
	isActive = YES;
}

- (void)showBlockViewWithFrame:(CGRect)frame{
	if (isActive) {
		[self hideBlockView];
	}
	self.baseView = [[UIApplication sharedApplication] keyWindow];
	[baseView addSubview:view];
	[view setFrame: frame];
	if(blockSpinnerEnabled){
		[self updateSpinnerFrame];
		[spinner startAnimating];
	}
	isActive = YES;
}

- (void)showBlockViewForView:(UIView *)_view {
	if (isActive) {
		[self hideBlockView];
	}
	self.baseView = _view;
	[baseView addSubview:view];
	[view setFrame:_view.bounds];
	if(blockSpinnerEnabled){
		[self updateSpinnerFrame];
		[spinner startAnimating];
	}
	isActive = YES;
}

- (void)hideBlockView{
	self.baseView = nil;
	[view removeFromSuperview];
	isActive = NO;
}

- (void)setColor:(UIColor *)newColor{
	view.backgroundColor = newColor;
}

#pragma mark -
#pragma mark Text Message
- (void)setBlockTextEnabled:(BOOL)newValue{
	if(newValue != blockTextEnabled){
		if (newValue) {
			if (textLabel == nil) {
				textLabel = [[UILabel alloc] initWithFrame:[self textFrameWithViewFrame:view.frame]];
				textLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0f];
				textLabel.textColor = [UIColor whiteColor];
				textLabel.font = [UIFont boldSystemFontOfSize:24];
				textLabel.adjustsFontSizeToFitWidth = YES;
				textLabel.textAlignment = UITextAlignmentCenter;
			}
			
			[self updateSpinnerFrame];
			[view addSubview:textLabel];
			
		}
		else {
			[spinner stopAnimating];
			[spinner removeFromSuperview];
		}
		blockSpinnerEnabled = newValue;
	}
}

- (CGRect)textFrameWithViewFrame:(CGRect)viewFrame{
	return CGRectMake((viewFrame.size.width - DEFAULT_TEXT_WIDTH)/ 2,
					  (viewFrame.size.height - DEFAULT_TEXT_HEIGHT)/ 2 - DEFAULT_INDICATOR_SIZE * 1.5f,
					  DEFAULT_TEXT_WIDTH, 
					  DEFAULT_TEXT_HEIGHT);
}

- (void)updateTextFrame{
	textLabel.frame = [self textFrameWithViewFrame:view.frame];
}

- (void)setText:(NSString *)textMessage{
	textLabel.text = textMessage;
}

- (BOOL)blockTextEnabled{
	return blockTextEnabled;
}

#pragma mark -
#pragma mark Spinner
- (void)setBlockSpinnerEnabled:(BOOL)newValue{
	if(newValue != blockSpinnerEnabled){
		if (newValue) {
			if (spinner == nil) {
				spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
						   UIActivityIndicatorViewStyleWhiteLarge];
			}

			[self updateSpinnerFrame];
			[view addSubview:spinner];
			
		}
		else {
			[spinner stopAnimating];
			[spinner removeFromSuperview];
		}
		blockSpinnerEnabled = newValue;
	}
}

- (void)updateSpinnerFrame{
	spinner.frame = [self spinnerFrameWithViewFrame:view.frame];
}

- (CGRect)spinnerFrameWithViewFrame:(CGRect)viewFrame{
	return CGRectMake((viewFrame.size.width - DEFAULT_INDICATOR_SIZE)/ 2,
									 (viewFrame.size.height - DEFAULT_INDICATOR_SIZE)/ 2,
									 DEFAULT_INDICATOR_SIZE, 
									 DEFAULT_INDICATOR_SIZE);
}

- (BOOL)blockSpinnerEnabled{
	return blockSpinnerEnabled;
}

- (void)setBlockColor:(UIColor *)newColor{
	blockColor = newColor;
	view.backgroundColor = blockColor;
}

- (UIColor*)blockColor{
	return self.blockColor;
}

- (void)setBlockAlpha:(float)newAlpha{
	blockAlpha = newAlpha;
	view.alpha = blockAlpha;
}

- (float)blockAlpha{
	return blockAlpha;
}

#pragma mark -
#pragma mark memory
- (void)releaseMemory{
	[sharedUIBlocker release];
	sharedUIBlocker = nil;
}

- (void)dealloc{
	[sharedUIBlocker release];
	[view release];
	[super dealloc];
}


@end
