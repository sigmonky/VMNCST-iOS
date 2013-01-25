#import <Foundation/Foundation.h>

@class SMTwitterLoginPopup;

@protocol SMTwitterLoginPopupDelegate

- (void)twitterLoginPopupDidCancel:(SMTwitterLoginPopup *)popup;
- (void)twitterLoginPopupDidAuthorize:(SMTwitterLoginPopup *)popup;

@end

@protocol SMTwitterAccountsListDelegate

- (void)closeTwitterAccountList:(id)account;
- (void)twitterAccountAccessRefused:(NSString *)aMessage;

@end

@protocol SMTwitterViewControllerDelegate

- (void)twitterAccountDidGetSelected:(id)account;
- (void)twitterAccountNotAuthorized:(NSError *)errorInfo;

@end

@protocol SMTwitterReverseAuthDelegate <NSObject>

- (void) reverseAuthDidSucceed;
- (void) reverseAuthDidFailWithError:(NSError *)error;

@end
