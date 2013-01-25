//
//  PKAppInfoParser.m
//  VMN_App_A
//
//  Created by Aliaksandr Huryn on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PKAppInfoParser.h"

#define APPLICATION_TAG @"application"
#define APPLICATION_NAME_TAG @"name"
#define APPLICATION_PLATFORM_TAG @"platform"
#define APPLICATION_PLATFORM_NAME_ATTR @"name"
#define APPLICATION_IMAGE_TAG @"image"
#define APPLICATION_SCHEME_TAG @"custom_url"
#define APPLICATION_IMAGE_URL_ATTR @"url"

@implementation PKAppInfoParser

@synthesize items;
@synthesize error;

- (id) initWithData:(NSData *)data {
	self = [super init];
	if (self) {
		dataToParse = [data retain];
		items = [[NSMutableArray alloc] init];
		characters = nil;
	}
	return self;
}

- (void) parse {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:dataToParse];
	parser.delegate = self;
	[parser parse];
	[parser release];
}

#pragma mark - Private

- (void) dealloc {
	[dataToParse release];
	[error release];
	[items release];
	[super dealloc];
}

#pragma mark - Private

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:APPLICATION_TAG]) {
		[curentApp release];
		curentApp = [[PKAppInfo alloc] init];
	} else if ([elementName isEqualToString:APPLICATION_NAME_TAG]) {
		characters = [NSMutableString string];
	} else if ([elementName isEqualToString:APPLICATION_PLATFORM_TAG]) {
		if ([[[attributeDict objectForKey:APPLICATION_PLATFORM_NAME_ATTR] lowercaseString] isEqualToString:@"iphone"]) {
			iphonePlatform = YES;
		} else {
			iphonePlatform = NO;
		}
	} else if ([elementName isEqualToString:APPLICATION_IMAGE_TAG] && iphonePlatform) {
		curentApp.imageUrl = [attributeDict objectForKey:APPLICATION_IMAGE_URL_ATTR];
	} else if ([elementName isEqualToString:APPLICATION_SCHEME_TAG] && iphonePlatform) {
		characters = [NSMutableString string];
	}
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:APPLICATION_TAG]) {
		if (curentApp) {
			[items addObject:curentApp];
		}
	} else if ([elementName isEqualToString:APPLICATION_NAME_TAG]) {
		curentApp.name = characters;
	} else if ([elementName isEqualToString:APPLICATION_SCHEME_TAG] && iphonePlatform) {
		curentApp.scheme = characters;
	}
	characters = nil;
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (characters) {
		[characters appendString:string];
	}
}

- (void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	error = [parseError retain];
}

@end
