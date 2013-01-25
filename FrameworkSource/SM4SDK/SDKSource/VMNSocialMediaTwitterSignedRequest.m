//
//    TWSignedRequest.m
//    TWiOS5ReverseAuthExample
//
//    Copyright (c) 2012 Sean Cook
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to
//    deal in the Software without restriction, including without limitation the
//    rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//    sell copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in
//    all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//    IN THE SOFTWARE.
//

// https://dev.twitter.com/discussions/7676

#import "VMNSocialMediaTwitterSignedRequest.h"
#import "VMNSocialMediaSettingsUtils.h"

#import "OAuthCore.h"


#define TW_HTTP_METHOD_GET @"GET"
#define TW_HTTP_METHOD_POST @"POST"
#define TW_HTTP_METHOD_DELETE @"DELETE"
#define TW_HTTP_HEADER_AUTHORIZATION @"Authorization"


//#define CONSUMER_SECRET @"OJt0KajMoWWFHgs5F6zFeBuV6yNydJpG4GvNtnG854"
//#define CONSUMER_KEY @"Zm3lo4TRGf9ZXrwVWf5DUg"


//  Important:  1) Your keys must be registered with Twitter to enable the reverse_auth endpoint
//              2) You should obfuscate keys and secrets in your apps before shipping!


@interface VMNSocialMediaTwitterSignedRequest()
{

}

- (NSURLRequest *)_buildRequest;

@end

@implementation VMNSocialMediaTwitterSignedRequest
@synthesize authToken = _authToken;
@synthesize authTokenSecret = _authTokenSecret;
@synthesize url = _url;
@synthesize parameters = _parameters;
@synthesize signedRequestMethod = _signedRequestMethod;

- (id)initWithURL:(NSURL *)url parameters:(NSDictionary *)parameters requestMethod:(TWSignedRequestMethod)requestMethod;
{
    self = [super init];
    if (self) {
        _url = [url retain];
        _parameters = [parameters retain];
        _signedRequestMethod = requestMethod;
    }
    return self;
}

- (NSURLRequest *)_buildRequest
{
//    NSAssert(_url, @"You can't build a request without an URL");

    NSString *method;

    switch (_signedRequestMethod) {
        case TWSignedRequestMethodPOST:
            method = TW_HTTP_METHOD_POST;
            break;
        case TWSignedRequestMethodDELETE:
            method = TW_HTTP_METHOD_DELETE;
            break;
        case TWSignedRequestMethodGET:
        default:
            method = TW_HTTP_METHOD_GET;
    }

    //  Build our parameter string
    NSMutableString *paramsAsString = [[NSMutableString alloc] init];
    [_parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [paramsAsString appendFormat:@"%@=%@&", key, obj];
    }];

    //  Create the authorization header and attach to our request
    NSData *bodyData = [paramsAsString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authorizationHeader = OAuthorizationHeader(_url, method, bodyData, [VMNSocialMediaTwitterSignedRequest consumerKey], [VMNSocialMediaTwitterSignedRequest consumerSecret], _authToken, _authTokenSecret);

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:_url];
    [request setHTTPMethod:method];
    [request setValue:authorizationHeader forHTTPHeaderField:TW_HTTP_HEADER_AUTHORIZATION];
    [request setHTTPBody:bodyData];
    [paramsAsString release];
    return request;
}

- (void)performRequestWithHandler:(TWSignedRequestHandler)handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:[self _buildRequest] returningResponse:&response error:&error];
        handler(data, response, error);
    });
}

// OBFUSCATE YOUR KEYS!
+ (NSString *)consumerKey
{
    return [VMNSocialMediaSettingsUtils twitterConsumerKey];
}

// OBFUSCATE YOUR KEYS!
+ (NSString *)consumerSecret
{
    return [VMNSocialMediaSettingsUtils twitterConsumerSecret];

}

- (void)dealloc{
    [_url release];
    [_parameters release];
    [_authToken release];
    [_authTokenSecret release];
    [super dealloc];
}

@end
