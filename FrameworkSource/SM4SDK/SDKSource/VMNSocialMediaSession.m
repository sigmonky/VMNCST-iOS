#import "VMNSocialMediaSession.h"
#import "VMNSocialMediaRequest.h"
#import "VMNSocialMediaRequestCodes.h"
#import "VMNSocialMediaSettingsUtils.h"
#import "VMNSocialMediaConstants.h"

// External Dependencies
#import "OAuth+Additions.h"
#import "JSONKit.h"

#define FLUX_API_VERSION_2 @"2.0/00001/"

#define ZGATEWAY_API_VERSION @"1"

#define VMNSOCIAL_MEDIA_API_VERSION @"1";

static VMNSocialMediaSession *sharedInstance = nil;

@interface VMNSocialMediaSession()

- (BOOL)_checkForLocalCredentials;
- (BOOL)_checkForKeys;
- (void)_handleError:(NSError *)error forResponse:(NSURLResponse *)response;
- (void)_handleStep2Response:(NSString *)responseStr;

@end

@implementation VMNSocialMediaSession

@synthesize currentUser = _currentUser,
delegate = _delegate;


+ (VMNSocialMediaSession *)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil){
            sharedInstance = [[super allocWithZone:NULL] init];
        }
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


- (void)dealloc {
    [super dealloc];
}

- (NSString *)tempFilePath {
    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                           inDomains:NSUserDomainMask];
    NSString *documentDirPath = [[urls objectAtIndex:0] path];
    return [documentDirPath stringByAppendingPathComponent:@"userObject"];
}


-(id)initWithDelegate:(id<VMNSocialMediaSessionDelegate>)delegate {
//    self = [super init];
//    if (self) {
        self.delegate = delegate;
        self.currentUser = [[VMNSocialMediaUser alloc] init];
        VMNSocialMediaUser *userObj = [NSKeyedUnarchiver unarchiveObjectWithFile:[self tempFilePath]];
        //    NSLog(@"user obj from NSKeyedUnarchiver: %@", userObj);
        if (userObj == nil){
            [NSKeyedArchiver archiveRootObject:self.currentUser toFile:[self tempFilePath]];
        }else{
            self.currentUser = userObj;
        }
//    }
    return sharedInstance;
}


-(void)authenticateWithFluxUserName:(NSString *)userName password:(NSString *)password completion:(void (^)(NSError *err))completion{
    
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init]autorelease];
    
    NSString* body = [NSString stringWithFormat:@"<Request><username>%@</username><password>%@</password><authenticateonly>false</authenticateonly></Request>", userName, password];
    [params setObject:body forKey:@"requestBody"];
    
    // Create Options Dictionary VMNSocialMediaRequest to login to FLUX backend
    
    //Set the UCID to the QUERY String
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", [VMNSocialMediaSettingsUtils fluxCommunityID]] forKey:@"ucid"];
    
    // Set the API version to the QUERY String
    [options setObject:FLUX_API_VERSION_2 forKey:@"version"];
    
    // Set the output format to the QUERY String
    [options setObject:@"Json/" forKey:@"output"];
    
    // Set Request content type
    
    [options setObject:@"xml" forKey:@"contentType"];
    
    //Create VMNSocialMediaRequest object to login to FLUX backend
    
    VMNSocialMediaRequest *fluxAuthRequest = [[[VMNSocialMediaRequest alloc] initWithServiceProvider:Flux params:params options:options requestMethod:RequestMethodPOST accessString:@"action/login"] autorelease];
    
    [fluxAuthRequest performRequestWithHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!data) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                completion(error);
            });
        }else{
            NSDictionary *dataDict = [[JSONDecoder decoder] objectWithData:data];
//            NSLog(@"flux login dict %@", dataDict);

            int status = [[dataDict objectForKey:@"Status"] intValue];
            
            //Authenticated with FLUX
            if (status == OK) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self storeFluxCookie];
                    
                    NSString *fluxUserID = [dataDict objectForKey:@"Ucid"];
                    [VMNSocialMediaFluxUtils storeUserID:fluxUserID];
                    
                    [self getFluxUserProfile];

                    [self completeFluxUserSignUp];
                    
                    completion(nil);
                });
                
                // NOT Authenticated with FLUX
            } else {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    NSMutableDictionary* details = [NSMutableDictionary dictionary];
                    [details setValue:[dataDict objectForKey:@"UIFriendlyMessage"] forKey:NSLocalizedDescriptionKey];
                    // populate the error object with the details
                    NSError *error_ = [NSError errorWithDomain:@"com.vmnsocialmedia.session" code:status userInfo:details];
                    completion(error_);
                });
            }
        }
    }];
}


