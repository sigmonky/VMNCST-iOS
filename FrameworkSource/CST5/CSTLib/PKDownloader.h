//
//  BaseService.h
//  ExperienceGameday
//
//  Created by Alex on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKBaseTaskManager.h"

@protocol PKDownloaderDelegate <NSObject>

- (void) downloaderTask:(NSNumber *)taskId data:(NSData *)data error:(NSError *)error;

@end

@interface PKDownloader : PKBaseTaskManager {
	NSMutableDictionary *urlsDictionary;
}

+ (PKDownloader *) instance;
- (NSNumber *) downloadUrl:(NSURL *)url delegate:(id<PKDownloaderDelegate>)delegate;

@end
