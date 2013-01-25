//
//  BaseTaskManager.h
//  ExperienceGameday
//
//  Created by Alex on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKBaseTaskManager : NSObject {
	NSInteger currentTaskId;
	NSMutableDictionary *delegatesDictionary;
	NSMutableDictionary *operationsDictionary;
	NSOperationQueue *operationQueue;
}

- (void) taskFinished:(NSNumber *)taskId;
- (void) startTaskWithId:(NSNumber *)taskId;
- (NSNumber *) taskWithTarget:(id)target selector:(SEL)selector taskDelegate:(id)taskDelegate;
- (void) cancelTask:(NSNumber *)taskId;
- (void) cancelTasks:(id)delegate;
- (void) safeSetObject:(id)object forKey:(id)key intoDictionary:(NSMutableDictionary *)dictionary;
- (void) safeRemoveObjectForKey:(id)key fromDictionary:(NSMutableDictionary *)dictionary;
// TODO: remove
- (NSNumber *) nextTaskId;
- (id) delegateForKey:(NSNumber *)key;
// TODO: remove
- (void) setDelegate:(id)delegate forKey:(NSNumber *)key;
- (NSInvocationOperation *) operationForKey:(NSNumber *)key;
// TODO: remove
- (void) setOperation:(NSInvocationOperation *)operation forKey:(NSNumber *)key;



@end
