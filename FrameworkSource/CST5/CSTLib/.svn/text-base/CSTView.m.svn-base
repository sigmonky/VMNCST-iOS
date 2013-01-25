/**
 
 Abstract: WebView Subclass that manages the CST panel lifecycle.
 
 Version: 1.2
 
 */


#import "CSTView.h"
#import "PKAppDetection.h"

#define CST_HOST @"mtvnmobile.mtvnservices.com"
#define CST_URL @"http://mtvnmobile.mtvnservices-d.mtvi.com/cst/5/"
//#define CST_URL @"http://166.77.206.220:8888/mobileapps/cst/5/"
#define WRAPPER_VERSION @"1.2"

@implementation UINavigationBar (BackgroundImage)
//This overridden implementation will patch up the NavBar with a custom Image instead of the title
- (void)drawRect:(CGRect)rect {
    UIImage *image = [UIImage imageNamed: @"headerBackground.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, 44.0)];
}
@end



@implementation CSTView


@synthesize mGid;
@synthesize platform;
@synthesize aWebView;
@synthesize config;
@synthesize currentUrl;
@synthesize appName;
@synthesize activityIndicator;
@synthesize aViewReference;
@synthesize paramsDictionary;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [appName release];
    appName = nil;
    
    aViewReference = nil;
    
    activityIndicator = nil;
    
    [currentUrl release];
    
    [config release];
    config = nil;
    
    [aWebView release];
    aWebView = nil;
    
    [mGid release];
    mGid = nil;
    
    [platform release];
    platform = nil;
    
    [hostReach release];
    hostReach = nil;
    
    [paramsDictionary release];
    paramsDictionary = nil;
    
    [super dealloc];
}

#pragma mark - View lifecycle


- (id)initWithFrame:(CGRect)frame forMgid:(NSString *)mgid forPlatform:(NSString *)platformVals inFullScreenMode:(BOOL)fullScreen inView:(UIView *)aView paramsList:( NSMutableDictionary *)params;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.mGid = mgid;
        self.platform = platformVals;
        isFullScreen = fullScreen;
        aViewReference = aView;
        siteChecked = NO;
        self.paramsDictionary = params;
        [self setup];
    }
    return self;
}



/**
 CST Class Method that is called from the view in order insert a CST Panel into the view stack.
 */
+ (CSTView *)showCSTInView:(UIView *)view forMgid:(NSString *)mgid forPlatform:(NSString *)platform inFullScreenMode:(BOOL)fullScreen paramsList:(NSMutableDictionary*)params {
    CSTView *panel = [CSTView cstPanel:mgid forPlatform:(NSString *)platform inFullScreenMode:fullScreen inView:view paramsList:(NSMutableDictionary *)params];
    UIDevice *device = [UIDevice currentDevice];
    [device beginGeneratingDeviceOrientationNotifications];
    
        
    if (fullScreen == false){
        
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIDeviceOrientationLandscapeLeft:
            case UIDeviceOrientationLandscapeRight:
                panel.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
                [params setObject:@"landscape" forKey:@"orientation"];
                break;
            case UIDeviceOrientationPortrait:
            case UIDeviceOrientationPortraitUpsideDown:
                panel.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
                [params setObject:@"portrait" forKey:@"orientation"];
                break;
        }
        
    }else{
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIDeviceOrientationLandscapeLeft:
            case UIDeviceOrientationLandscapeRight:
                [params setObject:@"landscape" forKey:@"orientation"];
                break;
            case UIDeviceOrientationPortrait:
            case UIDeviceOrientationPortraitUpsideDown:
                [params setObject:@"portrait" forKey:@"orientation"];
                break;
        }
        panel.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
    }
    
    [view addSubview:panel];
    return nil;
}

/**
 Method that returns an instance of the CST Panel
 */
+(CSTView *)cstPanel:(NSString *)mgid forPlatform:(NSString *)platform inFullScreenMode:(BOOL)fullScreen inView:(UIView *)aView paramsList:(NSMutableDictionary *)params {
    
    CGFloat screenWidth = aView.bounds.size.width;
    CGFloat screenHeight = aView.bounds.size.height;
    
    if (fullScreen){
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIDeviceOrientationLandscapeLeft:
            case UIDeviceOrientationLandscapeRight:
                screenWidth = aView.bounds.size.height;
                screenHeight = aView.bounds.size.width;
                break;
            case UIDeviceOrientationPortrait:
            case UIDeviceOrientationPortraitUpsideDown:
                screenWidth = aView.bounds.size.width;
                screenHeight = aView.bounds.size.height;
                break;
        }
    }
    
    CSTView *panel = [[[CSTView alloc] initWithFrame:CGRectMake(0,0, screenWidth,screenHeight) forMgid:mgid forPlatform:platform inFullScreenMode:(BOOL)fullScreen inView:aView paramsList:params] autorelease];
    panel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    return panel;
}

/**
 Method that is called when an action is trigged from Javascript.
 */
- (void)setup {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self setupUI];
    [self setupReachability];
}

