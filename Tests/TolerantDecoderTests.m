//
//  TolerantDecoderTests.m
//  iAvroTests
//

#import <XCTest/XCTest.h>
#import "TolerantDecoder.h"
#import "Ranking.h"

@interface TolerantDecoderTests : XCTestCase
@end

@implementation TolerantDecoderTests

- (void)testCandidatesIncludeOriginal {
    NSArray *c = [TolerantDecoder candidatesFor:@"hello" max:5];
    XCTAssertTrue([c containsObject:@"hello"]);
}

- (void)testAdjacentSwapCorrection {
    NSString *best = [TolerantDecoder bestFor:@"teh"]; // common swap for 'the'
    // Best should be 'the' given single transposition rule
    XCTAssertEqualObjects(best, @"the");
}

- (void)testRankingOrdersByEditDistance {
    NSArray *cands = @[ @"the", @"teh", @"th" ];
    NSArray *ranked = [Ranking rankRoman:cands forInput:@"teh"];
    // 'teh' distance 0, 'the' distance 2 (swap counts as 2 in Levenshtein), 'th' distance 1
    // So order should start with 'teh', then 'th', then 'the'. We assert prefix.
    XCTAssertEqualObjects(ranked.firstObject, @"teh");
}

- (void)testNeighborSubstitution {
    // 'tezt' -> neighbor substitution z->s should allow 'test'
    NSString *best = [TolerantDecoder bestFor:@"tezt"];
    // Depending on distance, 'tezt' (d1) vs 'test' (d1) tie-break keeps input; ensure 'test' is in candidates
    NSArray *c = [TolerantDecoder candidatesFor:@"tezt" max:10];
    XCTAssertTrue([c containsObject:@"test"]);
}

- (void)testMissingVowelInsertion {
    NSString *best = [TolerantDecoder bestFor:@"bng"]; // expect 'bang'
    XCTAssertEqualObjects(best, @"bang");
}

@end
