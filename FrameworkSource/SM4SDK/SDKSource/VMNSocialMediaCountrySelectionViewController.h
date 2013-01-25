#import <UIKit/UIKit.h>
#import "VMNSocialMediaUserRegistrationProtocols.h"

@interface VMNSocialMediaCountrySelectionViewController : UITableViewController{
    NSMutableArray *_countries;
    int _selectedRow;
    id<SelectCountryDelegate>_delegate;
}

@property (nonatomic, retain)  NSMutableArray *countries;
@property (nonatomic, assign)  id<SelectCountryDelegate> delegate;

@end
