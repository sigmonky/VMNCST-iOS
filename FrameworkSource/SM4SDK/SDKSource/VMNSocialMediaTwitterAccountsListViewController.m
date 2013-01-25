#import "VMNSocialMediaTwitterAccountsListViewController.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

@interface VMNSocialMediaTwitterAccountsListViewController ()
- (void)fetchData;
@property (strong, nonatomic) NSCache *usernameCache;
@property (strong, nonatomic) NSCache *imageCache;
@end

@implementation VMNSocialMediaTwitterAccountsListViewController

@synthesize accounts = _accounts;
@synthesize accountStore = _accountStore;
@synthesize delegate = _delegate;
@synthesize imageCache = _imageCache;
@synthesize usernameCache = _usernameCache;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    self.title = @"Accounts";
    if (self) {
        _imageCache = [[NSCache alloc] init];
        [_imageCache setName:@"TWImageCache"];
        _usernameCache = [[NSCache alloc] init];
        [_usernameCache setName:@"TWUsernameCache"];
        [self fetchData];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    self.tableView.frame = CGRectMake(_viewLeft,_viewTop,_viewWidth,_viewHeight);
}


- (id)initWithViewLeft: (float)aViewLeft viewTop:(float)aViewTop viewWidth:(float)aViewWidth viewHeight:(float)aViewHeight {
    self = [super init];
    if (self) {
        _viewLeft = aViewLeft;
        _viewTop = aViewTop;
        _viewWidth = aViewWidth;
        _viewHeight = aViewHeight;
        self.title = @"Accounts";
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [_imageCache removeAllObjects];
    [_usernameCache removeAllObjects];
    [super didReceiveMemoryWarning];
}

#pragma mark - Data handling

- (void)fetchData
{
    if (_accountStore == nil) {    
        self.accountStore = [[ACAccountStore alloc] init];
        if (_accounts == nil) {
            ACAccountType *accountTypeTwitter = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            [self.accountStore requestAccessToAccountsWithType:accountTypeTwitter withCompletionHandler:^(BOOL granted, NSError *error) {
                NSLog(@"%d",error.code);
                if(granted) {
                    self.accounts = [self.accountStore accountsWithAccountType:accountTypeTwitter];                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData]; 
                    });
                }else{
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        NSString *message;
                        if (error.code == 6){
                            message = @"There's no Twitter account registered in this device.";
                        }else{
                            message = @"User didn't allow access to his/her Twitter account";
                        }
                        [_delegate twitterAccountAccessRefused:message];
                    });
                }
            }];
        }
    }
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.accounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    ACAccount *account = [self.accounts objectAtIndex:[indexPath row]];
    cell.textLabel.text = account.username;
    cell.detailTextLabel.text = account.accountDescription;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSString *username = [_usernameCache objectForKey:account.username];
    if (username) {
        cell.textLabel.text = username;
    }
    else {
        TWRequest *fetchAdvancedUserProperties = [[TWRequest alloc] 
                                                  initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1/users/show.json"] 
                                                  parameters:[NSDictionary dictionaryWithObjectsAndKeys:account.username, @"screen_name", nil]
                                                  requestMethod:TWRequestMethodGET];
        [fetchAdvancedUserProperties performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if ([urlResponse statusCode] == 200) {
                NSError *error;
                id userInfo = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
                if (userInfo != nil) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [_usernameCache setObject:[userInfo valueForKey:@"name"] forKey:account.username];                        
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
                    });
                }
            }
        }];        
    }
    
    UIImage *image = [_imageCache objectForKey:account.username];
    if (image) {
        cell.imageView.image = image;        
    }
    else {
        TWRequest *fetchUserImageRequest = [[TWRequest alloc] 
                                            initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.twitter.com/1/users/profile_image/%@", account.username]] 
                                            parameters:nil
                                            requestMethod:TWRequestMethodGET];
        [fetchUserImageRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if ([urlResponse statusCode] == 200) {
                UIImage *image = [UIImage imageWithData:responseData];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [_imageCache setObject:image forKey:account.username];                    
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
                });
            }
        }];        
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_delegate closeTwitterAccountList:[self.accounts objectAtIndex:[indexPath row]]];
}

@end
