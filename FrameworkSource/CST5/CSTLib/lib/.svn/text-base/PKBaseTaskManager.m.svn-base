//
//  BaseTaskManager.m
//  ExperienceGameday
//
//  Created by Alex on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PKBaseTaskManager.h"

@interface PKBaseTaskManager ()

- (NSArray *) tasksForDelegate:(id)delegate;

@end

@implementation PKBaseTaskManager

- (NSNumber *) taskWithTarget:(id)target selector:(SEL)selector taskDelegate:(id)taskDelegate {
	NSNumber *taskId = [self nextTaskId];
	NSInvocationOperation *operation = [[[NSInvocationOperation alloc] initWithTarget:target selector:selector object:taskId] autorelease];
	
	[self setDelegate:taskDelegate forKey:taskId];
	[self setOperation:operation forKey:taskId];
	
	return taskId;
}

- (void) startTaskWithId:(NSNumber *)taskId {
	NSInvocationOperation *operation = [self operationForKey:taskId];
	[operationQueue addOperation:operation];
}

- (void) safeSetObject:(id)object forKey:(id)key intoDictionary:(NSMutableDictionary *)dictionary {
	@synchronized(dictionary) {
		[dictionary setObject:object forKey:key];
	}
}

- (void) safeRemoveObjectForKey:(id)key fromDictionary:(NSMutableDictionary *)dictionary {
	@synchronized(dictionary) {
		[dictionary removeObjectForKey:key];
	}
}

- (void) taskFinished:(NSNumber *)taskId {
	@synchronized(delegatesDictionary) {
		[delegatesDictionary removeObjectForKey:taskId];
	}
	@synchronized(operationsDictionary) {
		[operationsDictionary removeObjectForKey:taskId];
	}
}

- (void) cancelTasks:(id)delegate {
	NSArray *tasks = [self tasksForDelegate:delegate];
	for (NSNumber *n in tasks) {
		[self cancelTask:n];
	}
}

- (void) cancelTask:(NSNumber *)taskId {
	NSInvocationOperation *operation = [self operationForKey:taskId];
	[operation cancel];
	[self taskFinished:taskId];
}

#pragma mark - Private

- (void) dealloc {
	[delegatesDictionary release];
	[operationsDictionary release];
	[operationQueue release];
	[super dealloc];
}

- (id) init {
	self = [super init];
	if (self) {
		delegatesDictionary = [[NSMutableDictionary alloc] init];
		operationsDictionary = [[NSMutableDictionary alloc] init];
		operationQueue = [[NSOperationQueue alloc] init];
		currentTaskId = 0;
	}
	return self;
}

- (NSInvocationOperation *) operationForKey:(NSNumber *)key {
	return [operationsDictionary objectForKey:key];
}

- (void) setOperation:(NSInvocationOperation *)operation forKey:(NSNumber *)key {
	@synchronized(operationsDictionary) {
		[operationsDictionary setObject:operation forKey:key];
	}
}

- (void) setDelegate:(id)delegate forKey:(NSNumber *)key {
	@synchronized(delegatesDictionary) {
		[delegatesDictionary setObject:[NSValue valueWithNonretainedObject:delegate] forKey:key];
	}
}

- (NSArray *) tasksForDelegate:(id)delegate {
	NSMutableArray *arr = [NSMutableArray array];
	for (NSNumber *n in [delegatesDictionary allKeys]) {
		if ([delegatesDictionary objectForKey:n] == delegate) {
			[arr addObject:n];
		}
	}
	return arr;
}

- (id) delegateForKey:(NSNumber *)key {
	NSValue *v = [delegatesDictionary objectForKey:key];
	return [v nonretainedObjectValue];
}

- (NSNumber *) nextTaskId {
	NSInteger _id = 0;
	@synchronized(self) {
		currentTaskId++;
		if (currentTaskId == 0) {
			currentTaskId = 1;
		}
		_id = currentTaskId;
	}
	return [NSNumber numberWithUnsignedInteger:_id];
}

@end
