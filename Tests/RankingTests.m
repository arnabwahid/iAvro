//
//  RankingTests.m
//

#import <XCTest/XCTest.h>
#import "Ranking.h"

@interface RankingTests : XCTestCase
@end

@implementation RankingTests

- (void)testTiePrefersExactInput {
    NSArray *cands = @[ @"teh", @"the" ];
    NSArray *ranked = [Ranking rankRoman:cands forInput:@"teh"];
    XCTAssertEqualObjects(ranked.firstObject, @"teh");
}

- (void)testLexicalFallbackOnTie {
    NSArray *cands = @[ @"stap", @"step" ];
    // both distance 1 from 'stp' — lexical fallback should pick 'stap' first
    NSArray *ranked = [Ranking rankRoman:cands forInput:@"stp"];
    XCTAssertEqualObjects(ranked.firstObject, @"stap");
}

@end

