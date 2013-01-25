#import <Foundation/Foundation.h>

typedef enum RequestMethod {
    RequestMethodGET,
    RequestMethodPOST
} RequestMethod;

typedef enum ServiceProvider {
    Flux,
    ZConnect,
    ZGateway,
    Other
} ServiceProvider;

typedef void(^SMRequestHandler)(NSData *data, NSURLResponse *response, NSError *error);

@interface VMNSocialMediaRequest : NSObject{
    NSDictionary *_parameters;
    NSDictionary *_options;
    RequestMethod _requestMethod;
    ServiceProvider _serviceProvider;
    NSString *_accessString;
}

@property (nonatomic, retain) NSDictionary *parameters;
@property (nonatomic, retain) NSDictionary *options;
@property (nonatomic, retain) NSString *accessString;
@property (nonatomic, assign) RequestMethod requestMethod;
@property (nonatomic, assign) ServiceProvider serviceProvider;

// Creates a new request
- (id)initWithParams:(NSDictionary *)parameters requestMethod:(RequestMethod)requestMethod accessString:(NSString *)accessString;

- (id)initWithServiceProvider:(ServiceProvider)serviceProvider params:(NSDictionary *)parameters options:(NSDictionary *)options requestMethod:(RequestMethod)requestMethod accessString:(NSString *)accessString;

// Creates a new request
- (id)initWithParams:(NSDictionary *)parameters options:(NSDictionary *)options requestMethod:(RequestMethod)requestMethod accessString:(NSString *)accessString;

// Perform the request, and notify handler of results
- (void)performRequestWithHandler:(SMRequestHandler)handler;

@end
