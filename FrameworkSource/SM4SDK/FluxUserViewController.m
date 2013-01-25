#import "FluxUserViewController.h"
#import "VMNSocialMediaUser.h"
#import "VMNSocialMediaSession.h"

@interface FluxUserViewController ()

@end

@implementation FluxUserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"User Profile";
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    VMNSocialMediaUser *user = [[VMNSocialMediaSession sharedInstance] currentUser];
//    NSLog(@"flux user view: viewWillAppear user:%@", [[VMNSocialMediaSession sharedInstance] currentUser ]);
    if (nil == user) {
        userIdLabel.text = @"N/A";
        userNameLabel.text = @"N/A";
    } else {
//        NSLog("flux user profile %@", [user fluxProfile ]);
        userIdLabel.text = [[user fluxProfile ] objectForKey:@"Ucid"];
        
        NSString *fluxLoginName = [[user fluxProfile ] valueForKey:@"LoginName"];
        NSLog(@"flux login name %@", fluxLoginName);    
        if (fluxLoginName != [NSNull null]){
            userNameLabel.text = fluxLoginName;
        }
        
        [self downloadingServerImageFromUrl:userProfileImage AndUrl:[[[user fluxProfile ] objectForKey:@"Thumbnails"] objectForKey:@"Small" ]];
    }
}

- (IBAction)showUserProperties{
    NSString *userSettings = [NSString stringWithFormat:@"%@",[[[VMNSocialMediaSession sharedInstance] currentUser] fluxProfile ]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Settings" message:userSettings delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}



-(void)downloadingServerImageFromUrl:(UIImageView*)imgView AndUrl:(NSString*)strUrl{
    
    NSString* theFileName = [NSString stringWithFormat:@"%@.png",[[strUrl lastPathComponent] stringByDeletingPathExtension]];
    
    NSFileManager *fileManager =[NSFileManager defaultManager];
    NSString *fileName = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tmp/%@",theFileName]];
    
    imgView.backgroundColor = [UIColor darkGrayColor];
    UIActivityIndicatorView *actView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [imgView addSubview:actView];
    [actView startAnimating];
    CGSize boundsSize = imgView.bounds.size;
    CGRect frameToCenter = actView.frame;
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    actView.frame = frameToCenter;
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        NSData *dataFromFile = nil;
        NSData *dataFromUrl = nil;
        
        dataFromFile = [fileManager contentsAtPath:fileName];
        if(dataFromFile==nil){
            dataFromUrl=[[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:strUrl]] autorelease];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if(dataFromFile!=nil){
                imgView.image = [UIImage imageWithData:dataFromFile];
            }else if(dataFromUrl!=nil){
                imgView.image = [UIImage imageWithData:dataFromUrl];
                NSString *fileName = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tmp/%@",theFileName]];
                
                BOOL filecreationSuccess = [fileManager createFileAtPath:fileName contents:dataFromUrl attributes:nil];
                if(filecreationSuccess == NO){
                    NSLog(@"Failed to create the html file");
                }
                
            }else{
                imgView.image = [UIImage imageNamed:@"NO_Image.png"];
            }
            [actView removeFromSuperview];
            [actView release];
            [imgView setBackgroundColor:[UIColor clearColor]];
        });
    });
    
    
}

- (void)viewDidLoad
{
    UIBarButtonItem *topLeftSpace2Item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44.0f)];
    
    [toolBar sizeToFit];
    
    toolBar.userInteractionEnabled = YES;
    
    UIBarButtonItem *barCloseBtn = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(closeButtonClick)];
    
    toolBar.items = [NSArray arrayWithObjects:topLeftSpace2Item,barCloseBtn,nil];
    
    [topLeftSpace2Item release];
    
    [barCloseBtn release];
    
    [self.view  addSubview:toolBar];
    
    [toolBar release];
    
    [super viewDidLoad];
}


- (void) closeButtonClick {
    [self dismissModalViewControllerAnimated: YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
