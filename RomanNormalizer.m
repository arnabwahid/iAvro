//
//  RomanNormalizer.m
//  Avro Keyboard
//

#import "RomanNormalizer.h"

@implementation RomanNormalizer

+ (NSString *)normalize:(NSString *)input {
    if (input == nil || [input length] == 0) {
        return input ?: @"";
    }
    NSMutableString *s = [input mutableCopy];
#if !__has_feature(objc_arc)
    [s autorelease];
#endif

    // 1) Normalize Unicode (NFKC) to make composed forms consistent.
#if __has_feature(objc_arc)
    CFMutableStringRef cf = (__bridge CFMutableStringRef)s;
#else
    CFMutableStringRef cf = (CFMutableStringRef)s;
#endif
    CFStringNormalize(cf, kCFStringNormalizationFormKC);

    // 2) Lowercase for consistent matching (mutate in place).
    NSString *lower = [s lowercaseString];
    [s setString:lower];

    // 3) Replace smart quotes and dashes with ASCII equivalents.
    NSDictionary *punct = @{
        @"“": @"\"", @"”": @"\"",
        @"‘": @"'",  @"’": @"'",
        @"–": @" - ",   @"—": @" - ",
        @"…": @"..."
    };
    for (NSString *k in punct) {
        [s replaceOccurrencesOfString:k withString:punct[k]
                               options:0 range:NSMakeRange(0, [s length])];
    }

    // 4) Map a few common macrons to ASCII doubles (optional, safe fallbacks).
    NSDictionary *macrons = @{
        @"ā": @"aa",
        @"ī": @"ii",
        @"ū": @"uu",
        @"ē": @"e",
        @"ō": @"o"
    };
    for (NSString *k in macrons) {
        [s replaceOccurrencesOfString:k withString:macrons[k]
                               options:0 range:NSMakeRange(0, [s length])];
    }

    // 5) Collapse runs of whitespace to a single space and trim.
    NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSArray *parts = [s componentsSeparatedByCharactersInSet:ws];
    NSMutableArray *filtered = [NSMutableArray arrayWithCapacity:[parts count]];
    for (NSString *p in parts) {
        if ([p length] > 0) [filtered addObject:p];
    }
    NSString *joined = [filtered componentsJoinedByString:@" "];
    return joined;
}

@end
