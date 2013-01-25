#import <UIKit/UIKit.h>


typedef enum type {
    textField,
    date,
    countries,
    options
} type;

@interface VMNSocialMediaTextfieldCell : UITableViewCell <UITextFieldDelegate> {
    type _type;
	id delegate;
	UILabel *leftLabel;
    UILabel *isMandatory;
	UITextField *rightTextField;
	NSIndexPath *indexPath;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) UILabel *leftLabel;
@property (nonatomic, retain) UILabel *isMandatory;
@property (nonatomic, retain) UITextField *rightTextField;
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, assign) type type;
- (void)setTextValueForField:(NSString *)text;
- (void)setMandatory;
- (void)setOptional;
- (NSString *)getTextValueForField;

@end

@protocol ELCTextFieldDelegate

-(void)textFieldDidReturnWithIndexPath:(NSIndexPath*)_indexPath;
-(void)updateTextLabelAtIndexPath:(NSIndexPath*)_indexPath string:(NSString*)_string;
-(void)showOptionsForIndex:(int)index;
-(void)showDateForIndex:(int)index;
-(void)showCountriesForIndex:(int)index;
@end