/**
 
 Abstract: CST Demo View Controller that shows how to call the CST Panel and insert it into view.
 
 Version: 1.0
 
 */

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITextFieldDelegate>{
    UITextField *mgid;
    UITextField *detailMgid;
    UILabel *detailLabel;
    UISegmentedControl *viewSelector;
}

@property(nonatomic, retain)    IBOutlet UITextField *mgid;
@property (retain, nonatomic)   IBOutlet UITextField *detailMgid;
@property (retain, nonatomic) IBOutlet UILabel *detailLabel;
@property (retain, nonatomic) IBOutlet UISegmentedControl *viewSelector;

- (IBAction)selectViewType:(id)sender;
- (void) setDetailEntry; 

@end
