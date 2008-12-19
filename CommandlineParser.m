//
//  CommandlineParser.m
//  wkpdf
//
//  Created by Christian Plessl on 16.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "CommandlineParser.h"
#import "Debugging.h"
#import "Helper.h"
#import "version.h"

@implementation CommandlineParser

static CommandlineParser *sharedCommandlineParser = nil; // singleton instance

// declared by getopt
// TODO: check what is really needed
extern char *optarg;
extern int optind;
extern int optopt;
extern int opterr;
extern int optreset;

const double DEFAULT_TIMEOUT_FOR_URLREQUEST = 24 * 60 * 60.0;

+ (CommandlineParser *)sharedInstance
{  

  @synchronized(self) {
    if (sharedCommandlineParser == nil) {
      [[self alloc] init]; // assignment not done here
    }
  }
  return sharedCommandlineParser;
}

+ (id)allocWithZone:(NSZone *)zone
{
  @synchronized(self) {
    if (sharedCommandlineParser == nil) {
      sharedCommandlineParser = [super allocWithZone:zone];
      [sharedCommandlineParser setDefaults];
      // assignment and return on first allocation
      return sharedCommandlineParser;
    } 
  }
  // on subsequent allocation attempts return nil
  return nil;
}
  
- (id)copyWithZone:(NSZone *)zone
{
  return self;
}

- (id)retain
{
  return self;
}

- (unsigned)retainCount
{
  return UINT_MAX; // denotes object that cannot be released
}

- (void)release
{
  // do nothing
}

- (id)autorelease
{
  return self;
}

- (CommandlineParser *)setDefaults {
  LOG_DEBUG(@"setting default values for CommandlineParser");
  CommandlineParser * parser = [CommandlineParser sharedInstance];
  //_source = [NSURL fileURLWithPath:@"/dev/stdin"];
  //_output = @"/dev/stdout";
  _paperSize = [NSPrintInfo sizeForPaperName:@"A4"];
  _paginate = YES;
  _margin = [NSDecimalNumber notANumber];
  _stylesheetMedia = nil;
  _printBackground = NO;
  _paperOrientation = NSPortraitOrientation;
  _horizontallyCentered = NO;
  _verticallyCentered = NO;
  _cachingPolicy = NSURLRequestUseProtocolCachePolicy;
  _timeout = DEFAULT_TIMEOUT_FOR_URLREQUEST;
  _saveDelay = 0;
  _enablePlugins = NO;
  _ignoreHttpErrors = NO;
  _username = @"";
  _password = @"";
  return parser;
}
  
int opt_source, opt_output, opt_format, opt_paginate, opt_orientation;
int opt_hcenter, opt_vcenter, opt_help, opt_caching, opt_timeout, opt_saveDelay;
int opt_margin, opt_media, opt_background, opt_httperror;
int opt_username, opt_password, opt_plugins;
int dummy;

/* options descriptor */
static struct option longopts[] = {
  { "source",               required_argument,  &opt_source,     1 },  // 0
  { "output",               required_argument,  &opt_output,     1 },  // 1
  { "format",               required_argument,  &opt_format,     1 },  // 2
  { "portrait",             no_argument,        &dummy,          1 },  // 3
  { "landscape",            no_argument,        &dummy,          1 },  // 4
  { "hcenter",              no_argument,        &opt_hcenter,    1 },  // 5
  { "vcenter",              no_argument,        &opt_vcenter,    1 },  // 6
  { "help",                 no_argument,        &opt_help,       1 },  // 7
  { "caching",              required_argument,  &opt_caching,    1 },  // 8
  { "timeout",              required_argument,  &opt_timeout,    1 },  // 9
  { "version",              no_argument,        &dummy,          1 },  // 10
  { "margin",               required_argument,  &opt_margin,     1 },  // 11
  { "stylesheet-media",     required_argument,  &opt_media,      1 },  // 12
  { "print-background",     required_argument,  &opt_background, 1 },  // 13
  { "ignore-http-errors",   no_argument,        &opt_httperror,  1 },  // 14
  { "username",             required_argument,  &opt_username,   1 },  // 15
  { "password",             required_argument,  &opt_password,   1 },  // 16
  { "paginate",             required_argument,  &opt_paginate,   1 },  // 17
  { "enable-plugins",       required_argument,  &opt_plugins,    1 },  // 18
  { "save-delay",           required_argument,  &opt_saveDelay,  1 },  // 19
  { NULL,                   0,                  NULL,            0 }
};


