//
//  Controller.h
//  wkpdf
//
//  Created by Christian Plessl on 13.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WebView;
@class WebFrame;
@class NSURLRequest;

@interface Controller : NSObject {
    int _resourceCount;
    WebView *_webView;
    NSTimer *_saveTimer;
}

// init
- (id)initWithWebView:(WebView *)webView;

// private methods
- (void)checkResponseCode:(WebView *)sender forFrame:(WebFrame *)frame;
- (void)makePDF:(NSTimer *)theTimer;
- (void)makePaginatedPDF;
- (void)makeSinglePagePDF;

// methods from protocol WebFramLoadDelegate
- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame;
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame;
- (void)webView:(WebView *)sender didCommitLoadForFrame:(WebFrame *)frame;
- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame;
- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame;

// methods from protocol WebResourceLoadDelegate
- (id)webView:(WebView *)sender identifierForInitialRequest:(NSURLRequest *)request fromDataSource:(WebDataSource *)dataSource;
- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource;
- (void)webView:(WebView *)sender resource:(id)identifier didFailLoadingWithError:(NSError *)error fromDataSource:(WebDataSource *)dataSource;
- (void)webView:(WebView *)sender plugInFailedWithError:(NSError *)error dataSource:(WebDataSource *)dataSource;

- (void)webView:(WebView *)sender resource:(id)identifier didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge fromDataSource:(WebDataSource *)dataSource;

@end
