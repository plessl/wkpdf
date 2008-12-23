//
//  Controller.m
//  wkpdf
//
//  Created by Christian Plessl on 13.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <WebKit/WebKit.h>

#import "Controller.h"
#import "Debugging.h"
#import "CommandlineParser.h"
#import "Helper.h"

@implementation Controller

- (id)initWithWebView:(WebView *)webView {
  if ((self = [super init])) {
    _resourceCount = 0;
	_webView = webView;
  }
  return self;
}

- (void)checkResponseCode:(WebView *)sender forFrame:(WebFrame *)frame {
  WebDataSource *dataSource = [frame dataSource];

  NSURLResponse *response = [dataSource response];
  if (![response isKindOfClass: [NSHTTPURLResponse class]]){
    return;
  }

  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
  int statusCode = [httpResponse statusCode];
  if (statusCode >= 200 && statusCode <= 299){
    return;
  }

  NSString *errorMsg = [NSString stringWithFormat:@"could not load resource %@, HTTP status code %d", 
    [[response URL] absoluteString],statusCode];
  LOG_DEBUG(@"%@", errorMsg);
  [Helper terminateWithErrorcode:1 andMessage:errorMsg];
}

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame {
  LOG_DEBUG(@"webView %@ didStartProvisionalLoadForFrame %@", sender, frame);
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
  LOG_DEBUG(@"webView %@ didFinishLoadForFrame %@ // %@", sender, frame, [frame parentFrame]);
  if ([frame parentFrame])
	return; // sub-frame on page, page not fully loaded yet.
  CommandlineParser * options = [CommandlineParser sharedInstance];
  
  if (![options ignoreHttpErrors])
    [self checkResponseCode:sender forFrame:frame];

  double saveDelay = [options saveDelay];
  if (saveDelay <= 0) {
	[self makePDF:NULL];
	return;
  }
  [_saveTimer invalidate];
  _saveTimer = [NSTimer scheduledTimerWithTimeInterval:saveDelay target:self selector:@selector(makePDF:) userInfo:_saveTimer repeats:NO];
}

- (void)makePDF:(NSTimer *)theTimer {
  // theTimer arg is NULL if called directly without a timer.
  LOG_DEBUG(@"webView %@ makePDF", _webView);
  CommandlineParser * options = [CommandlineParser sharedInstance];
  
  if ([options paginate])
    [self makePaginatedPDF];
  else
    [self makeSinglePagePDF];
}

- (void)makePaginatedPDF {
  LOG_DEBUG(@"Make paginated PDF...");
  CommandlineParser * options = [CommandlineParser sharedInstance];

  NSPrintInfo *sharedInfo = [NSPrintInfo sharedPrintInfo];
  NSMutableDictionary *sharedDict = [sharedInfo dictionary];
  NSMutableDictionary *printInfoDict = [NSMutableDictionary dictionaryWithDictionary:sharedDict];
  
  [printInfoDict setObject:NSPrintSaveJob forKey:NSPrintJobDisposition];
  [printInfoDict setObject:[options output] forKey:NSPrintSavePath];
  
  NSPrintInfo *printInfo = [[NSPrintInfo alloc] initWithDictionary: printInfoDict];
  [printInfo setHorizontalPagination: NSAutoPagination];
  [printInfo setVerticalPagination: NSAutoPagination];
  [printInfo setVerticallyCentered:[options verticallyCentered]];
  [printInfo setHorizontallyCentered:[options horizontallyCentered]];
  [printInfo setOrientation:[options paperOrientation]];
  [printInfo setPaperSize:[options paperSize]];

  double margin = [[options margin] doubleValue];
  if (!isnan(margin)) {
    [printInfo setBottomMargin:margin];
    [printInfo setTopMargin:margin];
    [printInfo setLeftMargin:margin];
    [printInfo setRightMargin:margin];
  }
  //LOG_DEBUG(@"printInfo: %@",printInfo);
  
  NSView *viewToPrint = [[[_webView mainFrame] frameView] documentView];

  NSPrintOperation *printOp = [NSPrintOperation printOperationWithView:viewToPrint 
                                           printInfo:printInfo];
  [printOp setShowPanels:NO];
  LOG_DEBUG(@"Start NSPrintOperation");
  [printOp runOperation];
  LOG_DEBUG(@"Terminate application");
  exit(0);
}

