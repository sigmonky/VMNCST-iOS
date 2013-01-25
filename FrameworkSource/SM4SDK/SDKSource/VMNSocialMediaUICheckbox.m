#import "VMNSocialMediaUICheckbox.h"


@implementation VMNSocialMediaUICheckbox
@synthesize checked;


-(id)initWithFrame:(CGRect)frame{
    
    if(self == [super initWithFrame:frame]){
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"VMNSocialMedia_uicheckbox_unchecked" ofType:@"png"];
//
//        UIImage *image  = [[UIImage alloc] initWithContentsOfFile:imagePath];
//        [self setImage:image forState:UIControlStateNormal];

        [self setImage:[UIImage imageWithContentsOfFile:[[[self class] frameworkBundle] pathForResource:@"VMNSocialMedia_uicheckbox_unchecked" ofType:@"tiff"]] forState:UIControlStateNormal];
        
        [self addTarget:self action:@selector(checkBoxClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
    
}

-(IBAction)checkBoxClicked{
    
    if(self.checked == NO)
    {
        self.checked = YES;
//        [self setImage:[UIImage imageNamed:@"VMNSocialMedia_uicheckbox_checked.png"] forState:UIControlStateNormal];

        [self setImage:[UIImage imageWithContentsOfFile:[[[self class] frameworkBundle] pathForResource:@"VMNSocialMedia_uicheckbox_checked" ofType:@"tiff"]] forState:UIControlStateNormal];
    }
    else{
        self.checked = NO;
//        [self setImage:[UIImage imageNamed:@"VMNSocialMedia_uicheckbox_unchecked.png"] forState:UIControlStateNormal];
//        
//        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"VMNSocialMedia_uicheckbox_unchecked" ofType:@"png"];
//        
//        UIImage *image  = [[UIImage alloc] initWithContentsOfFile:imagePath];
//        [self setImage:image forState:UIControlStateNormal];
        
        [self setImage:[UIImage imageWithContentsOfFile:[[[self class] frameworkBundle] pathForResource:@"VMNSocialMedia_uicheckbox_unchecked" ofType:@"tiff"]] forState:UIControlStateNormal];
    }
    
}

// Load the framework bundle.
+ (NSBundle *)frameworkBundle {
    static NSBundle* frameworkBundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSString* mainBundlePath = [[NSBundle mainBundle] resourcePath];
        NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"VMNSocialMediaSDKResources.bundle"];
        frameworkBundle = [[NSBundle bundleWithPath:frameworkBundlePath] retain];
    });
    return frameworkBundle;
}

-(void) dealloc{
    [super dealloc];
}

@end