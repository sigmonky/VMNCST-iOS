#import <Foundation/Foundation.h>
#import "VMNSocialMediaTwitterLoginProtocols.h"
#import "VMNSocialMediaTwitterUtils.h"

@interface VMNSocialMediaTwitterReverseAuthManager : NSObject{
    id<SMTwitterReverseAuthDelegate> _delegate;
}
    
@property (nonatomic,assign) id<SMTwitterReverseAuthDelegate> delegate;
+ (VMNSocialMediaTwitterReverseAuthManager *)sharedInstance;
- (void)performReverseAuth:(id)account;
- (void)performReverseAuth:(id)account completion:(void (^)(NSError *err))completion;
- (void)_handleError:(NSError *)error forResponse:(NSURLResponse *)response;
- (void)_handleStep2Response:(NSString *)responseStr;

@end
