//
//  controller.swift
//  wkpdf-swift
//
//  Created by Joe Devietti on 7/2/16.
//
//

import Foundation
import Cocoa
import WebKit
import Darwin

class Controller : NSObject, NSApplicationDelegate, WebFrameLoadDelegate, WebResourceLoadDelegate {
  
  var resourceCount : Int
  var saveTimer : NSTimer?
  var webView : WebView
  
  init(webview: WebView) {
    // super_init
    resourceCount = 0
    saveTimer = nil
    webView = webview
    log("initialized Controller\n")
  }
  
  
  func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {
    log("webView \(sender) didFinishLoadForFrame \(frame), parentFrame: \(frame.parentFrame)\n")
    
    if frame.parentFrame != nil { // sub-frame on page, page not fully loaded yet
      return
    }
    
    if !parser.ignore_http_errors.value {
      checkResponseCodeforFrame(sender,frame: frame)
    }
    
    if parser.user_script.value! != "" {
      // because loading a user script occurs asynchronously, we have to pass
      // a continuation to ensure we print only after the script loads
      loadUserScript(sender, continuation: waitForSaveTimer)
    } else {
      waitForSaveTimer()
    }
    
  }
  
  func waitForSaveTimer() {
    saveTimer?.invalidate()
    // NB: if save_delay is <= 0, timerFired() gets called basically immediately
    saveTimer = NSTimer.scheduledTimerWithTimeInterval(parser.save_delay.value!, target: self, selector: #selector(Controller.timerFired(_:)), userInfo: nil, repeats: false)
  }

  func webView(sender: WebView!, didStartProvisionalLoadForFrame frame: WebFrame!) {
    log("webview \(sender) didStartProvisionalLoadForFrame \(frame)")
  }

  func webView(sender: WebView!, didCommitLoadForFrame frame: WebFrame!) {
    log("webView \(sender) didCommitLoadForFrame \(frame)\n")
  }
  
  // indicates errors for a partially loaded page
  func webView(sender: WebView!, didFailLoadWithError error: NSError!, forFrame frame: WebFrame!) {
    log("webView \(sender) didFailLoadWithError: \(error), Frame: \(frame)\n")
    if !parser.ignore_http_errors.value { exit(EX_IOERR) }
  }
  
  // indicates errors for initially loading a page
  func webView(sender: WebView!, didFailProvisionalLoadWithError error: NSError!, forFrame frame: WebFrame!) {
    log("webView \(sender) didFailProvisionalLoadWithError \"\(error)\", Frame: \(frame)")
    if !parser.ignore_http_errors.value { exit(EX_IOERR) }
  }
  
  // accessing a password-protected resource
  func webView(sender: WebView!, resource identifier: AnyObject!, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge!, fromDataSource dataSource: WebDataSource!) {
    log("webView \(sender) didReceiveAuthenticationChallenge challenge: \(challenge) from data source: \(dataSource)")
    if challenge.previousFailureCount == 0 {
      let cred = NSURLCredential(user: parser.username.value!, password: parser.password.value!, persistence: NSURLCredentialPersistence.ForSession)
      challenge.sender?.useCredential(cred, forAuthenticationChallenge: challenge)
    } else {
      print("Could not authenticate with the given username/password\n")
      exit(EX_IOERR)
    }
  }
  
  // notification that a resource is unavailable
  func webView(sender: WebView!, resource identifier: AnyObject!, didFailLoadingWithError error: NSError!, fromDataSource dataSource: WebDataSource!) {
    log("didFailLoadingWithError identifier: \(identifier) error: \(error) dataSource: \(dataSource)\n")
    if !parser.ignore_http_errors.value { exit(EX_IOERR) }
  }
  
  // plugin failed to load
  func webView(sender: WebView!, plugInFailedWithError error: NSError!, dataSource: WebDataSource!) {
    log("plugInFailedWithError error: \(error) dataSource: \(dataSource)\n")
    if !parser.ignore_http_errors.value { exit(EX_IOERR) }
  }
  
  // assign each resource a unique identifier when loading
  func webView(sender: WebView!, identifierForInitialRequest request: NSURLRequest!, fromDataSource dataSource: WebDataSource!) -> AnyObject! {
    let resourceId = resourceCount
    resourceCount += 1
    log("identifierForInitialRequest request: \(request) dataSource: \(dataSource) (resource id: \(resourceId))\n")
    return resourceId
  }
  
  // notification that a resource has been loaded successfully
  func webView(sender: WebView!, resource identifier: AnyObject!, didFinishLoadingFromDataSource dataSource: WebDataSource!) {
    log("didFinishLoadingFromDataSource identifier: \(identifier) dataSource: \(dataSource)\n")
  }
  
  func timerFired(timer: NSTimer) {
    log(" **** TIMER FIRED ***\n")
    makePDF()
  }
  
  func makePDF() {
    log("webView \(webView) makePDF\n")
    if parser.no_paginate.value {
      makeSinglePagePDF()
    } else {
      makePaginatedPDF()
    }
  }
   
  func makePaginatedPDF() {
    
    log("Make paginated PDF...\n")
    
    let sharedInfo = NSPrintInfo.sharedPrintInfo
    let printInfoDict = sharedInfo().dictionary()
    
    printInfoDict.setObject(NSPrintSaveJob,forKey: NSPrintJobDisposition)
    printInfoDict.setObject(parser.output!,forKey: NSPrintJobSavingURL)
    
    var printInfoDict_Swift = [String: AnyObject]()
    for (k,v) in printInfoDict {
      printInfoDict_Swift[k as! String] = v
    }
    let printInfo = NSPrintInfo(dictionary: printInfoDict_Swift)
    printInfo.horizontalPagination = NSPrintingPaginationMode.AutoPagination
    printInfo.verticalPagination = NSPrintingPaginationMode.AutoPagination
    printInfo.verticallyCentered = parser.verticallyCentered.value
    printInfo.horizontallyCentered = !parser.noHorizontallyCentered.value
    do {
      try printInfo.orientation = parser.paper_orientation.value!.getNSPaperOrientation()
    } catch {
      log("Error setting paper orientation\n")
      exit(EX_CONFIG)
    }
    printInfo.paperSize = parser.paperSize!
    
    if parser.margins != nil {
      printInfo.topMargin = CGFloat(parser.margins!.0)
      printInfo.rightMargin = CGFloat(parser.margins!.1)
      printInfo.bottomMargin = CGFloat(parser.margins!.2)
      printInfo.leftMargin = CGFloat(parser.margins!.3)
    }
    
    let viewToPrint = webView.mainFrame.frameView.documentView
    let printOp = NSPrintOperation(view: viewToPrint,printInfo: printInfo)
    printOp.showsPrintPanel = false
    printOp.showsProgressPanel = false
    log("Start NSPrintOperation\n")
    let ok = printOp.runOperation()
    log("Terminate application. Printing was \(ok)\n")
    exit(EX_OK)
  }
  
  /* jld: debug helper function from Ruby version?
  # log all respondsToSelector calls. This helps to spot possibly interesting
  # delegation calls
  #def respondsToSelector(sel)
  #  log "checked for SEL: #{sel}\n"
  #  return super.respondsToSelector(sel)
  #end
  
 */
  
  func makeSinglePagePDF() {
    log("Make single-page PDF...\n")
    let viewToPrint = webView.mainFrame.frameView.documentView
    var r = viewToPrint.bounds
    if parser.margins != nil {
      r.origin.x -= CGFloat(parser.margins!.1)
      r.origin.y -= CGFloat(parser.margins!.0)
      r.size.width += CGFloat(parser.margins!.1 + parser.margins!.3)
      r.size.height += CGFloat(parser.margins!.0 + parser.margins!.2)
    }
    
    log("Create PDF with bounds \(r)\n")
    let data = viewToPrint.dataWithPDFInsideRect(r)
    log("Save PDF to file \(parser.output)\n")
    do {
      try data.writeToURL(parser.output!, options: NSDataWritingOptions.DataWritingAtomic)
      exit(EX_OK)
    } catch {
      print("Error writing to \(parser.output): \(error)")
      exit(EX_IOERR)
    }
  }
  
  func checkResponseCodeforFrame(sender: WebView, frame : WebFrame) {
    let response = frame.dataSource?.response
    if !(response?.isKindOfClass(NSHTTPURLResponse))! { return }
    
    let response2 = response as! NSHTTPURLResponse
    let statusCode = response2.statusCode
    if statusCode >= 200 && statusCode <= 299 { return }
    
    print("could not load resource \(response2.URL?.absoluteString), HTTP status code \(statusCode)")
    exit(EX_IOERR)
  }
  
  func loadUserScript(sender: WebView, continuation: () -> Void) {
    log("Loading user script \(parser.user_script.value)\n")
    let urlRequest = NSURLRequest(URL: NSURL(fileURLWithPath: parser.user_script.value!), cachePolicy: parser.cachingPolicy, timeoutInterval: parser.timeout.value!)
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(urlRequest) {
      (data, response, error) in
      if error == nil {
        // NB: run this on the main thread since continuation() creates a timer callback.
        // When running on a non-main thread, I saw sporadic CFRUNLOOP_IS_CALLING_OUT_TO_A_TIMER_CALLBACK_FUNCTION crashes.
        dispatch_async(dispatch_get_main_queue(), {
          let js = NSString(data: data!, encoding: NSUTF8StringEncoding)
          sender.stringByEvaluatingJavaScriptFromString(js! as String)
          
          continuation() // prints the PDF after the save timer elapses
        })
      } else {
        log("Could not load user script \(parser.user_script.value), response: \(response), error: \(error)\n")
        if !parser.ignore_http_errors.value { exit(EX_IOERR) }
      }
    }
    
    task.resume()
  }
  
}

private func log(msg: String) {
  if parser.debug.value {
    fputs(msg, stderr)
  }
}