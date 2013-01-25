#import "VMNSocialMediaUserRegistrationFormViewController.h"
#import "VMNSocialMediaCountrySelectionViewController.h"
#import "VMNSocialMediaSession.h"
#import "VMNSocialMediaFluxUtils.h"
#import "VMNSocialMediaUICheckbox.h"
#import "VMNSocialMediaBrowserView.h"
#import "VMNSocialMediaUIActionSheetWithDismiss.h"
#import "VMNSocialMediaConstants.h"

@interface VMNSocialMediaUserRegistrationFormViewController ()

@end

@implementation VMNSocialMediaUserRegistrationFormViewController

//@synthesize mainTable = _mainTable;
@synthesize delegate = _delegate;
@synthesize fieldNames = _fieldNames;
@synthesize fieldData = _fieldData;
@synthesize textFieldProto = _textFieldProto;
@synthesize entryFields = _entryFields;
@synthesize textFieldBeingEdited = _textFieldBeingEdited;
@synthesize formFields;

@synthesize labels;
@synthesize placeholders;

@synthesize missingFields;
@synthesize tocCheckBoxes;
@synthesize tocCheckBoxesUI;

#define kLabelTag   4096
#define kTextTag    4097

#define toc_line_width_iPhone  250.0
#define toc_line_width_iPad  430.0

#define BUNDLE 

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    missingFields = [[NSMutableArray alloc]init];

    
    isFormValid = true;
    
    // UINavigation Bar
    self.title = @"Sign up";
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleDone target:self
                                                                  action:@selector(submitForm)];
    self.navigationItem.rightBarButtonItem = doneButton;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonSystemItemCancel target:self
                                                                  action:@selector(closeView)];
    self.navigationItem.leftBarButtonItem = backButton;
    [backButton release];

    
    self.textFieldProto = [[NSMutableDictionary alloc] init];

    self.labels = [[NSMutableArray alloc]init];
    
    self.tocCheckBoxes = [[NSMutableArray alloc]init];
    self.tocCheckBoxesUI = [[NSMutableArray alloc]init];

    
    
    for( int i = 0; i < [self.formFields count];i++){
        id aField = [self.formFields objectAtIndex:i];
        
        //Dont display Terms and Agreements in the table view
        if (![[aField objectForKey:@"Field"] isEqualToString:@"AgreementTerms"]){
            [self.labels addObject:[aField objectForKey:@"Field"]];
            [self.textFieldProto setObject:@"" forKey:[[aField valueForKey:@"Field"] lowercaseString]];
        }else{
            
            [self.textFieldProto setObject:@"" forKey:@"tos_accepted"];

            //get the fields for TOC checkboxes
            
            
            NSString *value = [aField objectForKey:@"Value"];
            if (![value isKindOfClass:[NSNull class]]){
                for (id checkbox in [aField objectForKey:@"Value"]){
                    if (checkbox != nil)[self.tocCheckBoxes addObject:checkbox];
                }
            }
 
        }
    }

    
    footerTotalHeight = 0;
    
    BOOL isIpad = false;
    if (NSClassFromString(@"UISplitViewController") != nil && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        isIpad = true;
    }
    
    for (int i =0; i<[tocCheckBoxes count]; i++){
        
        if (isIpad){
            CGSize theSize = [ [[tocCheckBoxes objectAtIndex:i] objectForKey:@"Text"] sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0] constrainedToSize:CGSizeMake(toc_line_width_iPad, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
            footerTotalHeight = footerTotalHeight + theSize.height + 15;

        }else{
            CGSize theSize = [ [[tocCheckBoxes objectAtIndex:i] objectForKey:@"Text"] sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0] constrainedToSize:CGSizeMake(toc_line_width_iPhone, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
            footerTotalHeight = footerTotalHeight + theSize.height + 15;
        }
        

//        CGSize theSize = [[tocCheckBoxes objectAtIndex:i] sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0] constrainedToSize:CGSizeMake(250, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];         footerTotalHeight = footerTotalHeight + theSize.height + 15;
        
        
        // 15 is padding
    }
    
    //44 is the height of the submit button
    footerTotalHeight = footerTotalHeight+44;
    
    //44 is the height of the footer header label it's different than nil
    footerTotalHeight = footerTotalHeight+44;
}




- (id)initWithViewLeft: (float)aViewLeft viewTop:(float)aViewTop viewWidth:(float)aViewWidth viewHeight:(float)aViewHeight {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _viewLeft = aViewLeft;
        _viewTop = aViewTop;
        _viewWidth = aViewWidth;
        _viewHeight = aViewHeight;
    }
    return self;
}

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [super dealloc];
    self.tocCheckBoxesUI = nil;
    self.tocCheckBoxes = nil;
    self.missingFields = nil;
    self.formFields = nil;
    self.entryFields = nil;
    self.textFieldBeingEdited = nil;
    self.delegate = nil;
    self.fieldNames = nil;
    self.fieldData = nil;
    self.textFieldProto = nil;
    
}


