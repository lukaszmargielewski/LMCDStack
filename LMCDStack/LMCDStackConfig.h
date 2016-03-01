//
//  NSManagedObject_sync_config.h
//  Roskilde
//
//  Created by Lukasz Margielewski on 20/03/15.
//
//

#ifndef LMCDDBConfig_config_h
#define LMCDDBConfig_config_h


//#define DEBUG_CDDBSTACK 1
// Activate debug methods ONLY IN DEBUG RELEASES!!!

#if  DEBUG && DEBUG_CDDBSTACK
#define CDLog(format, ...) NSLog((@"%s [Line %d]: " format), __PRETTY_FUNCTION__, __LINE__,## __VA_ARGS__)
#else
#define CDLog(format, ...) while(0){}
#endif

#if  DEBUG && DEBUG_SYNC
#define CDSyncLog(format, ...) NSLog((@"%s [Line %d]: " format), __PRETTY_FUNCTION__, __LINE__,## __VA_ARGS__)
#else
#define CDSyncLog(format, ...) while(0){}
#endif

#if  DEBUG && DEBUG_SYNC_REQUEST
#define CDSyncrequestLog(format, ...) NSLog((@"%s [Line %d]: " format), __PRETTY_FUNCTION__, __LINE__,## __VA_ARGS__)
#else
#define CDSyncrequestLog(format, ...) while(0){}
#endif

#if  DEBUG && DEBUG_SYNC_RESPONSE
#define CDSyncresponseLog(format, ...) NSLog((@"%s [Line %d]: " format), __PRETTY_FUNCTION__, __LINE__,## __VA_ARGS__)
#else
#define CDSyncresponseLog(format, ...) while(0){}
#endif


#if DEBUG && DEBUG_SYNC_DELETE
#define CDSyncDeleteLog(format, ...) NSLog((@"%s [Line %d]: " format), __PRETTY_FUNCTION__, __LINE__,## __VA_ARGS__)
#else
#define CDSyncDeleteLog(format, ...) while(0){}
#endif

#if DEBUG && DEBUG_SYNC_LOOP
#define CDSyncLoopLog(format, ...) NSLog((@"%s [Line %d]: " format), __PRETTY_FUNCTION__, __LINE__,## __VA_ARGS__)
#else
#define CDSyncLoopLog(format, ...) while(0){}
#endif

#if DEBUG && DEBUG_SYNC_PREDICATE
#define CDSyncPredLog(format, ...) NSLog((@"%s [Line %d]: " format), __PRETTY_FUNCTION__, __LINE__,## __VA_ARGS__)
#else
#define CDSyncPredLog(format, ...) while(0){}
#endif

#if DEBUG && DEBUG_SYNC_SEARCH
#define CDSyncSearchLog(format, ...) NSLog((@"%s [Line %d]: " format), __PRETTY_FUNCTION__, __LINE__,## __VA_ARGS__)
#else
#define CDSyncSearchLog(format, ...) while(0){}
#endif

#if DEBUG && DEBUG_SYNC_CACHE
#define CDSyncCacheLog(format, ...) NSLog((@"%s [Line %d]: " format), __PRETTY_FUNCTION__, __LINE__,## __VA_ARGS__)
#else
#define CDSyncCacheLog(format, ...) while(0){}
#endif

#if DEBUG && DEBUG_SYNC_UPDATE
#define CDSyncUpdateLog(format, ...) NSLog((@"%s [Line %d]: " format), __PRETTY_FUNCTION__, __LINE__,## __VA_ARGS__)
#else
#define CDSyncUpdateLog(format, ...) while(0){}
#endif

#if DEBUG && DEBUG_SYNC_FILTERS
#define CDSyncFiltersLog(format, ...) NSLog((@"%s [Line %d]: " format), __PRETTY_FUNCTION__, __LINE__,## __VA_ARGS__)
#else
#define CDSyncFiltersLog(format, ...) while(0){}
#endif

#if DEBUG && DEBUG_SYNC_DUPLICATES
#define CDSyncDupsLog(format, ...) NSLog((@"%s [Line %d]: " format), __PRETTY_FUNCTION__, __LINE__,## __VA_ARGS__)
#else
#define CDSyncDupsLog(format, ...) while(0){}
#endif


#endif
