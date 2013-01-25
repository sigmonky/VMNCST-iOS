#import "VMNSocialMediaBrowserView.h"
#import "VMNSocialMediaBlockerView.h"

@interface VMNSocialMediaBrowserView()

- (CGContextRef)createContext;
- (UIImage *)imageRefBack;
- (UIImage *)imageRefForw;
- (void) dropUrlCache;
- (BOOL) isiPad;
@property(nonatomic, retain)UIWebView *webView;
@property(nonatomic, retain)UIBarButtonItem *backItem;
@property(nonatomic, retain)UIBarButtonItem *forwItem;
@property(nonatomic, retain)UIBarButtonItem *topTitleItem;
@property(nonatomic, retain)UIToolbar *toolBarTop;
@property(nonatomic, retain)UIToolbar *bottomToolBar;
@property(nonatomic, assign)id<VMNSocialMediaBrowserViewDelegate> delegate;
@end

@implementation VMNSocialMediaBrowserView

bool overrideTitle = NO;

@synthesize webView, backItem, forwItem, topTitleItem, toolBarTop, bottomToolBar, delegate;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame url:(NSURL *)url delegate:(id<VMNSocialMediaBrowserViewDelegate>) delegate_{
	if ([self initWithFrame:frame]) {
		self.delegate = delegate_;
		self.autoresizesSubviews = YES;
		
		// tool bar top
		self.toolBarTop = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,frame.size.width,44)];
		self.toolBarTop.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.topTitleItem = [[UIBarButtonItem alloc] initWithTitle:@"Loading" style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.topTitleItem setWidth:frame.size.width - 110];
		UIBarButtonItem *topLeftSpace2Item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem *topDoneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStylePlain target:self action:@selector(action_Done:)];
		UIBarButtonItem *topLeftSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
		topLeftSpaceItem.width = 50;
		self.toolBarTop.items = [NSArray arrayWithObjects:topLeftSpaceItem,topLeftSpace2Item, self.topTitleItem,topLeftSpace2Item, topDoneItem,nil];
		
		[topTitleItem release];
		[topLeftSpace2Item release];
		[topDoneItem release];
		[topLeftSpaceItem release];
		
		[self addSubview:self.toolBarTop];
		[toolBarTop release];
		
		// webView		
		self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, frame.size.width, frame.size.height - 44 - 44)];
		[self.webView release];
		self.webView.delegate = self;
		
		[self.webView loadRequest:[NSURLRequest requestWithURL:url]];
		self.webView.scalesPageToFit = YES;
		[self addSubview:self.webView];
		
		
		// tool bar	bottom
		self.bottomToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,frame.size.height-44,frame.size.width,44)];
		
		self.bottomToolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		UIBarButtonItem *bottomLeftSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
		self.backItem = [[UIBarButtonItem alloc] initWithImage:[self imageRefBack] style:UIBarButtonItemStylePlain target:self action:@selector(action_Back:)];
		[self.backItem release];
		[self.backItem setEnabled:NO];
		UIBarButtonItem *bottomNavSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
		self.forwItem = [[UIBarButtonItem alloc] initWithImage:[self imageRefForw] style:UIBarButtonItemStylePlain target:self action:@selector(action_Forw:)];
		[self.forwItem release];
		[self.forwItem setEnabled:NO];
		UIBarButtonItem *bottomRightSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem *refrItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(action_Refresh:)];
		[bottomLeftSpaceItem setWidth:25];
		[bottomNavSpaceItem setWidth:40];
		
		self.bottomToolBar.items = [NSArray arrayWithObjects:bottomLeftSpaceItem,bottomRightSpaceItem,self.backItem,bottomNavSpaceItem,self.forwItem,bottomRightSpaceItem,refrItem,nil];
		[self addSubview:self.bottomToolBar];
		
		[refrItem release];
		[bottomRightSpaceItem release];
		[bottomNavSpaceItem release];
		[bottomLeftSpaceItem release];
		[bottomToolBar release];
		
		
		
	}
	return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code.
 }
 */


#pragma mark -
#pragma mark UIWebViewDelegate
- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error{
	if ([error code] == NSURLErrorNotConnectedToInternet) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Check your Internet connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
	else {
		if (([error code] !=   NSURLErrorCancelled) && ([error code] !=   204)
			&& !(error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"])) {
			
			
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alertView show];
			[alertView release];
		}
	}
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)req navigationType:(UIWebViewNavigationType)navigationType {
	NSLog(@"LINK = %@",[[req URL] absoluteString]);
    // Determine if we want the system to handle it.
    NSURL *turl = req.URL;

	NSRange range = [req.URL.absoluteString rangeOfString:@"http://itunes.apple.com" options:NSCaseInsensitiveSearch];
	if (range.location != NSNotFound) {
		[[UIApplication sharedApplication] openURL:turl];
		return NO;
	}
	
	if (![turl.scheme isEqual:@"http"] && ![turl.scheme isEqual:@"https"]) {
        if ([[UIApplication sharedApplication]canOpenURL:turl]) {
            [[UIApplication sharedApplication]openURL:turl];
            return NO;
        }
    }
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    return YES; 
}