-(void)linkFluxToFacebook:(void (^)(NSError *err))completion{
    
    if ([VMNSocialMediaFacebookUtils hasLocalCredentials]){
        
        //Create Parameters Dictionary VMNSocialMediaRequest to link Facebook account to FLUX backend
        
        //Params: access_token, production_location, device
        //TODO Product_location should come from an Util method
        
        NSString *fbToken = [VMNSocialMediaFacebookUtils accessToken];
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", fbToken] forKey:@"access_token"];
        
        [params setObject:@"mobile" forKey:@"device"];
        
        // Create Options Dictionary VMNSocialMediaRequest to link Facebook account to FLUX backend
        
        //Set the UCID to the QUERY String
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", [VMNSocialMediaSettingsUtils fluxCommunityID]] forKey:@"ucid"];
        
        // Set the API version to the QUERY String
        [options setObject:FLUX_API_VERSION_2 forKey:@"version"];
        
        // Set the output format to the QUERY String
        [options setObject:@"Json/" forKey:@"output"];
        
        // Set Request content type
        
        [options setObject:@"xml" forKey:@"contentType"];
        
        //Create VMNSocialMediaRequest objecvt to link Facebook account to FLUX backend
        VMNSocialMediaRequest *fbAuthRequest = [[[VMNSocialMediaRequest alloc] initWithServiceProvider:Flux params:params options:options requestMethod:RequestMethodGET accessString:@"action/FacebookAuth"] autorelease];
        
        [fbAuthRequest performRequestWithHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            if (!data) {
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:ERROR_LINK_FLUX_TO_FACEBOOK forKey:NSLocalizedDescriptionKey];
                // populate the error object with the details
                NSError *error_ = [NSError errorWithDomain:@"com.vmnsocialmedia.session" code:101 userInfo:details];
                completion(error_);
            }else{
                NSDictionary *dataDict = [[JSONDecoder decoder] objectWithData:data];
                int status = [[dataDict objectForKey:@"Status"] intValue];
                
                // Facebook account linked with Facebook
                if (status == FACEBOOKLOGINCOMPLETE) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        
                        //Get Flux Cookie from the response object and store it locally
                        
                        NSString *fluxCookie = [dataDict objectForKey:@"AuthTicket"];
                        [self storeFluxCookieWithValue:fluxCookie];
                        
                        NSString *fluxUserID = [dataDict objectForKey:@"Ucid"];
                        [VMNSocialMediaFluxUtils storeUserID:fluxUserID];
                        
                        [self getFluxUserProfile];
                        
                        //Connect to Flux to get the remaining fields to complete a user account
                        [self completeFluxUserSignUp];
                        
                        //Connect to Flux to get the remaining fields to complete a user account
                        completion(nil);

                    });
                    
                    //FACEBOOK ACCOUNT ERROR: FB WAS NOT LINKED TO FLUX
                } else {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        NSMutableDictionary *details = [NSMutableDictionary dictionary];
                        [details setValue:[dataDict objectForKey:@"UIFriendlyMessage"] forKey:NSLocalizedDescriptionKey];
                        // populate the error object with the details
                        NSError *error_ = [NSError errorWithDomain:@"com.vmnsocialmedia.session" code:status userInfo:details];
                        completion(error_);
                    });
                }
            }
        }];
        //FACEBOOK ACCOUNT ERROR: FB WAS NOT LINKED TO FLUX
    }else{
//        NSMutableDictionary *details = [NSMutableDictionary dictionary];
//        [details setValue:@"Could not link Facebook account to Flux" forKey:NSLocalizedDescriptionKey];
        
        //Make NSERROR MSG
        completion(nil);
        
    }
}

