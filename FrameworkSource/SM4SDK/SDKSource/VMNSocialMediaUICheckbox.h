#import <Foundation/Foundation.h>

@interface VMNSocialMediaUICheckbox : UIButton {
    
    BOOL checked;
    
}

@property (nonatomic, assign) BOOL checked;

-(IBAction)checkBoxClicked;

@end