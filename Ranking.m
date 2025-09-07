//
//  Ranking.m
//  Avro Keyboard
//

#import "Ranking.h"
#import "NSString+Levenshtein.h"

@implementation Ranking

+ (NSArray<NSString *> *)rankRoman:(NSArray<NSString *> *)candidates forInput:(NSString *)roman {
    if (!candidates || candidates.count == 0) return @[];
    return [candidates sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
        NSUInteger da = [roman levenshteinDistanceTo:a];
        NSUInteger db = [roman levenshteinDistanceTo:b];
        if (da < db) return NSOrderedAscending;
        if (da > db) return NSOrderedDescending;
        // Tie-breakers: prefer exact input if present, then lexical
        if ([a isEqualToString:roman] && ![b isEqualToString:roman]) return NSOrderedAscending;
        if ([b isEqualToString:roman] && ![a isEqualToString:roman]) return NSOrderedDescending;
        return [a compare:b];
    }];
}

@end
