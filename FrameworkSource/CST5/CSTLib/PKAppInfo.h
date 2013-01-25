//
//  PKAppInfo.h
//  VMN_App_A
//
//  Created by Aliaksandr Huryn on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKAppInfo : NSObject {
	NSString *scheme;
	NSString *name;
	NSString *imageUrl;
	BOOL installed;
}

@property (nonatomic, retain) NSString *scheme;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *imageUrl;
@property (nonatomic, assign) BOOL installed;

@end
