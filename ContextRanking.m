//
//  ContextRanking.m
//  Avro Keyboard
//

#import "ContextRanking.h"

static NSMutableArray<NSString *> *s_recentHistory;
static NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSNumber *> *> *s_bigrams; // prev -> (next -> count)
static const NSUInteger kHistoryMax = 8; // small cap to keep things light

@implementation ContextRanking

+ (NSArray<NSString *> *)rankCandidates:(NSArray<NSString *> *)candidates
                           withHistory:(NSArray<NSString *> * _Nullable)history
{
    if (!candidates || candidates.count <= 1) return candidates ?: @[];
    // Minimal heuristic: boost candidates observed to follow the last committed token.
    NSString *last = (history.count > 0 ? history[0] : nil);
    if (!last || !s_bigrams) {
        return [NSArray arrayWithArray:candidates];
    }
    NSDictionary<NSString *, NSNumber *> *nextCounts = s_bigrams[last];
    if (!nextCounts || nextCounts.count == 0) {
        return [NSArray arrayWithArray:candidates];
    }
    return [candidates sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
        NSInteger ca = [nextCounts[a] integerValue];
        NSInteger cb = [nextCounts[b] integerValue];
        if (ca != cb) {
            // Higher count (more frequently seen) comes first
            return (ca > cb) ? NSOrderedAscending : NSOrderedDescending;
        }
        // Stable tie-breaker: original order
        NSUInteger ia = [candidates indexOfObjectIdenticalTo:a];
        NSUInteger ib = [candidates indexOfObjectIdenticalTo:b];
        if (ia < ib) return NSOrderedAscending;
        if (ia > ib) return NSOrderedDescending;
        return NSOrderedSame;
    }];
}

+ (void)recordCommittedToken:(NSString *)token {
    if (token.length == 0) return;
    @synchronized(self) {
        if (!s_recentHistory) s_recentHistory = [[NSMutableArray alloc] init];
        // Update bigram counts using previous token (if any)
        NSString *prev = (s_recentHistory.count > 0 ? s_recentHistory[0] : nil);
        if (prev && token) {
            if (!s_bigrams) s_bigrams = [[NSMutableDictionary alloc] init];
            NSMutableDictionary<NSString *, NSNumber *> *nextMap = s_bigrams[prev];
            if (!nextMap) {
                nextMap = [[NSMutableDictionary alloc] init];
                s_bigrams[prev] = nextMap;
            }
            NSNumber *n = nextMap[token];
            NSInteger c = n ? [n integerValue] : 0;
            nextMap[token] = [NSNumber numberWithInteger:(c + 1)];
        }
        // Deduplicate immediate repeats
        if (s_recentHistory.count > 0 && [s_recentHistory[0] isEqualToString:token]) return;
        [s_recentHistory insertObject:token atIndex:0];
        while (s_recentHistory.count > kHistoryMax) [s_recentHistory removeLastObject];
    }
}

+ (NSArray<NSString *> *)recentHistory:(NSUInteger)limit {
    @synchronized(self) {
        if (!s_recentHistory || s_recentHistory.count == 0) return @[];
        if (limit == 0 || limit >= s_recentHistory.count) return [NSArray arrayWithArray:s_recentHistory];
        NSRange r = NSMakeRange(0, limit);
        return [s_recentHistory subarrayWithRange:r];
    }
}

@end
