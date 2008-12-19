#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>b
#import <WebKit/WebKit.h>

#import "Controller.h"
#import "CommandlineParser.h"
#import "Debugging.h"

int main (int argc,  char * argv[]) {
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  LOG_DEBUG(@"wkpdf started");

  CommandlineParser * parser = [CommandlineParser sharedInstance];
  [parser parseWithArgumentNumber:argc andCommandline:argv];
  [parser prettyprint];
  
  [NSApplication sharedApplication];
  
  // use 1x1 size: when pagination is turned off, the view should grow to the 
  // required size, if turned on, the view should use the page size. 
  WebView * webView = [[WebView alloc] initWithFrame:NSMakeRect(0,0,1,1)
                                           frameName:@"myFrame"
                                           groupName:@"myGroup"];

  NSWindow * window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0,0,1,1) 
                                                  styleMask:NSBorderlessWindowMask 
                                                    backing:NSBackingStoreNonretained defer:NO];
  [window setContentView:webView];

  Controller * controller = [[Controller alloc] initWithWebView:webView]; 
  
  [webView setFrameLoadDelegate: controller];
  [webView setResourceLoadDelegate: controller];
  NSString *appName = [NSString stringWithFormat: @"wkpdf/%@", [parser getVersionString]];
  [webView setApplicationNameForUserAgent:appName];

  WebPreferences * webPrefs = [WebPreferences standardPreferences];
  [webPrefs setLoadsImagesAutomatically:YES];
  [webPrefs setAllowsAnimatedImages:YES];
  [webPrefs setAllowsAnimatedImageLooping:NO];
  [webPrefs setJavaEnabled:NO];
  [webPrefs setPlugInsEnabled:[parser enablePlugins]];
  [webPrefs setJavaScriptEnabled:YES];
  [webPrefs setJavaScriptCanOpenWindowsAutomatically:NO];
  [webPrefs setShouldPrintBackgrounds:[parser printBackground]];
  [webView setPreferences:webPrefs];
  [webView setMaintainsBackForwardList:NO];

  if ([parser stylesheetMedia] != nil)
	[webView setMediaStyle:[parser stylesheetMedia]];
  LOG_DEBUG(@"media style is: %@", [webView mediaStyle]);

  NSURL * theURL = [parser source];  
  NSURLRequest * request = [NSURLRequest requestWithURL:theURL 
                                            cachePolicy: [parser cachingPolicy]
                                        timeoutInterval: [parser timeout]];
  
  // TODO: detect timeout and terminate if timeout occured
  
  [[webView mainFrame] loadRequest:request];
  [[NSRunLoop currentRunLoop] run];
    
  [webView release];
  [pool release];
  return 0;
}

