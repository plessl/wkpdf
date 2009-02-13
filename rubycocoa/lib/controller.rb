require 'osx/cocoa'

class Controller < NSObject

  include OSX

  attr_accessor :resourceCount, :webView

  def initWithWebView(webview)
    #super_init
    @resourceCount = 0
    @webView = webview
    log("initialied Controller\n")
    self
  end

  def webView_didFinishLoadForFrame(sender, frame)
    log("webView #{sender} didFinishLoadForFrame #{frame} // #{frame.parentFrame}\n")

    return if frame.parentFrame # sub-frame on page, page not fully loaded yet

    #  CommandlineParser * options = [CommandlineParser sharedInstance];
    #  
    #  if (![options ignoreHttpErrors])
    #    [self checkResponseCode:sender forFrame:frame];
    #
    #  double saveDelay = [options saveDelay];
    #  if (saveDelay <= 0) {
    #	[self makePDF:NULL];
    #	return;
    #  }
    #  [_saveTimer invalidate];
    #  _saveTimer = [NSTimer scheduledTimerWithTimeInterval:saveDelay target:self selector:@selector(makePDF:) userInfo:_saveTimer #repeats:NO];
    makePDF(nil)

  end


   def webView_didStartProvisionalLoadForFrame(sender,frame)
     log("webview #{sender} didStartProvisionalLoadForFrame #{frame}")
   end

    def webView_didCommitLoadForFrame(sender,frame)
      log("webView #{sender} didCommitLoadForFrame #{frame}\n")
    end

    # indicates errors for a partially loaded page
    def webView_didFailLoadWithError_forFrame(sender,error,frame)
      log("webView #{sender} didFailLoadWithError: #{error.localizedDescription}, Frame: #{frame}\n")
      #[Helper terminateWithErrorcode:1 andMessage:[error localizedDescription]];
    end

    # indicates errors for initially loading a page
    def webView_didFailProvisionalLoadWithError_forFrame(sender,error,frame)
      log("webView #{sender} didFailProvisionalLoadWithError \"#{error.localizedDescription}\", Frame: #{frame}")
      #[Helper terminateWithErrorcode:1 andMessage:[error localizedDescription]];
    end

    def makePDF(timer)
      log("webView #{webView} makePDF\n")
      p = CommandlineParser.instance
      if p.paginate then
        makePaginatedPDF
      else
        makeSinglePagePDF
      end
    end

    def makePaginatedPDF
      
      log("Make paginated PDF...\n")
      p = CommandlineParser.instance

      sharedInfo = NSPrintInfo.sharedPrintInfo
      sharedDict = sharedInfo. dictionary
      printInfoDict = NSMutableDictionary.dictionaryWithDictionary(sharedDict)

      printInfoDict.setObject_forKey(NSPrintSaveJob,NSPrintJobDisposition)
      printInfoDict.setObject_forKey(p.output,NSPrintSavePath)

      printInfo = NSPrintInfo.alloc.initWithDictionary(printInfoDict)
      printInfo.setHorizontalPagination(NSAutoPagination)
      printInfo.setVerticalPagination(NSAutoPagination)
      printInfo.setVerticallyCentered(p.verticallyCentered)
      printInfo.setHorizontallyCentered(p.horizontallyCentered)
      printInfo.setOrientation(p.paperOrientation)
      printInfo.setPaperSize(p.paperSize)

      if p.margin > 0 then
        printInfo.setBottomMargin(p.margin)
        printInfo.setTopMargin(p.margin)
        printInfo.setLeftMargin(p.margin)
        printInfo.setRightMargin(p.margin)
      end

      viewToPrint = webView.mainFrame.frameView.documentView
      printOp = NSPrintOperation.printOperationWithView_printInfo(viewToPrint,printInfo)
      printOp.setShowPanels(false)
      log("Start NSPrintOperation\n")
      printOp.runOperation
      log("Terminate application\n")
      NSApplication.sharedApplication.terminate(nil)
  end

  def makeSinglePagePDF
    log("Make single-page PDF...\n")
    p = CommandlineParser.instance
    viewToPrint = webView.mainFrame.frameView.documentView
    r = viewToPrint.bounds
    if p.margin > 0 then
      r.origin.x -= p.margin;
      r.origin.y -= p.margin;
      r.size.width += 2 * p.margin;
      r.size.height += 2 * p.margin;
    end

    log("Create PDF\n")
    data = viewToPrint.dataWithPDFInsideRect(r)
    log("Save PDF\n")
    data.writeToFile_atomically(p.output,true)
    log("Terminate application\n")
    NSApplication.sharedApplication.terminate(nil)

  end

private

  def log(msg)
    $stderr.puts(msg)
  end


end


__END__

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
