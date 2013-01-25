#import "VMNSocialMediaRequest.h"

#define HTTP_METHOD_GET @"GET"
#define HTTP_METHOD_POST @"POST"

//#define FLUX_URL @"http://daapiak.flux.com/"
#define FLUX_URL @"http://daapiak.flux-staging.com/"
#define ZCONNECT_URL @"https://stage-connector-w.zeebox.com/connector/"
#define ZGATEWAY_URL @"https://stage-zgateway-w.zeebox.com/lmg/"

NSString* kErrorDomain = @"com.mtvn.flux";

@interface VMNSocialMediaRequest()
{
    
}

- (NSURLRequest *)_buildRequest;

@end

@implementation VMNSocialMediaRequest

@synthesize parameters = _parameters;
@synthesize requestMethod = _requestMethod;
@synthesize accessString = _accessString;
@synthesize options = _options;
@synthesize serviceProvider = _serviceProvider;

- (id)initWithParams:(NSDictionary *)parameters requestMethod:(RequestMethod)requestMethod accessString:(NSString *)accessString
{
    self = [super init];
    if (self) {
        self.parameters = parameters;
        self.requestMethod = requestMethod;
        self.accessString = accessString;
    }
    return self;
}

- (id)initWithServiceProvider:(ServiceProvider)serviceProvider params:(NSDictionary *)parameters options:(NSDictionary *)options requestMethod:(RequestMethod)requestMethod accessString:(NSString *)accessString
{
    self = [super init];
    if (self) {
        self.parameters = parameters; /* GET/POST parameters */
        self.options = options; /* Request content type, ucid, api version, output format*/
        self.requestMethod = requestMethod; /* GET/POST */
        self.accessString = accessString; /* Custom Method */
        self.serviceProvider = serviceProvider;
    }
    return self;
}



- (NSURLRequest *)_buildRequest
{
    NSString *method;
    
    switch (_requestMethod) {
        case RequestMethodPOST:
            method = HTTP_METHOD_POST;
            break;
        case RequestMethodGET:
        default:
            method = HTTP_METHOD_GET;
    }
    
    NSMutableString *urlString;
    
    //REST SERVICE API VERSION
    NSString *apiVersion = [_options objectForKey:@"version"];
    
    //XML/JSON
    NSString *outputFormat = [_options objectForKey:@"output"];
    
    
    //getCookies
    NSString *cookie = [_options objectForKey:@"cookie"];

    
    //FLUX COMMUNITY ID
    NSString *ucid = [_options objectForKey:@"ucid"];

    switch (_serviceProvider) {
        case Flux:;
            urlString = [NSMutableString stringWithFormat:@"%@%@%@%@/%@", FLUX_URL, apiVersion, outputFormat, ucid, self.accessString];
            break;
        case ZConnect:;
            urlString = [NSMutableString stringWithFormat:@"%@%@/%@", ZCONNECT_URL, apiVersion, self.accessString];
            break;
        case ZGateway:;
            urlString = [NSMutableString stringWithFormat:@"%@%@/%@", ZGATEWAY_URL, apiVersion, self.accessString];
            break;
        case Other:
            urlString = [NSMutableString stringWithFormat:@"%@", [self.options objectForKey:@"request_url"]];
            break;
        default:
            urlString = [NSMutableString stringWithFormat:@"%@%@%@%@/%@", FLUX_URL, apiVersion, outputFormat, ucid, self.accessString];
            break;
    }
    
    
    //GET REQUEST: BUILD QUERY STRING
    if (RequestMethodGET == _requestMethod) {
        int counter = 0;
        for (NSString *key in [self.parameters allKeys]) {
                if (!counter) {
                    [urlString appendString:@"?"];
                } else {
                    [urlString appendString:@"&"];
                }
                ++counter;
                [urlString appendFormat:@"%@=%@", key, [self.parameters objectForKey:key]];
        }
    }
    
    
    //Verify if Zbox token is present
    
    
    if ([self.options objectForKey:@"access_token"] != nil){
        [urlString appendFormat:@"?access_token=%@", [self.options objectForKey:@"access_token"]];
    }
    
    //BUILD URL FOR REQUEST OBJECT
    NSURL *requestURL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
    [request setHTTPMethod:method];
    
    //SET REQUEST TYPE
    NSString *contentType = [self.options objectForKey:@"contentType"];
    
    if ([contentType isEqualToString:@"json"]) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }else if([contentType isEqualToString:@"xml"]){
        [request setValue:@"text/xml" forHTTPHeaderField:@"Content-type"];
    }else if([contentType isEqualToString:@"url_encoded"]){
        [request setValue:@"x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    }
    

    // POST REQUEST: SET POST BODY
    if (RequestMethodPOST == _requestMethod) {
        
        NSMutableString *requestBody;

        if ([contentType isEqualToString:@"json"]){
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.parameters
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&error];
            
            NSString *jsonContent = [[NSString alloc] initWithData:jsonData
                                                     encoding:NSUTF8StringEncoding];
            
//            NSLog(@"request POST body %@", jsonContent);
            requestBody = [[NSMutableString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }else if([contentType isEqualToString:@"url_encoded"]){
            
            // CHECK MEMORY LEAK OF requestBody
            
            requestBody = [[[NSMutableString alloc] init] autorelease];
            int counter = 0;
            for (NSString *key in [self.parameters allKeys]) {
                if (!counter) {
                    //
                } else {
                    [urlString appendString:@"&"];
                }
                ++counter;
                [requestBody appendFormat:@"%@=%@", key, [self.parameters objectForKey:key]];
            }
        }else if([contentType isEqualToString:@"xml"]){
            requestBody = [[[NSMutableString alloc] init] autorelease];
            [requestBody appendFormat:@"%@", [self.parameters objectForKey:@"requestBody"]];
        }
        

        
        [request setValue:[NSString stringWithFormat:@"%d", [requestBody length]] forHTTPHeaderField:@"Content-length"];
        
        [request setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (cookie != nil){
        //Set Flux Cookie
        
        
        NSString *flux_url;
        
        if ([self.options objectForKey:@"request_url"] != nil){
            flux_url = @"http://daapi.flux.com/";
        }else{
            flux_url = FLUX_URL;
        }
        
        
        NSURL *_server_url = [NSURL URLWithString:flux_url];
        
        // creation the cookie
        NSHTTPCookie *cook = [NSHTTPCookie cookieWithProperties:
                              [NSDictionary dictionaryWithObjectsAndKeys:
                               [_server_url host], NSHTTPCookieDomain,
                               [_server_url path], NSHTTPCookiePath,
                               @"RtxAuth2407",  NSHTTPCookieName,
                               cookie, NSHTTPCookieValue,
                               nil]];
        
        // Posting the cookie
        
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cook];
        
    }
    
    NSLog(@"request URL: %@", urlString);
    return request;
}

- (void)performRequestWithHandler:(SMRequestHandler)handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:[self _buildRequest] returningResponse:&response error:&error];
        handler(data, response, error);
    });
}

- (void)performZBoxRequestWithHandler:(SMRequestHandler)handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:[self _buildZBoxRequest] returningResponse:&response error:&error];
        handler(data, response, error);
    });
}

- (void)dealloc{
    self.parameters = nil;
    self.accessString = nil;
    self.options = nil;
    [super dealloc];
}

@end