- (BOOL)isFieldRequired:(NSString *)fieldName{
    for( int i = 0; i < [self.formFields count];i++){
        id aField = [self.formFields objectAtIndex:i];
        //Dont display Terms and Agreements in table view
        if (![[aField objectForKey:@"Field"] isEqualToString:fieldName]){
            NSString *isRequired = [NSString stringWithFormat:@"%@", [aField objectForKey:@"Required"]];
            if ([isRequired isEqualToString:@"1"]){
                return TRUE;
            }else{
                return FALSE;
            }
        }
    }
    return FALSE;

}

#pragma mark Table view data source

- (void)configureCell:(VMNSocialMediaTextfieldCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	cell.leftLabel.text = [self.labels objectAtIndex:indexPath.row];

    if ([self isFieldRequired:[self.labels objectAtIndex:indexPath.row]]){
        cell.isMandatory.text = @"required";
    }else{
        cell.isMandatory.text = @"";
    }

    [cell setOptional];

    for (int i=0; i< [self.missingFields count]; i++){
        if ([[self.missingFields objectAtIndex:i] isEqualToString:[[self.labels objectAtIndex:indexPath.row]lowercaseString]]){
            [cell setMandatory];
        }
    }

	cell.indexPath = indexPath;
	cell.delegate = self;
    //Disables UITableViewCell from accidentally becoming selected.
    cell.selectionStyle = UITableViewCellEditingStyleNone;
    
    NSString *label = [self.labels objectAtIndex:indexPath.row];
    
    if ([label isEqualToString:@"Birthday"]){
        cell.type = date;
    }else if ([label isEqualToString:@"Gender"]){
        cell.type = options;
    }
    else if ([label isEqualToString:@"Location"]){
        cell.type = countries;
    }else{
        cell.type = textField;
    }
    
    // Todo: AgreementTerms
    
    //Password 
    if ([label isEqualToString:@"Password"]){
        [cell.rightTextField setSecureTextEntry:YES];
    }
    
    if ([label isEqualToString:@"mobilephone"] || [label isEqualToString:@"postalcode"]){
		[cell.rightTextField setKeyboardType:UIKeyboardTypeNumberPad];
    }

}


// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.labels count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    VMNSocialMediaTextfieldCell *cell = (VMNSocialMediaTextfieldCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[VMNSocialMediaTextfieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	[self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark VMNSocialMediaTextfieldCellDelegate Methods

