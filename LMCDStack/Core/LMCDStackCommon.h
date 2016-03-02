//
//  NSManagedObject_sync_config.h
//  Roskilde
//
//  Created by Lukasz Margielewski on 20/03/15.
//
//

#ifndef LMCDDBConfig_config_h
#define LMCDDBConfig_config_h

#define stringify(s) stri(s)
#define stri(s) @str(s)
#define str(s) #s


//#define DEBUG_CDDBSTACK 1
// Activate debug methods ONLY IN DEBUG RELEASES!!!

#if  DEBUG && DEBUG_CDDBSTACK
#define CDLog(format, ...) NSLog((@"%s [Line %d]: " format), __PRETTY_FUNCTION__, __LINE__,## __VA_ARGS__)
#else
#define CDLog(format, ...) while(0){}
#endif


#endif
