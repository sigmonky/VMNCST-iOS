/**
 
 VMNSocialMediaUser
 
 
 */

#import "VMNSocialMediaUser.h"

//static VMNSocialMediaUser *sharedInstance = nil;

//Use a macro to define the file name. This will ensure that you always look for the correct file.
#define FILE_NAME   @"UserInfo"

@implementation VMNSocialMediaUser

@synthesize fluxProfile = _fluxProfile;
@synthesize zeeBoxProfile = _zeeBoxProfile;

- (id) init{
    if (self = [super init])
	{
        //Find the path to the file that contains the data of a saved User object.
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *directory = [paths objectAtIndex:0];
        
        NSString *path = [[NSString alloc] initWithFormat:@"%@/%@", directory, FILE_NAME];
        
        //Check and see if the file exists
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            //If the file exist call [self release] to release the current instance of the User object and replace it with the
            //the one that is saved on the device.
            [self release];
            
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:[NSData dataWithContentsOfFile:path]];
            
            self = [[VMNSocialMediaUser alloc] initWithCoder:unarchiver];
            
            [unarchiver finishDecoding];
            [unarchiver release];
        }
        else {
        }
        [path release];
	}
    return self;
}

#pragma mark - NSCoding implementation for singleton

- (id)initWithCoder:(NSCoder *)decoder {
	if(self = [super init]) {
        self.fluxProfile = [decoder decodeObjectForKey:@"fluxProfile"];
        self.zeeBoxProfile = [decoder decodeObjectForKey:@"zeeBoxProfile"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    // Archive the singleton instance.
    [aCoder encodeObject:self.fluxProfile forKey:@"fluxProfile"];
    [aCoder encodeObject:self.zeeBoxProfile forKey:@"zeeBoxProfile"];
}


- (void)dealloc{
    [super dealloc];
    self.zeeBoxProfile = nil;
    self.fluxProfile = nil;
}


@end
