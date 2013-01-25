#import "VMNSocialMediaTwitterReverseAuthManager.h"
#import <Twitter/Twitter.h>

//Twitter Reverse Auth Stuff
#define TW_X_AUTH_MODE_KEY                  @"x_auth_mode"
#define TW_X_AUTH_MODE_REVERSE_AUTH         @"reverse_auth"
#define TW_X_AUTH_MODE_CLIENT_AUTH          @"client_auth"
#define TW_X_AUTH_REVERSE_PARMS             @"x_reverse_auth_parameters"
#define TW_X_AUTH_REVERSE_TARGET            @"x_reverse_auth_target"
#define TW_X_AUTH_USERNAME                  @"x_auth_username"
#define TW_X_AUTH_PASSWORD                  @"x_auth_password"
#define TW_SCREEN_NAME                      @"screen_name"
#define TW_USER_ID                          @"user_id"
#define TW_OAUTH_URL_REQUEST_TOKEN          @"https://api.twitter.com/oauth/request_token"
#define TW_OAUTH_URL_AUTH_TOKEN             @"https://api.twitter.com/oauth/access_token"


static VMNSocialMediaTwitterReverseAuthManager *sharedInstance = nil;

@implementation VMNSocialMediaTwitterReverseAuthManager

@synthesize delegate = _delegate;
/**
 Method that returns the DataManager Singleton Object
 */
+ (VMNSocialMediaTwitterReverseAuthManager *)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
            sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

+ (id) allocWithZone:(NSZone *)zone {
    return [[self sharedInstance] retain];
}

- (id) copyWithZone:(NSZone*)zone {
    return self;
}

- (id) retain {
    return self;
}

- (NSUInteger) retainCount {
    return NSUIntegerMax; // denotes an object that cannot be released
}

- (void) release {
    // do nothing
}

- (id) autorelease {
    return self;
}


#pragma mark Twitter Reverse Auth

- (void)performReverseAuth:(id)account{
    //  Check to make sure that the user has added his credentials
    if (1==1) {
        //
        //  Step 1)  Ask Twitter for a special request_token for reverse auth
        //
        NSURL *url = [NSURL URLWithString:TW_OAUTH_URL_REQUEST_TOKEN];
        
        // "reverse_auth" is a required parameter
        NSDictionary *dict = [NSDictionary dictionaryWithObject:TW_X_AUTH_MODE_REVERSE_AUTH forKey:TW_X_AUTH_MODE_KEY];
        VMNSocialMediaTwitterSignedRequest *signedRequest = [[VMNSocialMediaTwitterSignedRequest alloc] initWithURL:url parameters:dict requestMethod:TWSignedRequestMethodPOST];
        
        [signedRequest performRequestWithHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!data) {
                //                NSLog(@"Session - performReverseAuth: Unable to receive a request_token.");
                [_delegate reverseAuthDidFailWithError:error];
                [self _handleError:error forResponse:response];
            }
            else {
                NSString *signedReverseAuthSignature = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                //
                //  Step 2)  Ask Twitter for the user's auth token and secret
                //           include x_reverse_auth_target=CK2 and x_reverse_auth_parameters=signedReverseAuthSignature parameters
                //
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    NSLog(@"[VMNSocialMediaTwitterSignedRequest consumerKey] %@", [VMNSocialMediaTwitterSignedRequest consumerKey]);
                    
                     NSLog(@"[VMNSocialMediaTwitterSignedRequest consumerSecret] %@", [VMNSocialMediaTwitterSignedRequest consumerSecret]);
                    
                    NSDictionary *step2Params = [NSDictionary dictionaryWithObjectsAndKeys:[VMNSocialMediaTwitterSignedRequest consumerKey], TW_X_AUTH_REVERSE_TARGET, signedReverseAuthSignature, TW_X_AUTH_REVERSE_PARMS, nil];
                    NSURL *authTokenURL = [NSURL URLWithString:TW_OAUTH_URL_AUTH_TOKEN];
                    TWRequest *step2Request = [[TWRequest alloc] initWithURL:authTokenURL parameters:step2Params requestMethod:TWRequestMethodPOST];
                    
                    [step2Request setAccount:account];
                    [step2Request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        // Thanks to Marc Delling for pointing out that we should check the status code below
                        if (!responseData || ((NSHTTPURLResponse*)response).statusCode >= 400) {
                            //NSLog(@"Session - performReverseAuth: Error occurred in Step 2.  Check console for more info.");
                            [self _handleError:error forResponse:response];
                        }
                        else {
                            NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                            [self _handleStep2Response:responseStr];
                        }
                    }];
                });
            }
        }];
    }
}


- (void)_handleError:(NSError *)error forResponse:(NSURLResponse *)response
{
    //    NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
    //    NSLog(@"[Error]: %@", [error localizedDescription]);
    //    NSLog(@"[Error]: Response Code:%d \"%@\" ", [urlResponse statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[urlResponse statusCode]]);
    [_delegate reverseAuthDidFailWithError:error];

}


#define RESPONSE_EXPECTED_SIZE 4

- (void)_handleStep2Response:(NSString *)responseStr
{
    NSLog(@"responseStr %@", responseStr);
    NSDictionary *dict = [NSURL ab_parseURLQueryString:responseStr];
    
//    NSLog(@"count dict %d", [dict count]);
    // We are expecting a response dict of the format:
    //
    // {
    //     "oauth_token" = ...
    //     "oauth_token_secret" = ...
    //     "screen_name" = ...
    //     "user_id" = ...
    // }
    
    NSLog(@"Reverse Auth Response: %@", dict);
    
    if ([dict count] == RESPONSE_EXPECTED_SIZE) {
        [VMNSocialMediaTwitterUtils storeLocalCredentialsWithAccessToken:[dict objectForKey:@"oauth_token"] accessTokenSecret:[dict objectForKey:@"oauth_token_secret"]];
        [_delegate reverseAuthDidSucceed];
    }
    else {
        NSMutableDictionary *details = [NSMutableDictionary dictionary];
        [details setValue:@"The response from Twitter Reverse Auth doesn't seem correct. " forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        NSError *error = [NSError errorWithDomain:@"twitter.auth.error" code:41 userInfo:details];
        [_delegate reverseAuthDidFailWithError:error];
    }
    
}
@end