// TODO: replace numerical switch labels with textual option names to make the 
//  parser more robust against changes in the option specification.
- (void)parseWithArgumentNumber:(int)argc andCommandline:(char * const *)argv {

  int ch;
  int option_index;
  BOOL hasFormatArg = NO;
  
  opt_source = opt_output = opt_format = opt_orientation = 0;
  opt_hcenter = opt_vcenter = opt_help = opt_caching = opt_timeout = 0;
  opt_paginate = opt_plugins = 0;
  
  while ((ch = getopt_long(argc, argv, "", longopts, &option_index)) != -1)
    
    switch (ch) {

      case 0:
        LOG_DEBUG(@"option_index=%d",option_index);

        switch (option_index) {
        
          case 0: // --source
            LOG_DEBUG(@"option: --source, value: %s",optarg);
            _source = [self parseSourcePathOrURL:optarg];
            break;

          case 1: // --output
            LOG_DEBUG(@"option: --output, value: %s",optarg);
            _output = [self parseOutputPath:optarg];
            break;

          case 2: // --format
            LOG_DEBUG(@"option: --format, value: %s",optarg);
            _paperSize = [self parsePaperSize:optarg];
            hasFormatArg = YES;
            break;
            
          case 3: // --portrait
            LOG_DEBUG(@"option --portrait");
            _paperOrientation = NSPortraitOrientation;
            break;

          case 4: // --landscape
            LOG_DEBUG(@"option --landscape");
            _paperOrientation = NSLandscapeOrientation;
            break;
            
          case 5: // --hcenter
            LOG_DEBUG(@"option --hcenter");
            _horizontallyCentered = YES;
            break;
            
          case 6: // --vcenter
            LOG_DEBUG(@"option --vcenter");
            _verticallyCentered = YES;
            break;
            
          case 7: // --help
            LOG_DEBUG(@"option --help");
            fprintf(stderr,[self usage]);
            exit(0);
            break;
            
          case 8: // --caching
            LOG_DEBUG(@"option --caching, value: %s",optarg);
            _cachingPolicy = [self parseCachingArgument:optarg];
            break;
            
          case 9: // --timeout
            LOG_DEBUG(@"option --timeout, value: %s",optarg);
            _timeout = [self parseTimeoutArgument:optarg];
            break;
          
          case 10: // --version
            fprintf(stdout,"%s",[[NSString stringWithFormat:@"wkpdf %@\n",[self getVersionString]] UTF8String]);
            exit(0);
            break;

          case 11: // --margin
            LOG_DEBUG(@"option: --margin, value: %s",optarg);
            _margin = [self parseDecimalNumber:optarg argName:@"--margin"];
            break;

          case 12: // --stylesheet-media
            LOG_DEBUG(@"option: --stylesheet-media, value: %s",optarg);
            _stylesheetMedia = [NSString stringWithUTF8String:optarg];
            break;

          case 13: // --print-background
            LOG_DEBUG(@"option: --print-background, value: %s",optarg);
            _printBackground = [self parseYesOrNo:optarg];
            LOG_DEBUG(@"_printBackground: %d", _printBackground);            
            break;

          case 14: // --ignore-http-errors
            LOG_DEBUG(@"option: --ignore-http-errors");
            _ignoreHttpErrors = YES;
            break;

          case 15: // --username
            LOG_DEBUG(@"option: --username, value: %s",optarg);
            _username = [NSString stringWithUTF8String:optarg];
            break;

          case 16: // --password
            LOG_DEBUG(@"option: --password, value: %s",optarg);
            _password = [NSString stringWithUTF8String:optarg];
            break;
          
          case 17: // --paginate
            LOG_DEBUG(@"option: --paginate, value: %s",optarg);
            _paginate = [self parseYesOrNo:optarg];
            LOG_DEBUG(@"_paginate: %d", _paginate);            
            break;

          case 18: // --enable-plugins
            LOG_DEBUG(@"option: --enable-plugins, value: %s",optarg);
            _enablePlugins = [self parseYesOrNo:optarg];
            LOG_DEBUG(@"_enablePlugins: %d", _enablePlugins);            
            break;
            
          case 19: // --save-delay
            LOG_DEBUG(@"option: --save-delay, value: %s",optarg);
            _saveDelay = [[self parseDecimalNumber:optarg argName:@"--save-delay"] doubleValue];
            LOG_DEBUG(@"_saveDelay: %f", _saveDelay);            
            break;
        }        
      break;
        
      case '?':
        [Helper terminateWithErrorcode:1 andMessage:@"wkpdf: unknown or ambigous command-line option"];
        // TODO: show usage here
        break;
      default:
        ;
    }
    argc -= optind;
    argv += optind;
    
    if (!_paginate && hasFormatArg){ 
      [Helper terminateWithErrorcode:1 andMessage:@"options --format and --paginate=no are exclusive as non-pagination resizes output page to fit content"];
    }
  
    if (!(opt_source && opt_output)){
      // TODO: show usage here
      [Helper terminateWithErrorcode:1 andMessage:@"options --source and --output are mandatory"];
    }
}