-(void)linkFluxToTwitter:(void (^)(NSError *err))completion{
    
    if ([VMNSocialMediaTwitterUtils hasLocalCredentials]){
        
        NSString *twToken = [VMNSocialMediaTwitterUtils accessToken];
        //Flux doesn't accept Secret Token
        NSString *twSecretToken = [VMNSocialMediaTwitterUtils accessTokenSecret];
        
        //Create Parameters Dictionary VMNSocialMediaRequest to link Twitter account to FLUX backend
        
        //Params: access_token, production_location, device
        //TODO Product_location should come from an Util method
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", twToken] forKey:@"access_token"];
        [params setObject:[VMNSocialMediaSettingsUtils fluxCommunityID] forKey:@"ucid"];
        [params setObject:twSecretToken forKey:@"access_secret_token"];
        
        [params setObject:@"mobile" forKey:@"device"];
        
        // Create Options Dictionary VMNSocialMediaRequest to link Twitter account to FLUX backend
        
        //Set the UCID to the QUERY String
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", [VMNSocialMediaSettingsUtils fluxCommunityID]] forKey:@"ucid"];
        
        // Set the API version to the QUERY String
        [options setObject:FLUX_API_VERSION_2 forKey:@"version"];
        
        // Set the output format to the QUERY String
        [options setObject:@"Json/" forKey:@"output"];
        
        // Set Request content type
        
        [options setObject:@"xml" forKey:@"contentType"];
        
        //Create VMNSocialMediaRequest objecvt to link Facebook account to FLUX backend
        VMNSocialMediaRequest *twAuthRequest = [[[VMNSocialMediaRequest alloc] initWithServiceProvider:Flux params:params options:options requestMethod:RequestMethodGET accessString:@"action/TwitterAuth"] autorelease];
        
        [twAuthRequest performRequestWithHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!data) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    NSMutableDictionary* details = [NSMutableDictionary dictionary];
                    [details setValue:ERROR_LINK_FLUX_TO_TWITTER forKey:NSLocalizedDescriptionKey];
                    // populate the error object with the details
                    NSError *error_ = [NSError errorWithDomain:@"com.vmnsocialmedia.session" code:102 userInfo:details];
                    completion(error_);
                });
            }else{
                
                NSDictionary *dataDict = [[JSONDecoder decoder] objectWithData:data];
                int status = [[dataDict objectForKey:@"Status"] intValue];
                
                // Twitter account was linked to Flux
                
                if (status == TWITTERLOGINCOMPLETE) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        
                        //Get Flux Cookie from the response object and store it locally
                        
                        NSString *fluxCookie = [dataDict objectForKey:@"AuthTicket"];
                        [self storeFluxCookieWithValue:fluxCookie];
                        
                        //Cookie is still not being set in the response
//                        [VMNSocialMediaFluxUtils storeLocalCredentials];
                        
                        NSString *fluxUserID = [dataDict objectForKey:@"Ucid"];
                        [VMNSocialMediaFluxUtils storeUserID:fluxUserID];
                        
                        
                        [self getFluxUserProfile];

                        //Connect to Flux to get the remaining fields to complete a user account
                        [self completeFluxUserSignUp];
                        
                        completion(nil);
                    });
                    
                    // Twitter account was NOT linked to Flux
                    
                } else {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        
                        NSMutableDictionary *details = [NSMutableDictionary dictionary];
                        [details setValue:[dataDict objectForKey:@"UIFriendlyMessage"] forKey:NSLocalizedDescriptionKey];
                        // populate the error object with the details
                        NSError *error_ = [NSError errorWithDomain:@"com.vmnsocialmedia.session" code:status userInfo:details];
                        completion(error_);
                        
                        
                    });
                }
            }
        }];
    }else{
        
        // Twitter account was NOT linked to Flux
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            NSMutableDictionary *details = [NSMutableDictionary dictionary];
            [details setValue:ERROR_LINK_FLUX_TO_TWITTER forKey:NSLocalizedDescriptionKey];
            // populate the error object with the details
            NSError *error_ = [NSError errorWithDomain:@"com.vmnsocialmedia.session" code:103 userInfo:details];
            completion(error_);
        });
    }
}

