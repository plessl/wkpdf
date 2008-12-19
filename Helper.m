//
//  Helper.m
//  wkpdf
//
//  Created by Christian Plessl on 26.06.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Helper.h"


@implementation Helper

+ (void) terminateWithErrorcode:(int)error andMessage:(NSString *)message{
  
  const BOOL showErrorCode = NO;
  
  NSString * errorString;
  if (showErrorCode){
    errorString = [NSString stringWithFormat:@"Fatal error: %@ (error code: %d)\n",message, error];
  } else {
    errorString = [NSString stringWithFormat:@"Fatal error: %@\n",message];
  }
  fprintf(stderr, [errorString UTF8String]);
  exit(error);

}

@end