- (void)webViewDidFinishLoad:(UIWebView *)webView_{
	
	[self.backItem setEnabled:[webView_ canGoBack]];
	[self.forwItem setEnabled:[webView_ canGoForward]];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (!overrideTitle)
        self.topTitleItem.title = [[NSString alloc] initWithString:[webView stringByEvaluatingJavaScriptFromString:@"document.title"]];
	
	NSString *jsCommand;
	float coef = self.bounds.size.width / 320;
	jsCommand = [NSString stringWithFormat:@"document.body.style.zoom = %F;",coef];
	
	[self.webView stringByEvaluatingJavaScriptFromString:jsCommand];
	
	[self dropUrlCache];
	[[VMNSocialMediaBlockerView sharedBlocker] unblockUI];
}

- (void)webViewDidStartLoad:(UIWebView *)aWebView{
	[[VMNSocialMediaBlockerView sharedBlocker] blockView:self.webView];
}

#pragma mark - browser button
- (CGContextRef)createContext{
	// create the bitmap context
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(nil,27,27,8,0,
												 colorSpace,kCGImageAlphaPremultipliedLast);
	CFRelease(colorSpace);
	return context;
}

- (UIImage *)imageRefBack{
	CGContextRef context = [self createContext];
	
	// set the fill color
	CGColorRef fillColor = [[UIColor blackColor] CGColor];
	CGContextSetFillColor(context, CGColorGetComponents(fillColor));
	
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 8.0f, 12.0f);
	CGContextAddLineToPoint(context, 24.0f, 3.0f);
	CGContextAddLineToPoint(context, 24.0f, 21.0f);
	CGContextClosePath(context);
	CGContextFillPath(context);
	
	// convert the context into a CGImageRef
	CGImageRef image = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	UIImage *res = [[[UIImage alloc] initWithCGImage:image] autorelease];
	CGContextRelease((CGContextRef)image);
	
	return res;
	
}

- (UIImage *)imageRefForw{
	CGContextRef context = [self createContext];
	
	// set the fill color
	CGColorRef fillColor = [[UIColor blackColor] CGColor];
	CGContextSetFillColor(context, CGColorGetComponents(fillColor));
	
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 8.0f, 3.0f);
	CGContextAddLineToPoint(context, 24.0f, 12.0f);
	CGContextAddLineToPoint(context, 8.0f, 21.0f);
	CGContextClosePath(context);
	CGContextFillPath(context);
	
	// convert the context into a CGImageRef
	CGImageRef image = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	UIImage *res = [[[UIImage alloc] initWithCGImage:image] autorelease];
	CGContextRelease((CGContextRef)image);
	
	return res;
}

#pragma mark -
#pragma mark actions

- (void)action_Done:(id)sender{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[[VMNSocialMediaBlockerView sharedBlocker] unblockUI];
	[self.delegate closeBrowser:self];
}

- (void)action_Forw:(id)sender{
	[self.backItem setEnabled:[self.webView canGoBack]];
	[self.webView goForward];
}

- (void)action_Back:(id)sender{
	[self.forwItem setEnabled:[self.webView canGoForward]];
	[self.webView goBack];
}

- (void)action_Refresh:(id)sender{
	[self.webView reload];
}

#pragma mark _____
- (BOOL) isiPad {
#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 30200)
	if ([[UIDevice currentDevice] respondsToSelector: @selector(userInterfaceIdiom)])
		return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);
#endif
	return NO;
}

- (void) dropUrlCache {
	NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
	[NSURLCache setSharedURLCache:sharedCache];
	[sharedCache release];
}

-(void) layoutSubviews {
	[super layoutSubviews];
	self.webView.frame = CGRectMake(0, 44, self.bounds.size.width, self.bounds.size.height - 44 - 44);
	NSString *jsCommand;
	float coef = self.bounds.size.width / 320;
	jsCommand = [NSString stringWithFormat:@"document.body.style.zoom = %F;",coef];
	[self.webView stringByEvaluatingJavaScriptFromString:jsCommand];
	if ([[VMNSocialMediaBlockerView sharedBlocker] uiIsBlocked]){
		[[VMNSocialMediaBlockerView sharedBlocker] unblockUI];
		[[VMNSocialMediaBlockerView sharedBlocker] blockView:self.webView];
	}
}

- (void)dealloc {
	self.webView.delegate = nil;
	self.webView = nil;
	self.backItem = nil;
	self.forwItem = nil;
    [super dealloc];
}

#pragma mark settings
- (void)setTitle:(NSString *)title {
	self.topTitleItem.title = title;
    overrideTitle = YES;
}

- (void)setColor:(UIColor *)color {
	self.toolBarTop.barStyle =  UIBarStyleBlackTranslucent;
	self.toolBarTop.tintColor = color;
	
	self.bottomToolBar.barStyle =  UIBarStyleBlackTranslucent;
	self.bottomToolBar.tintColor = color;
}

@end
