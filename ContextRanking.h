//
//  ContextRanking.h
//  Avro Keyboard
//

#import <Foundation/Foundation.h>

@interface ContextRanking : NSObject

// Returns a re-ordered copy of candidates using lightweight context.
// Initial scaffold: pass-through (returns input order).
+ (NSArray<NSString *> *)rankCandidates:(NSArray<NSString *> *)candidates
                           withHistory:(NSArray<NSString *> * _Nullable)history;

// Lightweight in-memory history store (per-process) for recent committed tokens.
+ (void)recordCommittedToken:(NSString *)token;
+ (NSArray<NSString *> *)recentHistory:(NSUInteger)limit; // most-recent-first, up to limit

@end
