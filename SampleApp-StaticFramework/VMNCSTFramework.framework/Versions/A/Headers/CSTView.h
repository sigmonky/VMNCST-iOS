/**
 
 Abstract: WebView Subclass that manages the CST panel lifecycle.
 
 Version: 1.1
 
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Reachability.h"
#import "PKAppDetection.h"

@interface CSTView : UIView <UIWebViewDelegate, NSURLConnectionDelegate> {
    NSString *mGid;
    NSString *platform;
    UIView *aViewReference;
    BOOL isFullScreen;
    Reachability *hostReach;
    UIWebView *aWebView;
    NSDictionary *config;
    BOOL siteChecked;
    NSString *currentUrl;
    NSString *appName;
    UIActivityIndicatorView *activityIndicator;
    NSMutableDictionary *paramsDictionary;
    
}
@property (nonatomic, retain) NSString *mGid;
@property (nonatomic, retain) NSString *platform;
@property (nonatomic, retain) UIWebView *aWebView;
@property (nonatomic, retain)  NSDictionary *config;
@property (nonatomic, retain)  NSString *currentUrl;
@property (nonatomic, retain)  NSString *appName;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UIView *aViewReference;
@property (nonatomic, retain) NSMutableDictionary *paramsDictionary;



+ (CSTView *)showCSTInView:(UIView *)view forMgid:(NSString *)id forPlatform:(NSString *)platformVals inFullScreenMode:(BOOL)fullScreen paramsList:(NSMutableDictionary*)params;
+(CSTView *)cstPanel:(NSString *)mgid forPlatform:(NSString *)platform inFullScreenMode:(BOOL)fullScreen inView:(UIView *)aView paramsList:(NSMutableDictionary*)params;
- (void)handleCall:(NSString*)functionName arg:(NSString*)arg;
- (NSDictionary *)getDictionary:(NSString *)fileName;
- (void)closeCST;
- (void)closeCSTPanel:(id)sender;
- (void)setup;
- (void) setupUI;
- (void) setupReachability;
- (void) updateInterfaceWithReachability: (Reachability*) curReach;
- (NSArray *) getSysApps;
- (void) setSysApps:(NSArray *)apps;
- (void) executeAppDetection;
- (void) launchApp: (NSString *)app;


@end