- (void) didRotate:(NSNotification *)notification
{
    if (!isFullScreen)[aViewReference removeFromSuperview];
    
    [aWebView setFrame:CGRectMake(0, 44, self.bounds.size.width, self.bounds.size.height)];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (aWebView != nil) {
        [aWebView setFrame:CGRectMake(0, 44, self.bounds.size.width, self.bounds.size.height - 44)];
    }
    if (activityIndicator != nil) {
        [activityIndicator setFrame:CGRectMake(self.bounds.size.width/2-20, self.bounds.size.height/2-20, 40.0, 40.0)];
    }
}


- (void) setupUI{
    
    //Get Config Values
    config = [self getDictionary:@"config"];
    NSString *headerBackground = [config valueForKey:@"backgroundImage"];
    NSString *imageLogo = [config valueForKey:@"logoImage"];
    NSString *closeButtonImage = [config valueForKey:@"closeButtonImage"];
    appName = [config valueForKey:@"appname"];
    if (appName == nil)appName = @"nickelodeon";
    
    //Setup Navigation Bar Background, logo and Close Button
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:
                               CGRectMake(0,0,self.bounds.size.width,44)];
    
    if ([navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        // IOS5
        [navBar setBackgroundImage:[UIImage imageNamed:headerBackground] forBarMetrics:UIBarMetricsDefault];
    }
    
    
    navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:navBar];
    
    
    aWebView = [[UIWebView alloc] init];
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            if (!isFullScreen){
                [aWebView setFrame:CGRectMake(0, 44, self.bounds.size.width, self.bounds.size.height)];
                activityIndicator.frame = CGRectMake(self.bounds.size.width/2-20, self.bounds.size.height/2-20, 40.0, 40.0);
            }else{
                [aWebView setFrame:CGRectMake(0, 44, self.bounds.size.height, self.bounds.size.width)];
                activityIndicator.frame = CGRectMake(self.bounds.size.height/2-20, self.bounds.size.width/2-20, 40.0, 40.0);
            }
            
            break;
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
            [aWebView setFrame:CGRectMake(0, 44, self.bounds.size.width, self.bounds.size.height)];
            activityIndicator.frame = CGRectMake(self.bounds.size.width/2-20, self.bounds.size.height/2-20, 40.0, 40.0);
            break;
    }
    
    
    [self addSubview:aWebView];
    [self addSubview: activityIndicator];
    [activityIndicator startAnimating];
    
    UIImage *buttonImage = [UIImage imageNamed:closeButtonImage];
    
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setImage:buttonImage forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    
    [aButton addTarget:self action:@selector(closeCSTPanel:) forControlEvents:UIControlEventTouchUpInside];
    
    UINavigationItem *item = [[UINavigationItem alloc] init];
    item.rightBarButtonItem = closeButton;
    item.hidesBackButton = YES;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageLogo]];
    item.titleView = imageView;
    [imageView release];
    
    [navBar pushNavigationItem:item animated:NO];
    [closeButton release];
    [item release];
    [navBar release];
}

