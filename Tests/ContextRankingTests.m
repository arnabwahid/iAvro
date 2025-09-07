//
//  ContextRankingTests.m
//  iAvroTests
//

#import <XCTest/XCTest.h>
#import "ContextRanking.h"

@interface ContextRankingTests : XCTestCase
@end

@implementation ContextRankingTests

- (void)testPassThroughRankingWhenUnavailable {
    // This test exercises the ranking scaffold directly.
    NSArray *input = @[ @"ক", @"কা", @"কি" ];
    NSArray *out = [ContextRanking rankCandidates:input withHistory:@[]];
    XCTAssertEqualObjects(out, input, @"Scaffold should be pass-through");
}

- (void)testHistoryRecordingIsSafeAndOrderStable {
    [ContextRanking recordCommittedToken:@"টেস্ট"];
    NSArray *hist = [ContextRanking recentHistory:3];
    XCTAssertTrue(hist.count >= 1);
    NSArray *input = @[ @"ক", @"কা", @"কি" ];
    NSArray *out = [ContextRanking rankCandidates:input withHistory:hist];
    XCTAssertEqualObjects(out, input, @"Scaffold ranking should remain stable");
}

@end