-(void)textFieldDidReturnWithIndexPath:(NSIndexPath*)indexPath {
    
	if(indexPath.row < [labels count]-1) {
		NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
		[[(VMNSocialMediaTextfieldCell*)[self.tableView cellForRowAtIndexPath:path] rightTextField] becomeFirstResponder];
		[self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
	}
	
	else {
        
		[[(VMNSocialMediaTextfieldCell*)[self.tableView cellForRowAtIndexPath:indexPath] rightTextField] resignFirstResponder];
	}
}


//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 40.0f;
//}

// =================================================================================================
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


- (void)updateTextLabelAtIndexPath:(NSIndexPath*)indexPath string:(NSString*)string {
//    NSLog(@"key %@", [self.labels objectAtIndex:indexPath.row]);
    if (![string isEqualToString:@""]){
        [self.textFieldProto setObject:string forKey:[[self.labels objectAtIndex:indexPath.row]lowercaseString]];
    }

//	NSLog(@"See input: %@ from section: %d row: %d, should update models appropriately", string, indexPath.section, indexPath.row);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!isFormValid){
        UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,30)] autorelease];
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, headerView.frame.size.height)];
        headerLabel.textAlignment = UITextAlignmentCenter;
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.text = VALIDATION_NUMBER_OF_FIELDS;
        [headerLabel setTextColor:[UIColor colorWithRed:.285 green:.376 blue:.541 alpha:1]];
        [headerLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
        [headerView addSubview:headerLabel];
        [headerLabel release];
        return headerView;
    }else{
        return nil;
    }
}

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (isFormValid){
        return 0;
    }
    else{
        return 40;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {

    //allocate the view if it doesn't exist yet
//    UIView *footerView  = [[UIView alloc] init];
    
    //Calculate size of Footer view
    UIView *footerView = [[[UIView alloc] initWithFrame:CGRectMake(20,0,tableView.frame.size.width-40,550)] autorelease];
    
    
    float labelsTotalHeight = 0;
    // Create TOC checkboxes
//    float currentY = 70;
     float currentY = 20;

    BOOL isIpad = false;
    if (NSClassFromString(@"UISplitViewController") != nil && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        isIpad = true;
    }
    
    
    int numberOfTocCheckBoxesWithCheckTrue = 0;
    
    for (int zz=0; zz<[tocCheckBoxes count]; zz++){
        NSString *hasCheckBox = [[tocCheckBoxes objectAtIndex:zz] valueForKey:@"CheckBox"];
        if (hasCheckBox)numberOfTocCheckBoxesWithCheckTrue=numberOfTocCheckBoxesWithCheckTrue+1;
    }
    
//    NSLog(@"count checkbox ui %d", [tocCheckBoxesUI count ]);
//    
//    NSLog(@"count numberOfTocCheckBoxesWithCheckTrue ui %d", numberOfTocCheckBoxesWithCheckTrue);
    int currentIndexOfCheckBoxWithCheckTrue = 0;

    for (int i =0; i<[tocCheckBoxes count]; i++){
        
        
//        BOOL hasCheckBox = [[[tocCheckBoxes objectAtIndex:i] valueForKey:@"CheckBox"] isEqualToString:@"true"];
        
        NSString *hasCheckBox = [[tocCheckBoxes objectAtIndex:i] valueForKey:@"CheckBox"];

        
        CGSize theSize;
        
        if (isIpad == true) {
            theSize = [[[tocCheckBoxes objectAtIndex:i] objectForKey:@"Text" ] sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0] constrainedToSize:CGSizeMake(toc_line_width_iPad, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
            
        }else{
            theSize = [[[tocCheckBoxes objectAtIndex:i] objectForKey:@"Text" ] sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0] constrainedToSize:CGSizeMake(toc_line_width_iPhone, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        }
        
//        float currentY = headingLabel.frame.size.height + (55*i) + 20;
//        currentY = labelsTotalHeight + 15;

        
        if (hasCheckBox){
        
            
            if ([tocCheckBoxesUI count ] < numberOfTocCheckBoxesWithCheckTrue){
                VMNSocialMediaUICheckbox *checkbox;
                if (isIpad == true) {
                    checkbox = [[[VMNSocialMediaUICheckbox alloc] initWithFrame:CGRectMake(30,currentY,30, 30)] autorelease];

                }else{
                    checkbox = [[[VMNSocialMediaUICheckbox alloc] initWithFrame:CGRectMake(10,currentY,30, 30)] autorelease];
                }
                [tocCheckBoxesUI addObject:checkbox];
                [footerView addSubview:checkbox];
            }else{
                VMNSocialMediaUICheckbox *checkbox = (VMNSocialMediaUICheckbox *)[tocCheckBoxesUI objectAtIndex:currentIndexOfCheckBoxWithCheckTrue];
                [footerView addSubview:checkbox];
            }
        }

//        NSLog(@"the size height %f", theSize.height);
        
        VMNSocialMediaGLTapLabel *checkBoxLabel;
        if (isIpad == true) {
            checkBoxLabel = [[VMNSocialMediaGLTapLabel alloc] initWithFrame:CGRectMake(70, currentY, toc_line_width_iPad, theSize.height)];
        }else{
            checkBoxLabel = [[VMNSocialMediaGLTapLabel alloc] initWithFrame:CGRectMake(50, currentY, toc_line_width_iPhone, theSize.height)];
        }
        
        checkBoxLabel.delegate = self;
        checkBoxLabel.linkColor = [UIColor colorWithRed:.25 green:.25 blue:.25 alpha:1];

        checkBoxLabel.text = [[tocCheckBoxes objectAtIndex:i] objectForKey:@"Text" ];
        
        checkBoxLabel.numberOfLines = 0;

//        [checkBoxLabel sizeToFit];

        checkBoxLabel.tag = i;
        checkBoxLabel.textColor = [UIColor colorWithRed:.285 green:.376 blue:.541 alpha:1];
//        checkBoxLabel.textAlignment = UITextAlignmentLeft;
        checkBoxLabel.backgroundColor = [UIColor clearColor];
        checkBoxLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13.0];
        
        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnTOC:)];
        
        // if labelView is not set userInteractionEnabled, you must do so
        [checkBoxLabel setUserInteractionEnabled:YES];
        [checkBoxLabel addGestureRecognizer:gesture];
        
        [footerView addSubview:checkBoxLabel];

        labelsTotalHeight = currentY+theSize.height;
        currentY = labelsTotalHeight+15;
        
        if (hasCheckBox)currentIndexOfCheckBoxWithCheckTrue=currentIndexOfCheckBoxWithCheckTrue+1;

    }
    
    
    //create the Submission button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    //the button should be as big as a table view cell
    [button setFrame:CGRectMake(tableView.frame.size.width/2-150, labelsTotalHeight+20, 300, 44)];
    
    //set title, font size and font color
    [button setTitle:@"Submit" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [button setTitleColor:[UIColor colorWithRed:.285 green:.376 blue:.541 alpha:1]forState:UIControlStateNormal];

    //set action of the button
    [button addTarget:self action:@selector(submitForm) forControlEvents:UIControlEventTouchUpInside];
    
    //add the button to the view
    [footerView addSubview:button];

    footerView.frame = CGRectMake(20,0,tableView.frame.size.width-40,labelsTotalHeight+44);

    //return the view for the footer
    return footerView;
}

- (void)userTappedOnTOC:(id)sender{
//    NSLog(@"userTappedOnTOC with tag %d", [(UIGestureRecognizer *)sender view].tag);

    //Get the index of TOC
    for( int i = 0; i < [self.formFields count];i++){
        id aField = [self.formFields objectAtIndex:i];
        //Dont display Terms and Agreements in table view
        if ([[aField objectForKey:@"Field"] isEqualToString:@"AgreementTerms"]){
            _fieldBeingEdited = i;
        }
    }
    
    VMNSocialMediaUIActionSheetWithDismiss* sheet = [[VMNSocialMediaUIActionSheetWithDismiss alloc] init];
    sheet.title = @"Terms and Conditions";
    sheet.delegate = self;
    
    _termsAndConditionsBeingViewed = [(UIGestureRecognizer *)sender view].tag;

    NSMutableDictionary *checkBoxes = [tocCheckBoxes objectAtIndex:[(UIGestureRecognizer *)sender view].tag];
    
    for (id option in [checkBoxes objectForKey:@"links"]){
        [sheet addButtonWithTitle:[option objectForKey:@"title"]];
    }
    
    if ([[checkBoxes objectForKey:@"links"] count] >0){
        [sheet showInView:self.view];
    }
    [sheet release];

}

// specify the height of your footer section
- (CGFloat)tableView:(UITableView *)tableView
heightForFooterInSection:(NSInteger)section {
    //calculate the height of checkboxs, text label, submit button and padding
//    NSLog(@"footerTotalHeight %f", footerTotalHeight);
    return footerTotalHeight+50;
}

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

- (BOOL) validatePassword: (NSString *) candidate {
    if( [candidate length] >= 6 &&  [candidate length] <=16)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL) validateUrlName: (NSString *) candidate {
    if( [candidate length] >= 2 &&  [candidate length] <=25)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL) validateDisplayName: (NSString *) candidate {
    if( [candidate length] >= 1 &&  [candidate length] <=100)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL) validateBirthday: (NSString *) candidate {
        
    //Convert string to date
    NSString *dateString = candidate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful

    [dateFormatter setDateFormat:@"MM/dd/yyyy"];

    NSDate *dateFromString = [[NSDate alloc] init];
    // voila!
    dateFromString = [dateFormatter dateFromString:dateString];
    [dateFormatter release];
    
    NSDate *today = [NSDate date];
    
    
    if ([dateFromString compare:today] == NSOrderedDescending) {
//        NSLog(@"validateBirthday in the future", candidate);

        return NO;
    }else{
        return YES;
    }


}



- (void)validateForm{
    //Todo: Make a validator class
    
    
    // Array that contains any missing fields or fields that didn't pass validation
    [missingFields removeAllObjects];
    
    //Validate Form
    
    
    NSMutableString *errorMsg = [[NSMutableString alloc] init];
    NSUInteger errorMsgCharacterCount;

    for( int i = 0; i < [self.formFields count];i++){
        id aField = [self.formFields objectAtIndex:i];
        NSString *fieldKey = [[aField objectForKey:@"Field"] lowercaseString];

        NSString *isFieldRequired = [aField objectForKey:@"Required"];
        NSString *response =  [self.textFieldProto objectForKey:fieldKey];
        
        if (![fieldKey isEqualToString:@"agreementterms"]){
//            NSLog(@"key:%@ | response: %@", fieldKey, response);
            if ([response isEqualToString:@""] || response == nil){
                if (isFieldRequired){
                    [missingFields addObject:fieldKey];
//                    NSLog(@"response error");
                }
            }
        }
    }
    
    if ([missingFields count]>0)return;
    
    //Field has been populated, now it's time to validate it.
    
    //Validate TOS
    
    BOOL allTermsAgreed = true;
    for (int y =0; y<[tocCheckBoxesUI count]; y++){
        VMNSocialMediaUICheckbox *checkbox = (VMNSocialMediaUICheckbox *)[tocCheckBoxesUI objectAtIndex:y];
        if (!checkbox.checked){
                [missingFields addObject:@"tos_accepted"];
                allTermsAgreed = false;
            errorMsg = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@", VALIDATION_ACCEPT_TC]];
        }
    }
    
    
    if (allTermsAgreed){
        [self.textFieldProto setValue:@"true" forKey:@"tos_accepted"];
    }else{
        [self.textFieldProto setValue:@"false" forKey:@"tos_accepted"];
    }
    
    
    for( int x = 0; x < [self.formFields count];x++){
        id aField = [self.formFields objectAtIndex:x];
        NSString *fieldKey = [[aField objectForKey:@"Field"] lowercaseString];
        
        NSString *isFieldRequired = [aField objectForKey:@"Required"];
        NSString *response =  [self.textFieldProto objectForKey:fieldKey];
    
        errorMsgCharacterCount = [errorMsg length];

        
        //Validate Birthday
        if ([fieldKey isEqualToString:@"birthday"] && isFieldRequired){
            if (![self validateBirthday:response]){
                [missingFields addObject:fieldKey];
                if (errorMsgCharacterCount == 0){
                    errorMsg = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:VALIDATION_BIRTHDAY]];
                }
                
            }
        }
        
        //Validate email
        if ([fieldKey isEqualToString:@"email"] && isFieldRequired){
            if (![self validateEmail:response]){
                [missingFields addObject:fieldKey];
                if (errorMsgCharacterCount == 0){
                    errorMsg = [[NSMutableString alloc] initWithString:[NSString stringWithFormat: VALIDATION_EMAIL]];
                }

            }
        }
        
        //Validate password
        if ([fieldKey isEqualToString:@"password"] && isFieldRequired){
            if (![self validatePassword:response]){
                [missingFields addObject:fieldKey];
                if (errorMsgCharacterCount == 0){
                    errorMsg = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:VALIDATION_PASSWORD]];
                }


            }
        }
        
        //Validate display name
        if ([fieldKey isEqualToString:@"displayname"] && isFieldRequired){
            if (![self validateDisplayName:response]){
                [missingFields addObject:fieldKey];
                if (errorMsgCharacterCount == 0){
                    errorMsg = [[NSMutableString alloc] initWithString:[NSString stringWithFormat: VALIDATION_DISPLAYNAME]];
                }
            }
        }
        
        
        //Validate URL name
        if ([fieldKey isEqualToString:@"urlname"] && isFieldRequired){
            if (![self validateUrlName:response]){
                [missingFields addObject:fieldKey];
                if (errorMsgCharacterCount == 0){
                    errorMsg = [[NSMutableString alloc] initWithString:[NSString stringWithFormat: VALIDATION_URLNAME]];
                }

            }
        }
    
    
    }
    
    
    if (errorMsgCharacterCount > 0){
//        NSLog(@"errorMsg %@", errorMsg);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithString:errorMsg] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    
}

