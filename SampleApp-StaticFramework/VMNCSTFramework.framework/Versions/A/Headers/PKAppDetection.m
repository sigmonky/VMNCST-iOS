//
//  PKAppDetection.m
//  VMN_App_A
//
//  Created by Aliaksandr Huryn on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKAppDetection.h"
#import "PKAppInfoParser.h"

#define PK_APP_DETECTION_DOMAIN @"PKAppDetectionDomain"

static PKAppDetection *_pkAppDetectionInstance = nil;


typedef enum {
	PKAppDetectionAppTypeAll,
	PKAppDetectionAppTypeInstalled
} PKAppDetectionAppType;



@interface PKAppDetection () {
	NSURL *appsUrl;
	NSArray *apps;
	NSOperationQueue *operationQueue;
	PKAppDetectionStatus status;
	NSMutableDictionary *delegatesDictionaty;
	NSInteger curentTaskId;
}

- (NSString *) appsFeedUrl;
- (NSNumber *) nextTaskId;
- (void) taskFinished:(NSNumber *)taskId;
- (void) setDelegate:(id<PKAppDetectionDelegate>)delegate forKey:(id)key;
- (id<PKAppDetectionDelegate>) delegateForKey:(id)key;
- (void) downloadAppsList;
- (void) applicationsWithType:(PKAppDetectionAppType)appType delegate:(id<PKAppDetectionDelegate>)delegate;
- (void) addApplicationsDelegateToQueue:(id<PKAppDetectionDelegate>)delegate forType:(PKAppDetectionAppType)appType;
- (void) markInstalledApplications:(NSArray *)applications;

- (void) returnInstalledApplicationsToDelegate:(NSNumber *)taskId;
- (void) returnApplicationsToDelegate:(NSNumber *)taskId;

@end

@implementation PKAppDetection

+ (PKAppDetection *) instance {
	return _pkAppDetectionInstance;
}

- (void) refreshApps {
	if (appsUrl) {
		status = PKAppDetectionStatusDownloadingApps;
		[operationQueue setSuspended:YES];
		[self performSelectorInBackground:@selector(downloadAppsList) withObject:nil];
	} else {
		NSLog(@"PKAppDetection: apps url is not specified");
	}
}

- (BOOL) isAppInstalledWithScheme:(NSString *)scheme andIdentifier:(NSString *)identifier {
	BOOL isInstalled = NO;
	if (scheme && identifier) {
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", scheme, identifier]];
		if ([[UIApplication sharedApplication] canOpenURL:url]) {
			isInstalled = YES;
		}
	}	
	return isInstalled;
}

- (void) openApplicationWithScheme:(NSString *)scheme andIdentifier:(NSString *)identifier {
	if (scheme && identifier) {
		NSURL *appUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", scheme, identifier]];
		[[UIApplication sharedApplication] openURL:appUrl];
	} else {
		NSLog(@"PKAppDetection: scheme and identifier are required to open application");
	}
}

- (void) installedApplications:(id<PKAppDetectionDelegate>)delegate {
	[self applicationsWithType:PKAppDetectionAppTypeInstalled delegate:delegate];
}

- (void) applications:(id<PKAppDetectionDelegate>)delegate {
	[self applicationsWithType:PKAppDetectionAppTypeAll delegate:delegate];
}

- (void) cancelTasks:(id<PKAppDetectionDelegate>)delegate {
	for (NSNumber *taskId in [delegatesDictionaty allKeysForObject:delegate]) {
		[self taskFinished:taskId];
	}
}

#pragma mark - Private

+ (void) initialize {
	if (!_pkAppDetectionInstance) {
		_pkAppDetectionInstance = [[PKAppDetection alloc] init];
	}
}

- (void) dealloc {
	[apps release];
	[appsUrl release];
	[delegatesDictionaty release];
	[operationQueue release];
	[super dealloc];
}

- (void) applicationsWithType:(PKAppDetectionAppType)appType delegate:(id<PKAppDetectionDelegate>)delegate {
	if (!apps) {
		if (status == PKappDetectionStatusNone) {
			[self refreshApps];
		}
	}
	[self addApplicationsDelegateToQueue:delegate forType:appType];
}