- (char *)usage
{
return ""  
"usage: wkpdf <options>\n"
"  --source URL|file         URL or file to be converted to PDF (mandatory)\n"  
"  --output file             filename for the PDF (mandatory)\n"
"  --portrait                use portrait paper orientation\n"
"  --landscape               use landscape paper orientation\n"
"  --hcenter                 center output horizontally\n"
"  --vcenter                 center output vertically\n"
"  --format arg              select paper format (valid values are e.g. A4, A5,\n"
"                            A3, Legal, Letter, Executive) CAUTION: these values\n"
"                            are case-sensitive\n"
"  --paginate arg            enable pagination of output (yes|no default: yes)\n"
"                            Output page is resized to fit content when paginate=no\n"
"  --margin arg              set paper margin in points (same value is used for\n"
"                            all 4 margins)\n"
"  --stylesheet-media arg    set the CSS media value (default: 'screen')\n"
"  --print-background arg    display background images (yes|no default: no)\n"
"  --enable-plugins arg      enable plugins (yes|no default: no)\n"
"  --ignore-http-errors      generate PDF even if server error occur (e.g.\n"
"                            server returns 404 Not Found errors.)\n"
"  --save-delay arg          wait x.y seconds after page is loaded\n"
"                            before generating the PDF\n"
"  --username arg            authenticate with this username\n"
"  --password arg            authenticate with this password\n"
"                            pages with HTTP authentication can also be accessed\n"
"                            by using user:password@example.org style URLs\n"
//"  --caching arg     set caching policy (valid values are: yes, no) default is yes\n"
//"  --timeout arg     set timeout in seconds, default: no timeout\n"
"  --help                    print help on options\n"
"  --version                 print version number\n"
"\n"
"For further information refer to http://wkpdf.plesslweb.ch\n"
;
}

// TODO: implement
- (NSString *)description
{
  return @"description not implemented yet";
}

- (void)prettyprint
{
  LOG_DEBUG(@"source: %@", [_source absoluteString]);
  LOG_DEBUG(@"output: %@", _output);
}

- (NSURL *)source
{
  return [[_source copy] autorelease];
}

- (NSString *)output
{
  return [[_output copy] autorelease];
}

- (NSSize)paperSize
{
  return _paperSize;
}

- (BOOL)paginate
{
  return _paginate;
}

- (NSDecimalNumber *)margin
{
  return [[_margin copy] autorelease];
}

- (NSString *)stylesheetMedia
{
  return [[_stylesheetMedia copy] autorelease];
}

- (BOOL)printBackground
{
  return _printBackground;
}

- (NSPrintingOrientation)paperOrientation
{
  return _paperOrientation;
}

- (BOOL)horizontallyCentered
{
  return _horizontallyCentered;
}

- (BOOL)verticallyCentered
{
  return _verticallyCentered;
}

- (NSURLRequestCachePolicy)cachingPolicy
{
  return _cachingPolicy;
}

- (NSTimeInterval)timeout
{
  return _timeout;
}

- (NSTimeInterval)saveDelay
{
  return _saveDelay;
}

