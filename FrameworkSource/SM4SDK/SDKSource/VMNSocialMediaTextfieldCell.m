#import "VMNSocialMediaTextfieldCell.h"


@implementation VMNSocialMediaTextfieldCell

@synthesize delegate;
@synthesize leftLabel;
@synthesize isMandatory;
@synthesize rightTextField;
@synthesize indexPath;
@synthesize type = _type;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		
		leftLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[leftLabel setBackgroundColor:[UIColor clearColor]];
		[leftLabel setTextColor:[UIColor colorWithRed:.285 green:.376 blue:.541 alpha:1]];
		[leftLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
		[leftLabel setTextAlignment:UITextAlignmentRight];
		[leftLabel setText:@"Left Field"];
		[self addSubview:leftLabel];
        
        isMandatory = [[UILabel alloc] initWithFrame:CGRectMake(0,20,0,0)];
		[isMandatory setBackgroundColor:[UIColor clearColor]];
		[isMandatory setTextColor:[UIColor blackColor]];
		[isMandatory setFont:[UIFont fontWithName:@"Helvetica" size:13]];
		[isMandatory setTextAlignment:UITextAlignmentRight];
		[isMandatory setText:@"required"];
		[self addSubview:isMandatory];
		
		rightTextField = [[UITextField alloc] initWithFrame:CGRectZero];
		rightTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		[rightTextField setDelegate:self];
//		[rightTextField setPlaceholder:@"Right Field"];
		[rightTextField setFont:[UIFont systemFontOfSize:15]];
		
		// FOR MWF USE DONE
		[rightTextField setReturnKeyType:UIReturnKeyDone];
		
		[self addSubview:rightTextField];
    }
    
//    NSLog(@"origin %f", self.frame.origin.y);
    
    return self;
}

- (void)setMandatory{
    [leftLabel setTextColor:[UIColor redColor]];
}

- (void)setOptional{
    [leftLabel setTextColor:[UIColor colorWithRed:.285 green:.376 blue:.541 alpha:1]];
}

//Layout our fields in case of a layoutchange (fix for iPad doing strange things with margins if width is > 400)
- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect origFrame = self.contentView.frame;
	if (leftLabel.text != nil) {
		leftLabel.frame = CGRectMake(origFrame.origin.x, origFrame.origin.y-10, 90, origFrame.size.height-1);
        isMandatory.frame = CGRectMake(origFrame.origin.x, 10, 90, origFrame.size.height-1);

		rightTextField.frame = CGRectMake(origFrame.origin.x+105, origFrame.origin.y-10, origFrame.size.width-120, origFrame.size.height-1);
	} else {
		leftLabel.hidden = YES;
		NSInteger imageWidth = 0;
		if (self.imageView.image != nil) {
			imageWidth = self.imageView.image.size.width + 5;
		}
		rightTextField.frame = CGRectMake(origFrame.origin.x+imageWidth+10, origFrame.origin.y, origFrame.size.width-imageWidth-20, origFrame.size.height-1);
	}
    


}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;

}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (_type == options){
        [textField resignFirstResponder];
        [delegate showOptionsForIndex:[indexPath row]];
    }else if (_type == date){
        [textField resignFirstResponder];
        [delegate showDateForIndex:[indexPath row]];
    }
        else if (_type == countries){
            [textField resignFirstResponder];
        [delegate showCountriesForIndex:[indexPath row]];
    }
    
}

- (void)setTextValueForField:(NSString *)text{
    self.rightTextField.text = text;
}

- (NSString *)getTextValueForField{
    return self.rightTextField.text;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

	NSString *textString = self.rightTextField.text;
	
	if (range.length > 0) {
		
		textString = [textString stringByReplacingCharactersInRange:range withString:@""];
	} 
	
	else {
		
		if(range.location == [textString length]) {
			
			textString = [textString stringByAppendingString:string];
		}

		else {
			
			textString = [textString stringByReplacingCharactersInRange:range withString:string];	
		}
	}
	
	if([delegate respondsToSelector:@selector(updateTextLabelAtIndexPath:string:)]) {		
		[delegate performSelector:@selector(updateTextLabelAtIndexPath:string:) withObject:indexPath withObject:textString];
	}
	
	return YES;
}

- (void)dealloc {
    [isMandatory release];
	[leftLabel release];
	[rightTextField release];
	[indexPath release];
    [super dealloc];
}

@end
