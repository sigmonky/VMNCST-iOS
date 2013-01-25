//
//  PKAppInfoParser.h
//  VMN_App_A
//
//  Created by Aliaksandr Huryn on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKAppInfo.h"

@interface PKAppInfoParser : NSObject <NSXMLParserDelegate> {
	NSData *dataToParse;
	NSMutableArray *items;
	NSMutableString *characters;
	PKAppInfo *curentApp;
	NSError	*error;
	BOOL iphonePlatform;
}

@property (nonatomic, readonly) NSArray *items;
@property (nonatomic, readonly) NSError *error;

- (id) initWithData:(NSData *)data;
- (void) parse;

@end