- (void) addApplicationsDelegateToQueue:(id<PKAppDetectionDelegate>)delegate forType:(PKAppDetectionAppType)appType {
	NSInvocationOperation *operation = nil;
	NSNumber *taskId = [self nextTaskId];
	switch (appType) {
		case PKAppDetectionAppTypeAll:
			operation = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(returnApplicationsToDelegate:) object:taskId] autorelease];
			break;
		case PKAppDetectionAppTypeInstalled:
			operation = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(returnInstalledApplicationsToDelegate:) object:taskId] autorelease];
			break;
		default:
			NSLog(@"PKAppDetection: unknown app type");
			break;
	}
	if (operation) {
		[self setDelegate:delegate forKey:taskId];
		[operationQueue addOperation:operation];
	}
}

- (void) markInstalledApplications:(NSArray *)applications {
	for (PKAppInfo *app in applications) {
		app.installed = [self isAppInstalledWithScheme:app.scheme andIdentifier:@"start"];
	}
}

- (void) downloadAppsList {
	NSURLRequest *request = [NSURLRequest requestWithURL:appsUrl];
	NSURLResponse *response = nil;
	NSError *_error = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&_error];
	if (!_error) {
		PKAppInfoParser *parser = [[PKAppInfoParser alloc] initWithData:data];
		[parser parse];
		if (!parser.error) {
			[apps release];
			apps = [parser.items retain];
			status = PKAppDetectionStatusReady;
		}
		[parser release];
	} else {
		status = PKAppDetectionStatusNoInternet;
		NSLog(@"PKAppDetection: Failed to download apps list");
		[operationQueue setSuspended:NO];
	}
	[operationQueue setSuspended:NO];
}

- (void) returnApplicationsToDelegate:(NSNumber *)taskId {
	[self markInstalledApplications:apps];
	NSError *error = nil;
	id<PKAppDetectionDelegate> delegate = [self delegateForKey:taskId];
	if (status != PKAppDetectionStatusReady) {
		error = [[[NSError alloc] initWithDomain:PK_APP_DETECTION_DOMAIN code:status userInfo:nil] autorelease];
	}
	[delegate appDetectionApplications:[NSArray arrayWithArray:apps] error:error];
	[self taskFinished:taskId];
}

- (void) returnInstalledApplicationsToDelegate:(NSNumber *)taskId {
	[self markInstalledApplications:apps];
	NSError *error = nil;
	id<PKAppDetectionDelegate> delegate = [self delegateForKey:taskId];
	if (status != PKAppDetectionStatusReady) {
		error = [[[NSError alloc] initWithDomain:PK_APP_DETECTION_DOMAIN code:status userInfo:nil] autorelease];
	}
	NSMutableArray *res = nil;
	if (apps) {
		res = [NSMutableArray array];
		for (PKAppInfo *appInfo in apps) {
			if (appInfo.installed) {
				[res addObject:appInfo];
			}
		}
	}
	[delegate appDetectionApplications:res error:error];
	[self taskFinished:taskId];
}

- (NSString *) appsFeedUrl {
	NSString *urlStr = [[[NSBundle mainBundle] infoDictionary] valueForKeyPath:@"libAppDetector.ApplicationsUrl"];
	if (!urlStr) {
		status = PKAppDetectionStatusMisconfigured;
		NSLog(@"PKAppDetection: libAppDetector.ApplicationsUrl is not specified");
	}
	return urlStr;
}

- (void) taskFinished:(NSNumber *)taskId {
	@synchronized(delegatesDictionaty) {
		[delegatesDictionaty removeObjectForKey:taskId];
	}
}
		  
- (void) setDelegate:(id<PKAppDetectionDelegate>)delegate forKey:(id)key {
	@synchronized(delegatesDictionaty) {
		[delegatesDictionaty setObject:[NSValue valueWithNonretainedObject:delegate] forKey:key];
	}
}

- (id<PKAppDetectionDelegate>) delegateForKey:(id)key {
	NSValue *value = [delegatesDictionaty objectForKey:key];
	return [value nonretainedObjectValue];
}

- (NSNumber *) nextTaskId {
	NSInteger taskId;
	@synchronized(self) {
		curentTaskId++;
		if (curentTaskId == 0) {
			curentTaskId = 1;
		}
		taskId = curentTaskId;
	}
	return [NSNumber numberWithInteger:taskId];
}

- (id) init {
	self = [super init];
	if (self) {
		status = PKappDetectionStatusNone;
		NSString *appUrlStr = [self appsFeedUrl];
		if (appUrlStr) {
			appsUrl = [[NSURL alloc] initWithString:appUrlStr];
		}
		operationQueue = [[NSOperationQueue alloc] init];
		delegatesDictionaty = [[NSMutableDictionary alloc] init];
		curentTaskId = 0;
	}
	return self;
}

@end
