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
      NSApplication.sharedApplication.terminate(nil)
    end

    # indicates errors for initially loading a page
    def webView_didFailProvisionalLoadWithError_forFrame(sender,error,frame)
      log("webView #{sender} didFailProvisionalLoadWithError \"#{error.localizedDescription}\", Frame: #{frame}")
      NSApplication.sharedApplication.terminate(nil)
    end

    # accessing a password protected resource
    def webView_resource_identifier_didReceiveAuthenticationChallenge_fromDataSource(sender,identifier,challenge,dataSource)
      log("webView #{sender} didReceiveAuthenticationChallenge challenge: #{challenge} from data source: #{dataSource}")

      if challenge.previousFailureCount == 0 then
        p = CommandlineParser.instance
        credential = NSURLCredential.credentialWithUser_password_persistence(p.username,p.password,NSURLCredentialPersistenceForSession)
        challenge.sender.useCredential_forAuthenticationChallenge(sender,challenge)
      else
        puts "Could not authenticate with the given username/password\n"
        NSApplication.sharedApplication.terminate(nil)
      end
    end

    # notification that a resource is unavailable
    def webView_resource_didFailLoadingWithError_fromDataSource(sender,identifier,error,dataSource)
      log("didFailLoadingWithError identifier: #{identifier} error: #{error.localizedDescription} dataSource: #{dataSource}\n")
      p = CommandlineParser.instance
      if p.ignoreHttpErrors then
        puts "Could not load resource #{identifier}, error: #{error.localizedDescription}\n"
        NSApplication.sharedApplication.terminate(nil)
      end
    end

    # plugin failed to load
    def webView_plugInFailedWithError_dataSource(sender,error,dataSource)
      puts "plugInFailedWithError error: #{error.localizedDescription} dataSource: #{dataSource}\n"
      p = CommandlineParser.instance
      if p.ignoreHttpErrors then
        puts "Cound not load plugin, error: #{error.localizedDescription}\n"
        NSApplication.sharedApplication.terminate(nil)
      end
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

  # log all respondsToSelector calls. This helps to spot possibly interesting 
  # delegation calls
  #def respondsToSelector(sel)
  #  log "checked for SEL: #{sel}\n"
  #  return super.respondsToSelector(sel)
  #end


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




@end
