//
//  CommandlineParser.h
//  wkpdf
//
//  Created by Christian Plessl on 16.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include <getopt.h>

@interface CommandlineParser : NSObject {
  
  NSURL * _source;
  NSString * _output;
  NSSize _paperSize;
  BOOL _paginate;
  NSDecimalNumber * _margin;
  NSString * _stylesheetMedia;
  BOOL _printBackground;
  NSPrintingOrientation _paperOrientation;
  BOOL _horizontallyCentered;
  BOOL _verticallyCentered;
  NSURLRequestCachePolicy _cachingPolicy;
  NSTimeInterval _timeout;
  NSTimeInterval _saveDelay;
  BOOL _enablePlugins;
  BOOL _ignoreHttpErrors;
  NSString * _username;
  NSString * _password;
}

+ (CommandlineParser *)sharedInstance;
- (CommandlineParser *)setDefaults;
- (void)parseWithArgumentNumber:(int)argc andCommandline:(char * const *)argv;
- (NSString *)description;
- (void)prettyprint;
- (char *)usage;

#pragma mark accessor methods
- (NSURL *)source;
- (NSString *)output;
- (NSSize)paperSize;
- (BOOL)paginate;
- (NSString *)stylesheetMedia;
- (BOOL)printBackground;
- (NSDecimalNumber *)margin;
- (NSPrintingOrientation)paperOrientation;
- (BOOL)horizontallyCentered;
- (BOOL)verticallyCentered;
- (NSString *)description;
- (NSURLRequestCachePolicy)cachingPolicy;
- (NSTimeInterval)timeout;
- (NSTimeInterval)saveDelay;
- (BOOL)enablePlugins;
- (BOOL)ignoreHttpErrors;
- (NSString *)username;
- (NSString *)password;

#pragma mark helper methods
- (NSSize)parsePaperSize:(char *)arg;
- (NSDecimalNumber*)parseDecimalNumber:(char *)arg argName:(NSString *)argName;
- (NSURL *)parseSourcePathOrURL:(char *)arg;
- (NSString *)parseOutputPath:(char *)arg;
- (BOOL)parseYesOrNo:(char *)arg;
- (NSURLRequestCachePolicy)parseCachingArgument:(char *)optarg;
- (NSTimeInterval)parseTimeoutArgument:(char *)optarg;
- (NSString *)getVersionString;

@end
