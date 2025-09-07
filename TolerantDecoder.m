//
//  TolerantDecoder.m
//  Avro Keyboard
//

#import "TolerantDecoder.h"
#import "NSString+Levenshtein.h"

@implementation TolerantDecoder

+ (NSArray<NSString *> *)candidatesFor:(NSString *)roman max:(NSUInteger)maxCount {
    if (!roman) return @[];
    NSMutableOrderedSet<NSString *> *out = [[NSMutableOrderedSet alloc] init];
    // Always include original first
    [out addObject:roman];

    // Adjacent swap (single transposition)
    NSUInteger len = [roman length];
    if (len >= 2) {
        for (NSUInteger i = 0; i + 1 < len && out.count < MAX(1, maxCount); i++) {
            NSMutableString *m = [roman mutableCopy];
            unichar a = [roman characterAtIndex:i];
            unichar b = [roman characterAtIndex:i+1];
            [m replaceCharactersInRange:NSMakeRange(i, 2)
                             withString:[NSString stringWithCharacters:(unichar[]){b,a} length:2]];
            [out addObject:m];
        }
    }

    // Missing vowel insertion (insert a common vowel between consonant clusters)
    NSCharacterSet *vowels = [NSCharacterSet characterSetWithCharactersInString:@"aeiou"]; // lowercase expected
    for (NSUInteger i = 0; i <= len && out.count < MAX(2, maxCount); i++) {
        if (i > 0 && i < len) {
            unichar p = [roman characterAtIndex:i-1];
            unichar c = [roman characterAtIndex:i];
            if (![[NSCharacterSet letterCharacterSet] characterIsMember:p] ||
                ![[NSCharacterSet letterCharacterSet] characterIsMember:c]) {
                continue;
            }
            if (![vowels characterIsMember:p] && ![vowels characterIsMember:c]) {
                // Try a small set of vowels; add until max reached
                for (NSString *v in @[@"a", @"e"]) {
                    NSMutableString *m = [roman mutableCopy];
                    [m insertString:v atIndex:i];
                    [out addObject:m];
                    if (out.count >= maxCount && maxCount > 0) break;
                }
            }
        }
    }

    // Keyboard neighbor substitution (small, safe map)
    NSDictionary<NSString*, NSArray<NSString*>*> *near = @{
        @"t": @[@"r", @"y"],
        @"e": @[@"w", @"r"],
        @"h": @[@"g", @"j"],
        @"n": @[@"b", @"m"],
        @"s": @[@"a", @"w", @"x", @"z"],
        @"z": @[@"s", @"x"],
    };
    for (NSUInteger i = 0; i < len && out.count < MAX(3, maxCount); i++) {
        NSString *ch = [[roman substringWithRange:NSMakeRange(i, 1)] lowercaseString];
        NSArray *alts = near[ch];
        if (!alts) continue;
        for (NSString *a in alts) {
            NSMutableString *m = [roman mutableCopy];
            [m replaceCharactersInRange:NSMakeRange(i, 1) withString:a];
            [out addObject:m];
            if (out.count >= maxCount && maxCount > 0) break;
        }
        if (out.count >= maxCount && maxCount > 0) break;
    }

    // Truncate if needed
    NSArray *arr = [out array];
    if (maxCount > 0 && arr.count > maxCount) {
        arr = [arr subarrayWithRange:NSMakeRange(0, maxCount)];
    }
    return arr;
}

+ (NSString *)bestFor:(NSString *)roman {
    NSArray *cands = [self candidatesFor:roman max:6];
    NSString *best = roman;
    NSUInteger bestScore = NSUIntegerMax;
    for (NSString *c in cands) {
        NSUInteger d = [roman levenshteinDistanceTo:c];
        if (d < bestScore) {
            bestScore = d;
            best = c;
        }
    }
    return best;
}

@end