- (NSString *)getToken:(SocialNetworkName)socialNetworkName{
    NSString *token;
    if (socialNetworkName == TWITTER){
        token = [VMNSocialMediaTwitterUtils accessToken];
    }else{
        //Facebook
        token = [VMNSocialMediaFacebookUtils accessToken];
    }
    return token;
}


-(void)linkToZeeBox:(SocialNetworkName)socialNetworkName
         completion:(void (^)(NSError *err))completion{
    
    
    NSString *token = [self getToken:socialNetworkName];
    
    NSMutableDictionary *zBoxparams = [NSMutableDictionary
                                       dictionaryWithObject:token forKey:@"token"];
    
    NSMutableDictionary *originArgs = [NSMutableDictionary
                                       dictionaryWithObjectsAndKeys:@"mtvi.com",@"domain",@"cia", @"platform"
                                       , @"default", @"macro_region", @"us", @"tvc", nil];
    
    if (socialNetworkName == TWITTER){
        //ZeeBox provider is Twitter
        NSString *twSecretToken = [VMNSocialMediaTwitterUtils
                                   accessTokenSecret];
        [zBoxparams setObject:twSecretToken forKey:@"secret"];
        [zBoxparams setObject:@"twitter" forKey:@"provider"];
    }else{
        //ZeeBox provider is Facebook
        [zBoxparams setObject:@"facebook" forKey:@"provider"];
    }
    
    
    //Create Options Dictionary VMNSocialMediaRequest to link
   // Facebook account to ZBox backend
    NSMutableDictionary *options = [NSMutableDictionary
                                    dictionaryWithObject:@"json" forKey:@"contentType"];
    
    // Set the API version to the QUERY String
    [options setObject:ZGATEWAY_API_VERSION forKey:@"version"];
    
    //Verify if there's an existing Zeebox token to the user account
    
    VMNSocialMediaRequest *zBoxRequest;
    
    if ([VMNSocialMediaZBoxUtils hasLocalCredentials] == TRUE){
        // add the social network account to existing zeebox account
        
        [zBoxparams setObject:@"1.0" forKey:@"version"];
        [options setObject:[VMNSocialMediaZBoxUtils accessToken]
                    forKey:@"access_token"];
        [zBoxparams setObject:@"true" forKey:@"merge"];
        
        zBoxRequest = [[[VMNSocialMediaRequest alloc]
                        initWithServiceProvider:ZGateway params:zBoxparams options:options
                        requestMethod:RequestMethodPOST accessString:@"connect"] autorelease];
        
    }else{
        // connect to zeebox and retrieve a zeebox token
        [zBoxparams setObject:originArgs forKey:@"origin"];
        [zBoxparams setObject:@"1.0" forKey:@"version"];
        zBoxRequest = [[[VMNSocialMediaRequest alloc]
                        initWithServiceProvider:ZGateway params:zBoxparams options:options
                        requestMethod:RequestMethodPOST accessString:@"login"] autorelease];
    }
    
    
    [zBoxRequest performRequestWithHandler:^(NSData *data,
                                             NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        int responseStatusCode = [httpResponse statusCode];
//        NSLog(@"zbox data %@", data);
        //NSLog(@"zbox error %@", error);
//        NSLog(@"zbox response %d", responseStatusCode);
        
        if (responseStatusCode == 200){
            // Store ZBox Access Token
            NSDictionary *dataDict = [[JSONDecoder decoder]
                                      objectWithData:data];
            NSString *zBoxAccessToken = [dataDict
                                         objectForKey:@"access_token"];
//            NSLog(@"zbox access token %@", zBoxAccessToken);
            dispatch_sync(dispatch_get_main_queue(), ^{
                //Got Zeebox token
                [VMNSocialMediaZBoxUtils
                 storeLocalCredentials:zBoxAccessToken];
                [self getZBoxUserProfile];
                completion(nil);
            });
        }else if(responseStatusCode == 201 || responseStatusCode == 410){
            // Successfully merged account to ZeeBox user
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self getZBoxUserProfile];
                completion(nil);
            });
        }else{
            dispatch_sync(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
    }];
}

