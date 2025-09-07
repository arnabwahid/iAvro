//
//  ContextRanking.m
//  Avro Keyboard
//

#import "ContextRanking.h"
#import <Foundation/Foundation.h>

static NSMutableArray<NSString *> *s_recentHistory;
static NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSNumber *> *> *s_bigrams; // prev -> (next -> count)
static const NSUInteger kHistoryMax = 5; // small cap to keep things light
static NSString * const kBigramsDefaultsKey = @"ContextRankingBigrams";
static const NSUInteger kPrevMax = 64;      // cap number of prev tokens to persist
static const NSUInteger kNextPerPrevMax = 8; // cap next variants per prev

static void ensureStoresLoaded(void) {
    if (!s_bigrams) {
        NSDictionary *saved = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kBigramsDefaultsKey];
        s_bigrams = [[NSMutableDictionary alloc] init];
        if ([saved isKindOfClass:[NSDictionary class]]) {
            [saved enumerateKeysAndObjectsUsingBlock:^(NSString *prev, NSDictionary *nexts, BOOL *stop) {
                if (![prev isKindOfClass:[NSString class]] || ![nexts isKindOfClass:[NSDictionary class]]) return;
                NSMutableDictionary<NSString *, NSNumber *> *mutableNexts = [[NSMutableDictionary alloc] init];
                [nexts enumerateKeysAndObjectsUsingBlock:^(NSString *nxt, NSNumber *cnt, BOOL *stop2) {
                    if ([nxt isKindOfClass:[NSString class]] && [cnt isKindOfClass:[NSNumber class]]) {
                        mutableNexts[nxt] = cnt;
                    }
                }];
                s_bigrams[prev] = mutableNexts;
            }];
        }
    }
}

static void persistBigrams(void) {
    if (!s_bigrams) return;
    // Enforce caps: limit number of prev keys and next variants per prev (by lowest count pruning)
    if (s_bigrams.count > kPrevMax) {
        NSArray *keys = [s_bigrams allKeys];
        NSMutableArray *scored = [NSMutableArray arrayWithCapacity:keys.count];
        for (NSString *k in keys) {
            NSDictionary *m = s_bigrams[k];
            NSInteger sum = 0; for (NSNumber *v in [m allValues]) sum += v.integerValue;
            [scored addObject:@{ @"k": k, @"s": @(sum) }];
        }
        [scored sortUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b){
            return [a[@"s"] integerValue] < [b[@"s"] integerValue] ? NSOrderedAscending : NSOrderedDescending;
        }];
        for (NSUInteger i = kPrevMax; i < scored.count; i++) {
            NSString *drop = scored[i][@"k"];
            [s_bigrams removeObjectForKey:drop];
        }
    }
    for (NSString *prev in [s_bigrams allKeys]) {
        NSMutableDictionary<NSString *, NSNumber *> *nextMap = s_bigrams[prev];
        if (nextMap.count > kNextPerPrevMax) {
            NSArray *pairs = [nextMap allKeys];
            NSArray *sorted = [pairs sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b){
                NSInteger ca = [nextMap[a] integerValue];
                NSInteger cb = [nextMap[b] integerValue];
                if (ca == cb) return NSOrderedSame;
                return (ca > cb) ? NSOrderedAscending : NSOrderedDescending;
            }];
            NSSet *keep = [NSSet setWithArray:[sorted subarrayWithRange:NSMakeRange(0, kNextPerPrevMax)]];
            for (NSString *key in [nextMap allKeys]) {
                if (![keep containsObject:key]) [nextMap removeObjectForKey:key];
            }
        }
    }
    NSMutableDictionary *toSave = [NSMutableDictionary dictionaryWithCapacity:s_bigrams.count];
    [s_bigrams enumerateKeysAndObjectsUsingBlock:^(NSString *prev, NSDictionary *nexts, BOOL *stop){
        toSave[prev] = [nexts copy];
    }];
    [[NSUserDefaults standardUserDefaults] setObject:toSave forKey:kBigramsDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@implementation ContextRanking

+ (NSArray<NSString *> *)rankCandidates:(NSArray<NSString *> *)candidates
                           withHistory:(NSArray<NSString *> * _Nullable)history
{
    if (!candidates || candidates.count <= 1) return candidates ?: @[];
    ensureStoresLoaded();
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

+ (NSArray<NSString *> *)maybeRankCandidates:(NSArray<NSString *> *)candidates
                                withHistory:(NSArray<NSString *> * _Nullable)history
{
    if (!candidates || candidates.count <= 1) return candidates ?: @[];
    BOOL enabled = NO;
    @try {
        enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"ContextRankingEnabled"];
    } @catch (__unused NSException *e) {}
    if (!enabled) return [NSArray arrayWithArray:candidates];
    return [self rankCandidates:candidates withHistory:history];
}

+ (void)recordCommittedToken:(NSString *)token {
    if (token.length == 0) return;
    @synchronized(self) {
        ensureStoresLoaded();
        if (!s_recentHistory) s_recentHistory = [[NSMutableArray alloc] init];
        // Update bigram counts using previous token (if any)
        NSString *prev = (s_recentHistory.count > 0 ? s_recentHistory[0] : nil);
        if (prev && token) {
            NSMutableDictionary<NSString *, NSNumber *> *nextMap = s_bigrams[prev];
            if (!nextMap) {
                nextMap = [[NSMutableDictionary alloc] init];
                s_bigrams[prev] = nextMap;
            }
            NSNumber *n = nextMap[token];
            NSInteger c = n ? [n integerValue] : 0;
            nextMap[token] = [NSNumber numberWithInteger:(c + 1)];
            // Simple decay: if total counts for this prev grow too large, halve all counts (min 1)
            NSInteger sum = 0; for (NSNumber *v in [nextMap allValues]) sum += v.integerValue;
            const NSInteger kDecaySumThreshold = 32;
            if (sum > kDecaySumThreshold) {
                for (NSString *k in [nextMap allKeys]) {
                    NSInteger val = [[nextMap objectForKey:k] integerValue];
                    NSInteger decayed = val / 2; if (decayed < 1) decayed = 1;
                    nextMap[k] = @(decayed);
                }
            }
        }
        // Deduplicate immediate repeats
        if (s_recentHistory.count > 0 && [s_recentHistory[0] isEqualToString:token]) return;
        [s_recentHistory insertObject:token atIndex:0];
        while (s_recentHistory.count > kHistoryMax) [s_recentHistory removeLastObject];
    }
    persistBigrams();
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
