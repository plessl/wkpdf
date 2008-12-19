/*
 *  Debugging.h
 *  wkpdf
 *
 *  Created by Christian Plessl on 09.06.07.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

#ifdef DEBUG
  #define LOG_DEBUG(fmt, ...) NSLog(fmt, ## __VA_ARGS__)
#else
  #define LOG_DEBUG(fmt, ...) //
#endif