- (void)submitForm{
    
    // Validate form on the client side
    
    [self validateForm];
    
    
//    NSLog(@"submit form with values %@", self.textFieldProto);

    
    // Missing fields array will be populated by form validation if there are any fields not being validated properly
    
//    NSLog(@"missing fields count %d", [missingFields count]);

    if ([missingFields count]==0){
        isFormValid = true;
        
        [[VMNSocialMediaSession sharedInstance] submitFluxRegistrationInfo:self.textFieldProto completion:^( NSMutableDictionary *response) {
            int status = [[response objectForKey:@"Status"] intValue];
            
//            NSLog(@"submitForm: response stats %d", status );

            //Validation will now happen on the server side
            if (status == 2 || status == 4 || status == 0 || status == 12){
                // errors
//                NSString *message = [[response objectForKey:@"ErrorsDetail"] objectAtIndex:0];
                NSString *message = [response objectForKey:@"Message"];

                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Flux Error" message:message delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
            }else if (status == 1){
                // Success
                [_delegate registrationDidComplete:nil];
            }
        }];
    }else{
        isFormValid = false;
        [self.tableView reloadData];
    }
    
    // Close popup
    
}

#pragma mark ELCTextFieldDelegate Methods defined in VMNSocialMediaTextfieldCell


-(void)showOptionsForIndex:(int)index{
    _fieldBeingEdited = index;
    VMNSocialMediaUIActionSheetWithDismiss* sheet = [[VMNSocialMediaUIActionSheetWithDismiss alloc] init];
    sheet.title = @"Gender";
    sheet.delegate = self;
    NSString *fieldType = [self.labels objectAtIndex:index];
    if ([fieldType isEqualToString:@"Gender"]){
        [sheet addButtonWithTitle:@"Male"];
        [sheet addButtonWithTitle:@"Female"];
    }
    [sheet showInView:self.view];
    [sheet release];
}

