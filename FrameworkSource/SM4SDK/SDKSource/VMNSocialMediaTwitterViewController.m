#import "VMNSocialMediaTwitterViewController.h"

#define kViewHeight CGRectGetHeight([UIScreen mainScreen].applicationFrame)
#define kViewWidth  CGRectGetWidth([UIScreen mainScreen].applicationFrame)

@interface VMNSocialMediaTwitterViewController ()

@end

@implementation VMNSocialMediaTwitterViewController

@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithDelegate:(id<SMTwitterViewControllerDelegate>)feedbackDelegate{
	self = [super init];
	if (self != nil) {
		_delegate = feedbackDelegate;
		
	}
	return self;
}

-(void) close_clicked:(id)sender {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}


- (void)viewDidLoad{
    [self.view setFrame:CGRectMake(0, 0, kViewWidth, kViewHeight)];
    VMNSocialMediaTwitterAccountsListViewController *twitterAccountsListView = [[VMNSocialMediaTwitterAccountsListViewController alloc]initWithViewLeft:0 viewTop:44.0f viewWidth:self.view.bounds.size.width viewHeight:self.view.bounds.size.height - 30.0f];
    
    twitterAccountsListView.delegate = self;

	[self.view addSubview:twitterAccountsListView.view];
    
	UIBarButtonItem *topLeftSpace2Item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
	UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, 44.0f)];
    
    [toolBar sizeToFit];
    
	UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(closeButtonClick)];
    
	toolBar.items = [NSArray arrayWithObjects:topLeftSpace2Item,barItem,nil];
    
	[topLeftSpace2Item release];
    
	[barItem release];
    
	[self.view  addSubview:toolBar];
    
	[toolBar release];
}

- (void) closeButtonClick {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self.view removeFromSuperview];
}

- (void)addTwitterIntoView:(UIView *)aView{
    VMNSocialMediaTwitterAccountsListViewController *twitterAccountsListView = [[VMNSocialMediaTwitterAccountsListViewController alloc]initWithViewLeft:0 viewTop:44.0f viewWidth:aView.bounds.size.width viewHeight:aView.bounds.size.height - 30.0f];
    twitterAccountsListView.delegate = self;
	[aView addSubview:twitterAccountsListView.view];
}

- (void)closeTwitterAccountList:(id)account{
    [_delegate twitterAccountDidGetSelected:account];
	[self.view removeFromSuperview];
}

- (void)twitterAccountAccessRefused:(NSString *)aMessage{
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue:aMessage forKey:NSLocalizedDescriptionKey];
    // populate the error object with the details
    NSError *error = [NSError errorWithDomain:@"com.vmnsocialmedia.session" code:22 userInfo:details];
    [_delegate twitterAccountNotAuthorized:error];
	[self.view removeFromSuperview];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
