//
//  BaseService.m
//  ExperienceGameday
//
//  Created by Alex on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PKDownloader.h"

static PKDownloader *_downloaderInstance = nil;

@interface PKDownloader ()

- (void) downloaderWorker:(NSNumber *)taskId;
- (void) taskFinished:(NSNumber *)taskId;

@end

@implementation PKDownloader

+ (PKDownloader *) instance {
	return _downloaderInstance;
}

- (NSNumber *) downloadUrl:(NSURL *)url delegate:(id<PKDownloaderDelegate>)delegate {
	NSNumber *taskId = [self taskWithTarget:self selector:@selector(downloaderWorker:) taskDelegate:delegate];
	[self safeSetObject:url forKey:taskId intoDictionary:urlsDictionary];
	[self startTaskWithId:taskId];
	return taskId;
}

#pragma mark - Private

+ (void) initialize {
	if (!_downloaderInstance) {
		_downloaderInstance = [[PKDownloader alloc] init];
	}
}

- (void) dealloc {
	[urlsDictionary release];
	[super dealloc];
}

- (id) init {
	self = [super init];
	if (self) {
		urlsDictionary = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) taskFinished:(NSNumber *)taskId {
	[self safeRemoveObjectForKey:taskId fromDictionary:urlsDictionary];
	[super taskFinished:taskId];
}

- (void) downloaderWorker:(NSNumber *)taskId {
	NSURL *url = [urlsDictionary objectForKey:taskId];
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url] returningResponse:&response error:&error];
	
	id<PKDownloaderDelegate> delegate = [self delegateForKey:taskId];
	[delegate downloaderTask:taskId data:data error:error];
	[self taskFinished:taskId];
}

@end
