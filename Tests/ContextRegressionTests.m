//
//  ContextRegressionTests.m
//  iAvroTests
//

#import <XCTest/XCTest.h>
#import "ContextRanking.h"

@interface ContextRegressionTests : XCTestCase
@end

@implementation ContextRegressionTests

- (void)testContextTSVBigramBoost {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"context" ofType:@"tsv" inDirectory:@"Tests/Regression"];
    XCTAssertNotNil(path);
    NSError *err = nil;
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    XCTAssertNil(err);
    NSArray<NSString *> *lines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (NSString *line in lines) {
      if (line.length == 0) continue;
      if ([line hasPrefix:@"prev\t"]) continue;
      NSArray *cols = [line componentsSeparatedByString:@"\t"];
      if (cols.count < 3) continue;
      NSString *prev = cols[0];
      NSString *expectedTop = cols[1];
      NSArray *cands = [cols[2] componentsSeparatedByString:@","];

      // Teach bigram prev->expectedTop
      [ContextRanking recordCommittedToken:prev];
      [ContextRanking recordCommittedToken:expectedTop];

      // Rank with history containing prev
      NSArray *out = [ContextRanking rankCandidates:cands withHistory:@[prev]];
      XCTAssertGreaterThan(out.count, 0U);
      XCTAssertEqualObjects(out[0], expectedTop, @"Expected top after prev=%@", prev);
    }
}

@end