- (void)submitFluxRegistrationInfo:(NSMutableDictionary *)formValues completion:(void (^)(NSMutableDictionary *response))completion{
    
    NSMutableDictionary *params = formValues;
    
    //Set the UCID to the QUERY String
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", [VMNSocialMediaSettingsUtils fluxCommunityID]] forKey:@"ucid"];
    
    // Set the API version to the QUERY String
    [options setObject:FLUX_API_VERSION_2 forKey:@"version"];
    
    
    //Check for flux cookie
    
    BOOL hasFluxCookie = [[VMNSocialMediaSession sharedInstance]hasFluxLocalCredentials];
    NSString *accessString;
    
    if (hasFluxCookie){
        // User exists in FLUX, just need to fill out additional info required by a Community
        // Set the Flux Cookie for the Request
        [options setObject:[VMNSocialMediaFluxUtils fluxCookie] forKey:@"cookie"];
        accessString = @"Action/CompleteAccount";
    }else{
        // Registering a Flux User
        accessString = @"Action/Signup";
//        accessString = @"Action/CompleteAccount";
    }
    
    // Set the output format to the QUERY String
    [options setObject:@"Json/" forKey:@"output"];
    
    [options setObject:@"json" forKey:@"contentType"];
    
    VMNSocialMediaRequest *fluxRequest = [[[VMNSocialMediaRequest alloc] initWithServiceProvider:Flux params:params options:options requestMethod:RequestMethodPOST accessString:accessString] autorelease];
    
    [fluxRequest performRequestWithHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (!data) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:ERROR_REGISTER_FLUX_USER forKey:NSLocalizedDescriptionKey];
                // populate the error object with the details
//                NSError *error_ = [NSError errorWithDomain:@"com.vmnsocialmedia.session" code:15 userInfo:details];
//                NSLog(@"error %@", error);
                completion(details);
            });
        }else{
            dispatch_sync(dispatch_get_main_queue(), ^{
//                NSLog(@"data dict %@", data);
                NSMutableDictionary *dataDict = [[JSONDecoder decoder] objectWithData:data];
//                NSLog(@"dataDict %@", dataDict);
                completion(dataDict);
            });
        }
    }];
}

- (void)getFluxUserProfile{
    
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", [VMNSocialMediaSettingsUtils fluxCommunityID]] forKey:@"ucid"];
    
    // Set the API version to the QUERY String
    [options setObject:FLUX_API_VERSION_2 forKey:@"version"];
    
    // Set the output format to the QUERY String
    [options setObject:@"Json/" forKey:@"output"];
    
    // Set Request content type
    
    [options setObject:@"xml" forKey:@"contentType"];
    
    // Set the API version to the QUERY String
    [options setObject:[VMNSocialMediaFluxUtils fluxCookie] forKey:@"cookie"];
    
    //Todo: Get my Flux ID from response object when linking social media account to Flux
    NSString *myFluxUserID = [VMNSocialMediaFluxUtils userID];
    
    NSString *accessString = [NSString stringWithFormat:@"feeds/people/0%@", myFluxUserID];
    
    VMNSocialMediaRequest *fluxRequest = [[[VMNSocialMediaRequest alloc] initWithServiceProvider:Flux params:nil options:options requestMethod:RequestMethodGET accessString:accessString] autorelease];
    
        [fluxRequest performRequestWithHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!data) {
                // Handle error from getting Flux user profile
            }else{
                NSString *response = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//                NSLog(@"flux profile data string:  %@", response);
                NSDictionary *dataDict = [[JSONDecoder decoder] objectWithData:data];
                [self.currentUser setFluxProfile:dataDict];
                [self saveUser];
//                NSLog(@"flux profile data dict %@", dataDict);
            }
        }];
    
}