- (void) setupReachability{
    // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
    // method "reachabilityChanged" will be called.
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    //Change the host name here to change the server your monitoring
	hostReach = [[Reachability reachabilityWithHostName: CST_HOST] retain];
	[hostReach startNotifier];
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateInterfaceWithReachability: curReach];
}
- (void) updateInterfaceWithReachability: (Reachability*) curReach{
    aWebView.delegate = self;
    self.opaque = NO;
    aWebView.scalesPageToFit = YES;
    UIDevice *device = [UIDevice currentDevice];
	[device beginGeneratingDeviceOrientationNotifications];
    NSString *urlAddress = @"";
    if (self.platform == nil){
        self.platform = [NSString stringWithFormat:@"iPhone,iPad"];
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.paramsDictionary 
                                            options:NSJSONWritingPrettyPrinted
                                            error:&error];
    NSString* params;
    params = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    urlAddress = [NSString stringWithFormat:@"%@index.esi?mgid=%@&platform=%@&appname=%@&wrapperversion=%@&params=%@", CST_URL, self.mGid, self.platform, self.appName,WRAPPER_VERSION,[params stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
     
    //[params release];
    //[error release];
    //[jsonData release];
    

    currentUrl = [[NSString stringWithFormat:@"%@", urlAddress] retain];
    NSLog(@"Current URL: %@",self.currentUrl);
    //Create a URL object.
    NSMutableURLRequest *requestObj;
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    if(netStatus == NotReachable){
        //        NSLog(@"not reachable");
        requestObj = [NSMutableURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"offline" ofType:@"html"]isDirectory:NO]];
        
    }else{
        NSURL *url = [NSURL URLWithString:urlAddress];
        requestObj = [NSMutableURLRequest requestWithURL:url];
    }
    [requestObj setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [requestObj setValue: @"iphone" forHTTPHeaderField: @"User-Agent"];
    [aWebView loadRequest:requestObj];
}

-(void) webViewDidFinishLoad:(UIWebView *)webView
{
     NSLog(@"web view loaded....");
    [self.activityIndicator removeFromSuperview];
    [self executeAppDetection];
}

/**
 Method that is called when an action is trigged from Javascript.
 @return Boolean value
 */
- (BOOL)webView:(UIWebView *)webView2
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *requestURL =[ [ request URL ] retain ];
    NSString *requestString = [[request URL] absoluteString];
    if (siteChecked) {
        
        if ([requestString hasPrefix:@"js-frame:"]) {
            NSArray *components = [requestString componentsSeparatedByString:@":"];
            NSString *function = (NSString*)[components objectAtIndex:1];
            NSString *argsAsString = [(NSString*)[components objectAtIndex:2] 
                                      stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [self handleCall:function arg:argsAsString];
            return NO;
        }
        if ([requestString rangeOfString:@"cst"].location == NSNotFound && [requestString rangeOfString:@"error.html"].location == NSNotFound) {
//            if ( ( [ [ requestURL scheme ] isEqualToString: @"http" ] || [ [ requestURL scheme ] isEqualToString: @"https" ] || [ [ requestURL scheme ] isEqualToString: @"mailto" ])
//                && ( navigationType == UIWebViewNavigationTypeLinkClicked ) ) {
                return ![ [ UIApplication sharedApplication ] openURL: [ requestURL autorelease ] ];
//            }
        } else
        {
            [ requestURL release ];
            return YES;
        }
    }
    
    //Checks if CST site is up and running
    NSURLConnection *conn = [NSURLConnection connectionWithRequest:request delegate:self];
    [ requestURL release ];
    if (conn == nil) {
    }
    
    // We navigate to a file url when there is an error, or we are offline
    if ([[requestURL scheme] isEqualToString: @"file" ]) {
        return YES;
    }
    
    return NO;
}

#pragma mark NSURLConnection Delegate Methods

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        siteChecked = YES;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        int status = [httpResponse statusCode];
        NSMutableURLRequest *req = [[[NSMutableURLRequest alloc]init ]autorelease];
        if (status == 500 || status == 404) {
            //            NSLog(@"request 500 or 404");
            req = [NSMutableURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                                              pathForResource:@"error" ofType:@"html"]isDirectory:NO]];
        }
        else {
            req = [NSURLRequest requestWithURL:[NSURL URLWithString:currentUrl]];
        }
        // cancel the connection. we got what we want from the response,
        // no need to download the response data.
        [connection cancel];
        // start loading the new request in webView
        [self.aWebView loadRequest:req];
    }
}


/**
 Handler for the Javascript close method.
 */
- (void)closeCST{
    if (isFullScreen){
        [self removeFromSuperview];
    }else{
        [aViewReference removeFromSuperview];
    }
    
}

/**
 Handler for the Native close method.
 */
- (void)closeCSTPanel:(id)sender{
    [self closeCST];
}

- (void)handleCall:(NSString*)functionName arg:(NSString*)arg{
    if ([functionName isEqualToString:@"close"]) {
        [self closeCST];
    }
    
    if ([functionName isEqualToString:@"executeAppDetection"]) {
        [self executeAppDetection];
    }
    
    if ([functionName isEqualToString:@"launchApp"]) {
        [self launchApp:arg];
        
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

// Get Plist config values
- (NSDictionary *)getDictionary:(NSString *)fileName {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"cst_config.plist"];
    NSDictionary *plistDictionary = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
    return plistDictionary;
} 

// TODO: refactor the code and move communication related code into Bridge class
#pragma mark - Bridge methods (refactor)

#define JS_GET_SYS_APPS @"getSysApps()"
#define JS_SET_SYS_APPS @"setSysApps('%@')"
#define APPS_SEPARATOR @","
#define JS_DID_ROTATE_TO @"didRotateTo('%@')"

// App Detection

- (NSArray *) filterInstalledApps:(NSArray *)apps {
	NSMutableArray *installedApps = [NSMutableArray array];
	for (NSString *app in apps) {
//        NSLog(@"checking for app --  %@", app);
		if ([[PKAppDetection instance] isAppInstalledWithScheme:app andIdentifier:@""]) {
			[installedApps addObject:app];
		} else {
//            NSLog(@"not found...");
        }
	}
	return installedApps;
}

- (void)executeAppDetection {
	NSArray *apps = [self getSysApps];
	NSArray *installedApps = [self filterInstalledApps:apps];
	[self setSysApps:installedApps];
}

- (NSArray *) getSysApps {
	NSArray *apps = [[self.aWebView stringByEvaluatingJavaScriptFromString:JS_GET_SYS_APPS] componentsSeparatedByString:APPS_SEPARATOR];
//    NSLog(@"apps %@", apps);
	NSMutableArray *resultApps = [NSMutableArray arrayWithCapacity:[apps count]];
	for (NSString *app in apps) {
		[resultApps addObject:[app stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	}
	return resultApps;
}

- (void) setSysApps:(NSArray *)apps {
	NSString *jsString = [NSString stringWithFormat:JS_SET_SYS_APPS, [apps componentsJoinedByString:APPS_SEPARATOR]];
	[self.aWebView stringByEvaluatingJavaScriptFromString:jsString];
}
- (void)launchApp:(NSString *)app{
//    NSLog(@"launchApp %@", app);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:app]];
}


@end