- (void)makeSinglePagePDF {
  LOG_DEBUG(@"Make single-page PDF...");
  CommandlineParser * options = [CommandlineParser sharedInstance];
  NSView *viewToPrint = [[[_webView mainFrame] frameView] documentView];
  NSRect r = [viewToPrint bounds];
  double margin = [[options margin] doubleValue];
  if (!isnan(margin)) {
    r.origin.x -= margin;
    r.origin.y -= margin;
    r.size.width += 2 * margin;
    r.size.height += 2 * margin;
  }
  LOG_DEBUG(@"Creates PDF");
  NSData *data = [viewToPrint dataWithPDFInsideRect:r];
  LOG_DEBUG(@"Saves PDF");
  [data writeToFile:[options output] atomically:YES];
  LOG_DEBUG(@"Terminate application");
  exit(0);
}

- (void)webView:(WebView *)sender didCommitLoadForFrame:(WebFrame *)frame {
  LOG_DEBUG(@"webView %@ didCommitLoadForFrame %@", sender, frame);
}

// indicates errors for a partially loaded page
- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
  LOG_DEBUG(@"webView %@ didFailLoadWithError Error: %@, Frame: %@", sender, error, frame);
  [Helper terminateWithErrorcode:1 andMessage:[error localizedDescription]];
}

// indicates errors for for initially loading a page
- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
  LOG_DEBUG(@"webView %@ didFailProvisionalLoadWithError Error: %@, Frame: %@", sender, error, frame);
  [Helper terminateWithErrorcode:1 andMessage:[error localizedDescription]];
}

// accessing a password protected resource
- (void)webView:(WebView *)sender resource:(id)identifier didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge fromDataSource:(WebDataSource *)dataSource {
  LOG_DEBUG(@"webView %@ didReceiveAuthenticationChallenge challenge: %@ from data source: %@", challenge, dataSource );
  
  if ([challenge previousFailureCount] == 0) {
    CommandlineParser * options = [CommandlineParser sharedInstance];
    NSURLCredential * credential = [NSURLCredential credentialWithUser:[options username]
                                                              password:[options password]
                                                           persistence:NSURLCredentialPersistenceForSession];
    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
  } else {
    [Helper terminateWithErrorcode:1 andMessage:@"could not authenticate with the given username/password"];
  }
    
}

// assign each resource a unique identifier when loading
- (id)webView:(WebView *)sender identifierForInitialRequest:(NSURLRequest *)request fromDataSource:(WebDataSource *)dataSource {
  NSNumber * resourceId = [NSNumber numberWithInt:_resourceCount++];
  LOG_DEBUG (@"identifierForInitialRequest request: %@ dataSource: %@ (resource id: %@)", request, dataSource, resourceId);
  return resourceId;
}  

// notification that a resource has been loaded successfully
- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource {
  LOG_DEBUG (@"didFinishLoadingFromDataSource identifier: %@ dataSource: %@", identifier, dataSource);
}


// notification that a resource is unavailable
-(void)webView:(WebView *)sender resource:(id)identifier didFailLoadingWithError:(NSError *)error fromDataSource:(WebDataSource *)dataSource {
  LOG_DEBUG (@"didFailLoadingWithError identifier: %@ error: %@ dataSource: %@", identifier, error, dataSource);
  CommandlineParser * options = [CommandlineParser sharedInstance];
  if (![options ignoreHttpErrors]){
    NSString *errorMsg = [NSString stringWithFormat:@"could not load resource %@, error %@", 
      identifier, error];
    [Helper terminateWithErrorcode:1 andMessage:errorMsg];
  }
}

- (void)webView:(WebView *)sender plugInFailedWithError:(NSError *)error dataSource:(WebDataSource *)dataSource {
  LOG_DEBUG (@"plugInFailedWithError error: %@ dataSource: %@", error, dataSource);
  CommandlineParser * options = [CommandlineParser sharedInstance];
  if (![options ignoreHttpErrors]){
    NSString *errorMsg = [NSString stringWithFormat:@"could not load plugin, error %@", error];
    [Helper terminateWithErrorcode:1 andMessage:errorMsg];
  }
}

// log all respondsToSelector calls. This helps to spot possibly interesting 
// delegation calls
- (BOOL) respondsToSelector: (SEL) aSelector
{
  LOG_DEBUG (@"checked for SEL: %s", (char *) aSelector);
  return ([super respondsToSelector: aSelector]);
}

@end
