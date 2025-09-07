//
//  IntegrationBengaliTests.m
//

#import <XCTest/XCTest.h>
#import "RomanNormalizer.h"
#import "TolerantDecoder.h"
#import "Suggestion.h"

@interface IntegrationBengaliTests : XCTestCase
@end

@implementation IntegrationBengaliTests

- (void)assertSuggestions:(NSArray *)s contain:(NSString *)expected message:(NSString *)msg {
    BOOL ok = NO;
    for (id obj in s) {
        if ([obj isKindOfClass:[NSString class]] && [(NSString *)obj isEqualToString:expected]) { ok = YES; break; }
    }
    XCTAssertTrue(ok, @"%@ — expected '%@' in %@", msg, expected, s);
}

- (void)testTopCandidatesContainExpectedWithDecoderON {
    // A few canonical words (allowing small typos); we assert presence among suggestions.
    NSArray *cases = @[
        @[ @"bnagla", @"বাংলা" ],   // bangla with swap
        @[ @"bhallo", @"ভালো" ],    // bhalo with extra letter
        @[ @"ekhon",  @"এখন" ],
        @[ @"shobdo", @"শব্দ" ],
    ];
    for (NSArray *row in cases) {
        NSString *roman = row[0];
        NSString *expectedBn = row[1];
        NSString *norm = [RomanNormalizer normalize:roman];
        NSString *best = [TolerantDecoder bestFor:norm];
        NSArray *sug = [[Suggestion sharedInstance] getList:best];
        [self assertSuggestions:sug contain:expectedBn message:[NSString stringWithFormat:@"roman=%@ best=%@", roman, best]];
    }
}

- (void)testFlagOFFBaselineUnaffectedForBaselineInputs {
    // Without decoder correction, using exact romans still yields expected suggestions present
    NSArray *cases = @[
        @[ @"bangla", @"বাংলা" ],
        @[ @"bikolpo", @"বিকল্প" ],
    ];
    for (NSArray *row in cases) {
        NSString *roman = row[0];
        NSString *expectedBn = row[1];
        NSString *norm = [RomanNormalizer normalize:roman];
        NSArray *sug = [[Suggestion sharedInstance] getList:norm];
        [self assertSuggestions:sug contain:expectedBn message:[NSString stringWithFormat:@"roman=%@", roman]];
    }
}

- (void)testNegativeNotPresent {
    NSArray *sug = [[Suggestion sharedInstance] getList:@"xyzq"];
    for (id obj in sug) {
        XCTAssertFalse([obj isKindOfClass:[NSString class]] && [(NSString *)obj isEqualToString:@"বাংলা"], @"Unexpected 'বাংলা' for xyzq");
    }
}

- (void)testDeterminismCandidatesOrderStable {
    NSArray *c1 = [TolerantDecoder candidatesFor:@"tezt" max:10];
    NSArray *c2 = [TolerantDecoder candidatesFor:@"tezt" max:10];
    XCTAssertEqualObjects(c1, c2);
}

@end