- (void)saveUser{
    [NSKeyedArchiver archiveRootObject:self.currentUser toFile:[self tempFilePath]];
}

- (void)getZBoxUserProfile{
//    NSLog(@"getZBoxUserProfile");
    ///connect to ZBOX and retrieve the token
    if ([VMNSocialMediaZBoxUtils accessToken]  != nil){
    
        NSMutableDictionary *zBoxparams = [NSMutableDictionary dictionaryWithObject:@"1" forKey:@"settings"];
        
        [zBoxparams setObject:[VMNSocialMediaZBoxUtils accessToken] forKey:@"access_token"];
        
        //Create Options Dictionary VMNSocialMediaRequest to link Facebook account to ZBox backend
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObject:@"json" forKey:@"contentType"];
        
        // Set the API version to the QUERY String
        [options setObject:ZGATEWAY_API_VERSION forKey:@"version"];
        
        VMNSocialMediaRequest *zBoxRequest = [[[VMNSocialMediaRequest alloc] initWithServiceProvider:ZConnect params:zBoxparams options:options requestMethod:RequestMethodGET accessString:@"me"] autorelease];
        
        [zBoxRequest performRequestWithHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            int responseStatusCode = [httpResponse statusCode];
            
            //todo handle status code
            
            NSDictionary *dataDict = [[JSONDecoder decoder] objectWithData:data];
//            NSLog(@"zbox profile data %d", responseStatusCode);
//            NSLog(@"zbox profile data %@", dataDict);
            [self.currentUser setZeeBoxProfile:dataDict];
            [self saveUser];
        }];
    }
}



- (void)completeFluxUserSignUp{
    
    //http://daapi.flux.com/2.0/00001/<JSON or XML>/<COMMUNITY UCID>/feeds/requireddata/
    
//    NSLog(@"completeFluxUserSignUp flux cookie %@", [VMNSocialMediaFluxUtils fluxCookie]);
    
    //Create VMNSocialMediaRequest object to retrieve required data for a Flux community
    
    //Set the UCID to the QUERY String
    NSMutableDictionary *options_flux_reg = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", [VMNSocialMediaSettingsUtils fluxCommunityID]] forKey:@"ucid"];
    
    // Set the API version to the QUERY String
    [options_flux_reg setObject:FLUX_API_VERSION_2 forKey:@"version"];
    
    // Set the output format to the QUERY String
    [options_flux_reg setObject:@"Json/" forKey:@"output"];
    
    // Set Request content type
    
    [options_flux_reg setObject:@"xml" forKey:@"contentType"];
    
    // TESTING LOCALLY
//    [options_flux_reg setObject:@"http://mtvnmobile.mtvnservices-d.mtvi.com/proto/sm4/flux_registration2.json" forKey:@"request_url"];
    
//    VMNSocialMediaRequest *completeRegRequest = [[[VMNSocialMediaRequest alloc] initWithServiceProvider:Other params:nil options:options_flux_reg requestMethod:RequestMethodGET accessString:nil] autorelease];
    
    // Set the API version to the QUERY String
    
    if ([VMNSocialMediaFluxUtils hasLocalCredentials]){
        [options_flux_reg setObject:[VMNSocialMediaFluxUtils fluxCookie] forKey:@"cookie"];
    }
    
    VMNSocialMediaRequest *completeRegRequest = [[[VMNSocialMediaRequest alloc] initWithServiceProvider:Flux params:nil options:options_flux_reg requestMethod:RequestMethodGET accessString:@"feeds/requireddata"] autorelease];

    [completeRegRequest performRequestWithHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        int responseStatusCode = [httpResponse statusCode];
        
        NSDictionary *dataDict = [[JSONDecoder decoder] objectWithData:data];
//        NSLog(@"flux registration %@", dataDict);
        //        NSLog(@"flux registration response %d", responseStatusCode);
        
        //User has successfully authenticated with Flux and now it's time to finish registering
        if (responseStatusCode == 200){
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSMutableArray *fields = [[[NSMutableArray alloc]init] autorelease];
                for(id field in [dataDict objectForKey:@"InputFields"]){
                    [fields addObject:field];
                }
                
//                NSLog(@"completeFluxUserSignUp fields:%@", fields);
                
                NSArray *fieldsArray = [NSArray arrayWithArray:fields];
                if ([self.delegate respondsToSelector:@selector(showFluxSignupFormWithFields:)]) {
                    [self.delegate showFluxSignupFormWithFields:fieldsArray];
                }
            });
        }else{
            if ([self.delegate respondsToSelector:@selector(showFluxSignupFormWithFields:)]) {
                [self.delegate showFluxSignupFormWithFields:nil];
            }
        }
        
    }];
}

