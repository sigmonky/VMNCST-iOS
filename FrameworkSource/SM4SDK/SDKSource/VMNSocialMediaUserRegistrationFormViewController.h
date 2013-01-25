#import <UIKit/UIKit.h>

#import "VMNSocialMediaUserRegistrationProtocols.h"

#import "VMNSocialMediaTextfieldCell.h"


#import "VMNSocialMediaBrowserView.h"


#import "VMNSocialMediaGLTapLabelDelegate.h"
#import "VMNSocialMediaGLTapLabel.h"

@interface VMNSocialMediaUserRegistrationFormViewController : UITableViewController <ELCTextFieldDelegate, UIPickerViewDelegate, UIActionSheetDelegate, UITextViewDelegate, SelectCountryDelegate, VMNSocialMediaGLTapLabelDelegate>{
    
    //Form elements
    //    UITableView *_mainTable;
    NSMutableArray *_entryFields;
    BOOL editing;
	NSMutableArray *_fieldNames;
	NSMutableDictionary* _fieldData;
	UITextView *_textFieldBeingEdited;
	NSMutableDictionary *_textFieldProto;
    id<VMNSocialMediaUserRegistrationDelegate>_delegate;
    
    int _fieldBeingEdited;
    
    int _termsAndConditionsBeingViewed;
    
    VMNSocialMediaBrowserView *browserView;
    
    
    //UI
    float _viewTop;
    float _viewLeft;
    float _viewWidth;
    float _viewHeight;
    
    UIDatePicker *_datePicker;
    
	NSMutableArray *labels;
	NSMutableArray *placeholders;
    
    
    NSMutableArray *missingFields;

    NSMutableArray *tocCheckBoxes;
    
    NSMutableArray *tocCheckBoxesUI;

    
    BOOL isFormValid;
    
    float footerTotalHeight;
}

@property (nonatomic, retain) NSMutableArray *missingFields;


@property (nonatomic, retain) NSMutableArray *labels;
@property (nonatomic, retain) NSMutableArray *placeholders;

@property (nonatomic, retain) NSMutableArray *tocCheckBoxes;

@property (nonatomic, retain) NSMutableArray *tocCheckBoxesUI;


@property (nonatomic, assign) id<VMNSocialMediaUserRegistrationDelegate>delegate;

@property (nonatomic, retain) NSMutableArray *entryFields;

// PRIVATE
@property (nonatomic,retain) UITextView *textFieldBeingEdited;

// PUBLIC

//@property (retain) IBOutlet UITableView *mainTable;
//@property (nonatomic,assign) id <TableFormEditorDelegate> delegate;
@property (nonatomic,retain) NSMutableArray *fieldNames;
@property (nonatomic,retain) NSMutableDictionary* fieldData;
@property (nonatomic,retain) NSMutableDictionary* textFieldProto;
@property NSInteger firstFocusRow;

@property (nonatomic, retain) NSArray *formFields;


- (id)initWithViewLeft: (float)aViewLeft viewTop:(float)aViewTop viewWidth:(float)aViewWidth viewHeight:(float)aViewHeight;

- (void)validateForm;
- (void)submitForm;
- (BOOL) validateDisplayName: (NSString *) candidate;
- (BOOL) validateUrlName: (NSString *) candidate;
- (BOOL) validatePassword: (NSString *) candidate;
- (BOOL) validateEmail: (NSString *) candidate;
- (BOOL)isFieldRequired:(NSString *)fieldName;

@end
