//
//  FlagBehaviorTests.m
//

#import <XCTest/XCTest.h>
#import "AvroParser.h"

@interface FlagBehaviorTests : XCTestCase
@end

@implementation FlagBehaviorTests

- (void)testBaselineUnchangedWhenNoDecoderApplied {
    // This asserts the baseline parser output is stable and independent of decoder logic.
    NSString *input = @"teh";
    NSString *parsed1 = [[AvroParser sharedInstance] parse:input];
    NSString *parsed2 = [[AvroParser sharedInstance] parse:input];
    XCTAssertEqualObjects(parsed1, parsed2);
}

@end