#pragma mark Util Methods

- (NSString *)zeeBoxToken{
    return [VMNSocialMediaZBoxUtils accessToken];
}

- (NSString *)facebookToken{
    return [VMNSocialMediaFacebookUtils accessToken];
}

- (NSString *)fluxToken{
    return [VMNSocialMediaFluxUtils fluxCookie];
}

- (BOOL)hasZBoxLocalCredentials{
    return [VMNSocialMediaZBoxUtils hasLocalCredentials]? TRUE : FALSE;
}

- (BOOL)hasFacebookLocalCredentials{
    return [VMNSocialMediaFacebookUtils hasLocalCredentials]? TRUE : FALSE;
}

- (BOOL)hasTwitterLocalCredentials{
    return [VMNSocialMediaTwitterUtils hasLocalCredentials]? TRUE : FALSE;
}

- (BOOL)hasFluxLocalCredentials{
    return [VMNSocialMediaFluxUtils hasLocalCredentials]? TRUE : FALSE;
}

- (void)storeFacebookLocalCredentialsWithAccessToken:(NSString*)accessToken
                                  existingExpiration:(NSDate*)expirationDate {
    [VMNSocialMediaFacebookUtils storeLocalCredentialsWithAccessToken:accessToken expirationDate:expirationDate];
}

- (void)storeFluxCookie{
    [VMNSocialMediaFluxUtils storeLocalCredentials];
}

- (void)storeFluxCookieWithValue:(NSString *)fluxCookieValue{
    [VMNSocialMediaFluxUtils storeLocalCredentialsWithValue:fluxCookieValue];
}


- (void)removeZeeBoxLocalCredentials{
    [VMNSocialMediaZBoxUtils removeLocalCredentials];
}

- (void)removeFacebookLocalCredentials{
    [VMNSocialMediaFacebookUtils removeLocalCredentials];
}

- (void)removeTwitterLocalCredentials{
    [VMNSocialMediaTwitterUtils removeLocalCredentials];
}

- (void)removeFluxLocalCredentials{
    [VMNSocialMediaFluxUtils removeLocalCredentials];
}

- (void)linkToTwitterAppWithConsumerKey:(NSString *)twConsumerKey consumerSecret:(NSString *)twConsumerSecret{
    [VMNSocialMediaTwitterUtils linkToAppWithConsumerKey:twConsumerKey consumerSecret:twConsumerSecret];
}


#pragma mark VMNSocialMediaRequestDelegate

-(void)request:(VMNSocialMediaRequest *)request didFailWithError:(NSError *)error {
}

-(void)request:(VMNSocialMediaRequest *)request didLoad:(NSDictionary *)response {

}

- (NSString *)apiVersion{
    return VMNSOCIAL_MEDIA_API_VERSION;
}

@end
