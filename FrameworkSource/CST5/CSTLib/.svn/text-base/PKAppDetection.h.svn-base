//
//  PKAppDetection.h
//  VMN_App_A
//
//  Created by Aliaksandr Huryn on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKAppInfo.h"

typedef enum {
	PKappDetectionStatusNone,
	PKAppDetectionStatusReady,
	PKAppDetectionStatusNoInternet,
	PKAppDetectionStatusDownloadingApps,
	PKAppDetectionStatusParsingError,
	PKAppDetectionStatusMisconfigured
} PKAppDetectionStatus;



@protocol PKAppDetectionDelegate <NSObject>

- (void) appDetectionApplications:(NSArray *)apps error:(NSError *)error;

@end



@interface PKAppDetection : NSObject {
	
}

+ (PKAppDetection *) instance;
- (void) refreshApps;
- (void) cancelTasks:(id<PKAppDetectionDelegate>)delegate;
- (void) installedApplications:(id<PKAppDetectionDelegate>)delegate;
- (void) applications:(id<PKAppDetectionDelegate>)delegate;
- (BOOL) isAppInstalledWithScheme:(NSString *)scheme andIdentifier:(NSString *)identifier;
- (void) openApplicationWithScheme:(NSString *)scheme andIdentifier:(NSString *)identifier;

@end