-(void)showDateForIndex:(int)index{
    _fieldBeingEdited = index;
    NSString *title = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? @"\n\n\n\n\n\n\n\n\n" : @"\n\n\n\n\n\n\n\n\n\n\n\n" ;
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:[NSString stringWithFormat:@"%@%@", title, NSLocalizedString(@"", @"")]
                                  delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Done", nil];
    [actionSheet showInView:self.view];
    
    _datePicker= [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 270, 220)];

//    _datePicker = [[[UIDatePicker alloc] init] autorelease];
    [_datePicker addTarget:self action:@selector(changeDateInLabel:)
      forControlEvents:UIControlEventValueChanged];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    [actionSheet addSubview:_datePicker];
}


-(void)showCountriesForIndex:(int)index{
    _fieldBeingEdited = index;
    VMNSocialMediaCountrySelectionViewController *countriesView = [[VMNSocialMediaCountrySelectionViewController alloc]init];
    countriesView.delegate = self;
    [self.navigationController pushViewController:countriesView animated:TRUE];
    [countriesView release];
}

- (void)changeDateInLabel:(id)sender{
    //Use NSDateFormatter to write out the date in a friendly format
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	df.dateStyle = NSDateFormatterMediumStyle;
    
    NSDate *birthDate = _datePicker.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *year = [formatter stringFromDate:birthDate];
    [formatter setDateFormat:@"MM"];
    NSString *month = [formatter stringFromDate:birthDate];
    [formatter setDateFormat:@"dd"];
    NSString *day = [formatter stringFromDate:birthDate];
    
	NSString *date = [NSString stringWithFormat:@"%@/%@/%@",month,day, year];
    
    NSIndexPath* path = [NSIndexPath indexPathForRow:_fieldBeingEdited inSection:0];
    [(VMNSocialMediaTextfieldCell*)[self.tableView cellForRowAtIndexPath:path] setTextValueForField: date];
	[df release];
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *fieldType = [self.labels objectAtIndex:_fieldBeingEdited];
    NSIndexPath* path = [NSIndexPath indexPathForRow:_fieldBeingEdited inSection:0];
    
//    NSLog(@"field type %@", fieldType);
    if ([fieldType isEqualToString:@"Gender"]){
        NSString *fieldValue;
        if (buttonIndex == 0){
            fieldValue = @"Male";
        }else{
            fieldValue = @"Female";
        }
        //Set the value in the Cell TextField:
        [(VMNSocialMediaTextfieldCell*)[self.tableView cellForRowAtIndexPath:path] setTextValueForField: fieldValue];
        //Set the value in the Form values array
        [self.textFieldProto setObject:fieldValue forKey:[[self.labels objectAtIndex:_fieldBeingEdited]lowercaseString]];
    } else if ([fieldType isEqualToString:@"Birthday"]){
        NSString *fieldValue = [(VMNSocialMediaTextfieldCell*)[self.tableView cellForRowAtIndexPath:path] getTextValueForField];
        [self.textFieldProto setObject:fieldValue forKey:[[self.labels objectAtIndex:_fieldBeingEdited]lowercaseString]];
    }else{
        // It's Terms and Conditions
        
        NSMutableDictionary *checkBoxes = [tocCheckBoxes objectAtIndex:_termsAndConditionsBeingViewed];
        
        int index = 0;
        for (id option in [checkBoxes objectForKey:@"links"]){
            
            if (buttonIndex == index){
//                NSLog(@"open url for link %@", [option valueForKey:@"url"]);
                browserView = [[VMNSocialMediaBrowserView alloc] initWithFrame:self.parentViewController.view.frame url:[NSURL URLWithString:[option valueForKey:@"url"]] delegate:self];
//                [browserView setColor:[UIColor blueColor]];
                [self.parentViewController.view addSubview:browserView];
                [browserView release];
            }
            index+=1;
        }
        
//        NSString *fieldValue = [(VMNSocialMediaTextfieldCell*)[self.tableView cellForRowAtIndexPath:path] getTextValueForField];
//        [self.textFieldProto setObject:fieldValue forKey:[[self.labels objectAtIndex:_fieldBeingEdited]lowercaseString]];
    }
}

- (void)closeBrowser:(VMNSocialMediaBrowserView *)_browserView {
	[_browserView removeFromSuperview];
}

- (void)closeView{
    if ([_delegate respondsToSelector:@selector(closeForm)]) {
        [_delegate closeForm];
    }
    if (!NSClassFromString(@"UISplitViewController") != nil && !UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.view removeFromSuperview];
    }
}

- (void)didSelectCountry:(NSString *)country{
//    NSLog(@"didSelectCountry %@", country);
    NSIndexPath* path = [NSIndexPath indexPathForRow:_fieldBeingEdited inSection:0];
    [(VMNSocialMediaTextfieldCell*)[self.tableView cellForRowAtIndexPath:path] setTextValueForField: country];
    [self.textFieldProto setObject:country forKey:[[self.labels objectAtIndex:_fieldBeingEdited]lowercaseString]];
}

-(void)label:(VMNSocialMediaGLTapLabel *)label didSelectedHotWord:(NSString *)w
{
}

@end
