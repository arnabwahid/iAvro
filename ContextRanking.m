//
//  ContextRanking.m
//  Avro Keyboard
//

#import "ContextRanking.h"

static NSMutableArray<NSString *> *s_recentHistory;
static const NSUInteger kHistoryMax = 8; // small cap to keep things light

@implementation ContextRanking

+ (NSArray<NSString *> *)rankCandidates:(NSArray<NSString *> *)candidates
                           withHistory:(NSArray<NSString *> * _Nullable)history
{
    if (!candidates || candidates.count <= 1) return candidates ?: @[];
    // Scaffold: no-op pass-through for now.
    // Future: use `history` (recent committed tokens) to prefer contextually likely items.
    return [candidates copy];
}

+ (void)recordCommittedToken:(NSString *)token {
    if (token.length == 0) return;
    @synchronized(self) {
        if (!s_recentHistory) s_recentHistory = [[NSMutableArray alloc] init];
        // Deduplicate immediate repeats
        if (s_recentHistory.count > 0 && [s_recentHistory[0] isEqualToString:token]) return;
        [s_recentHistory insertObject:token atIndex:0];
        while (s_recentHistory.count > kHistoryMax) [s_recentHistory removeLastObject];
    }
}

+ (NSArray<NSString *> *)recentHistory:(NSUInteger)limit {
    @synchronized(self) {
        if (!s_recentHistory || s_recentHistory.count == 0) return @[];
        if (limit == 0 || limit >= s_recentHistory.count) return [s_recentHistory copy];
        NSRange r = NSMakeRange(0, limit);
        return [s_recentHistory subarrayWithRange:r];
    }
}

@end