- (BOOL)enablePlugins
{
  return _enablePlugins;
}

- (BOOL)ignoreHttpErrors
{
  return _ignoreHttpErrors;
}

- (NSString *)username
{
  return [[_username copy] autorelease];
}

- (NSString *)password
{
  return [[_password copy] autorelease];
}

#pragma mark helper functions

- (NSSize)parsePaperSize:(char *)arg
{
  NSString * paperName = [NSString stringWithUTF8String:arg];
  NSSize size = [NSPrintInfo sizeForPaperName:paperName];
  if ((size.width == 0.0) && (size.height == 0.0)){
    fprintf(stderr,"%s is not a valid paper format!\n",arg);
    [Helper terminateWithErrorcode:1 andMessage:@"invalid paper format"];
  }
  return size;
}

- (NSDecimalNumber*)parseDecimalNumber:(char *)arg argName:(NSString *)argName
{
  NSString * str = [NSString stringWithUTF8String:arg];
  NSDecimalNumber * value = [NSDecimalNumber decimalNumberWithString:str];
  double d = [value doubleValue];
  LOG_DEBUG(@"%@ = %f\n", argName, d);
  if (isnan(d)) {
    NSString * msg = [NSString stringWithFormat:@"Argument '%@' '%@' is not a valid decimal number.", argName, str];
    fprintf(stderr, "%@\n", msg);
    [Helper terminateWithErrorcode:1 andMessage:msg];
  }
  return value;
}

- (NSURL *)parseSourcePathOrURL:(char *)arg
{
  NSURL * url;
  NSString * argAsString = [NSString stringWithUTF8String:arg]; 
  NSString * path = [ argAsString stringByExpandingTildeInPath];
  NSFileManager * fm = [NSFileManager defaultManager];
  BOOL argIsFile = [fm fileExistsAtPath:path];
  if (argIsFile){
    url = [NSURL fileURLWithPath:path];
  } else {
    url = [NSURL URLWithString:argAsString];

    // check URL validity
    NSArray * supportedSchemes = [NSArray arrayWithObjects:@"http", @"https", @"ftp", @"file", nil];
    NSString *scheme = [url scheme];
    LOG_DEBUG(@"--source URL scheme=%@\n",scheme);
    if ((scheme == nil) || 
        ([supportedSchemes indexOfObject:[scheme lowercaseString]] == NSNotFound)){
      NSString * errorMsg = [NSString stringWithFormat:
        @"%@ is neither a filename nor an URL with a supported scheme (http,https,ftp,file)",
        argAsString];
      [Helper terminateWithErrorcode:1 andMessage:errorMsg];
    }
  }
  return url;
}

- (NSString *)parseOutputPath:(char *)arg;
{
  NSString * argAsString = [NSString stringWithUTF8String:arg]; 
  NSString * path = [ argAsString stringByExpandingTildeInPath];
  return path;
}

- (BOOL)parseYesOrNo:(char *)arg;
{
  NSString * argAsString = [NSString stringWithUTF8String:arg];
  if ([argAsString caseInsensitiveCompare:@"yes"] == NSOrderedSame){
    return YES;
  }
  return NO;
}

- (NSURLRequestCachePolicy)parseCachingArgument:(char *)optarg;
{

  if (strcmp(optarg,"no") == 0){
    LOG_DEBUG(@"disable caching of webpages");
    return NSURLRequestReloadIgnoringCacheData;
  }
  return NSURLRequestUseProtocolCachePolicy;
}

- (NSTimeInterval)parseTimeoutArgument:(char *)optarg;
{
  double timeout = strtod(optarg,NULL);
  LOG_DEBUG(@"timeout = %f\n",timeout);
  return timeout;
}

- (NSString *)getVersionString
{
  unsigned revisionLength = [WKPDF_SVN_REVISION length] - 8;
  NSString * revString = [WKPDF_SVN_REVISION substringWithRange:NSMakeRange(6,revisionLength)];
  NSString * version = [NSString stringWithFormat:@"%d.%d.%d (r%@)",
    WKPDF_VERSION_MAJOR, WKPDF_VERSION_MINOR, WKPDF_VERSION_SUBMINOR, revString];
  return [version autorelease];
}

@end
