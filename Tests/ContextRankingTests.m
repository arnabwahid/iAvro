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

- (void)testBigramBoostMovesSeenPairUp {
    // Create a unique bigram prev->curr and ensure curr is boosted when prev is in history.
    NSString *prev = @"@prev@";
    NSString *curr = @"@curr@";
    [ContextRanking recordCommittedToken:prev];
    [ContextRanking recordCommittedToken:curr];
    NSArray *hist = @[ prev ];
    NSArray *input = @[ @"কি", curr, @"ক" ];
    NSArray *out = [ContextRanking rankCandidates:input withHistory:hist];
    XCTAssertEqualObjects(out[0], curr, @"Observed bigram should be boosted to front");
}

- (void)testPersistenceWritesBigramsToUserDefaults {
    // Clear any prior data
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ContextRankingBigrams"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *prev = @"alpha";
    NSString *next = @"beta";
    [ContextRanking recordCommittedToken:prev];
    [ContextRanking recordCommittedToken:next];
    NSDictionary *saved = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"ContextRankingBigrams"];
    XCTAssertNotNil(saved);
    NSDictionary *nexts = saved[prev];
    XCTAssertTrue([nexts isKindOfClass:[NSDictionary class]]);
    NSNumber *cnt = nexts[next];
    XCTAssertTrue(cnt != nil && cnt.integerValue >= 1);
}

- (void)testOffModeRespectsOriginalOrder {
    // Ensure that when the pref is OFF, maybeRankCandidates returns original order
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ContextRankingEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Teach a bigram to ensure ranking would otherwise change
    [ContextRanking recordCommittedToken:@"foo"];
    [ContextRanking recordCommittedToken:@"bar"];
    NSArray *hist = @[ @"foo" ];
    NSArray *input = @[ @"x", @"y", @"bar" ];
    NSArray *out = [ContextRanking maybeRankCandidates:input withHistory:hist];
    XCTAssertEqualObjects(out, input, @"OFF mode should preserve original order");
    // Restore to ON for other tests
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ContextRankingEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
