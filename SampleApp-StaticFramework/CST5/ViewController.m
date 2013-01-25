/**
 
 Abstract: CST Demo View Controller that shows how to call the CST Panel and insert it into view.
 
 Version: 1.0
 
 */

#import "ViewController.h"
#import <VMNCSTFramework/CSTView.h>

@implementation ViewController

@synthesize mgid;

@synthesize detailMgid;
@synthesize detailLabel;
@synthesize viewSelector;




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self setDetailEntry];
    
}

- (void) setDetailEntry
{
    if (viewSelector.selectedSegmentIndex == 0) {
        detailMgid.enabled = FALSE;
        detailMgid.borderStyle = UITextBorderStyleNone;
        detailMgid.backgroundColor = [UIColor lightGrayColor];
        detailMgid.textColor = [UIColor lightGrayColor];
        detailLabel.textColor = [UIColor lightGrayColor];
    } else {
        detailMgid.enabled = TRUE;
        detailMgid.borderStyle = UITextBorderStyleRoundedRect;
        detailMgid.backgroundColor = [UIColor whiteColor];
        detailMgid.textColor = [UIColor blackColor];
        detailLabel.textColor = [UIColor blackColor];
    }
}
- (void)viewDidUnload
{
    [self setMgid:nil];
    [self setDetailMgid:nil];
    [detailMgid release];
    detailMgid = nil;
    [self setDetailLabel:nil];
    [self setViewSelector:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeLeft animated:NO];
    CGAffineTransform newTransform = CGAffineTransformMake(0.0,1.0,-1.0,0.0,0.0,0.0);         
    self.view.transform = newTransform;
    [super viewWillAppear:animated];
}

/* here are sample button handlers for iPhone, iPad and Universal Applications: 
 - (IBAction)launchCST_iPhone:(id)sender{
 NSString *mgidValue = @"MGID value for iPhone App";
 NSString *platformValue = @"iPhone"; // this could also be "iPhone,iPad".
 //[CSTView showCSTInView:self.view forMgid:mgidValue forPlatform:platformValue inFullScreenMode:TRUE];
 }
 - (IBAction)launchCST_iPad:(id)sender{
 UIView *popUpView = [[[UIView alloc] initWithFrame:CGRectMake(100, 100, 320, 480)] autorelease];
 NSString *mgidValue = @"MGID value for iPad App";
 NSString *platformValue = @"iPad"; // this could also be "iPhone,iPad".
 //[CSTView showCSTInView:popUpView forMgid:mgidValue forPlatform:platformValue inFullScreenMode:FALSE];
 [self.view addSubview:popUpView];
 }
 - (IBAction)launchCST_Universal:(id)sender{
 NSString *mgidValue_iPhone = @"MGID value for iPhone App";
 NSString *mgidValue_iPad = @"MGID value for iPad App";    
 if (NSClassFromString(@"UISplitViewController") != nil && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
 UIView *popUpView = [[[UIView alloc] initWithFrame:CGRectMake(100, 100, 320, 480)] autorelease];
 //[CSTView showCSTInView:popUpView forMgid:mgidValue_iPad forPlatform:@"iPad" inFullScreenMode:FALSE];
 [self.view addSubview:popUpView];
 }
 else {
 //[CSTView showCSTInView:self.view forMgid:mgidValue_iPhone forPlatform:@"iPhone" inFullScreenMode:TRUE];
 }
 }
 */

//here's the button handler used for this sample:
- (IBAction)launchCST{
    [mgid resignFirstResponder];
    [detailMgid resignFirstResponder];
    NSString *viewValue =@"";
    NSString *mgidValue = mgid.text;
    //NSString *platformValue = platform.text;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:detailMgid.text forKey:@"uri"];
    
    if ((detailMgid.text.length > 0) && (viewSelector.selectedSegmentIndex == 1)) {
        viewValue = @"detail";
    } else {
        viewValue = @"landing";
    }
    [params setObject:viewValue forKey:@"view"];
    
    //@"2655d8ff-0d77-4fdf-9000-a019191409c4"
    
    if (mgidValue == nil)mgidValue=@" ";
    //if (platformValue == nil)platformValue=@"";
    
    if (NSClassFromString(@"UISplitViewController") != nil && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //IPAD DISPLAY
        //if ( fullScreen.on ) {
        [params setObject:@"false" forKey:@"partial"];
        [CSTView showCSTInView:self.view forMgid:mgidValue forPlatform:@"iPad" inFullScreenMode:TRUE paramsList:params];
        /*} else {
         UIView *popUpView = [[[UIView alloc] initWithFrame:CGRectMake(50, 300, 600, 480)] autorelease];
         [params setObject:@"true" forKey:@"partial"];
         [CSTView showCSTInView:popUpView forMgid:mgidValue forPlatform:@"iPad" inFullScreenMode:FALSE paramsList:params];
         [self.view addSubview:popUpView];
         }*/
    } else {
        //IPHONE DISPLAY
        
        //SHOW CST IN FULL SCREN MODE
        //if ( fullScreen.on ){
        [params setObject:@"false" forKey:@"partial"];
        [CSTView showCSTInView:self.view forMgid:mgidValue forPlatform:@"iPhone" inFullScreenMode:TRUE paramsList:params];
        /*} else {
         [params setObject:@"true" forKey:@"partial"];
         UIView *popUpView = [[[UIView alloc] initWithFrame:CGRectMake(0,230, 320, 250)] autorelease];
         [CSTView showCSTInView:popUpView forMgid:mgidValue forPlatform:@"iPhone" inFullScreenMode:FALSE paramsList:params];
         [self.view addSubview:popUpView];
         
         }*/
    }
    
}

- (void)dealloc
{
    [mgid release];
    [detailMgid release];
    [detailMgid release];
    [detailLabel release];
    [viewSelector release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


#pragma mark UITextField delegate method
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[deepLink setOn:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}


- (IBAction)selectViewType:(id)sender {
    NSLog(@"selecting view type...%d",viewSelector.selectedSegmentIndex);
    [self setDetailEntry];
}
@end
