//
//  NormalizerTests.m
//  iAvroTests
//

#import <XCTest/XCTest.h>
#import "RomanNormalizer.h"

@interface NormalizerTests : XCTestCase
@end

@implementation NormalizerTests

- (void)testLowercasingAndWhitespace {
    NSString *in = @"  HeLLo   WORld  ";
    NSString *out = [RomanNormalizer normalize:in];
    XCTAssertEqualObjects(out, @"hello world");
}

- (void)testSmartQuotesAndDashes {
    NSString *in = @"“test”—‘ok’";
    NSString *out = [RomanNormalizer normalize:in];
    XCTAssertEqualObjects(out, @"\"test\"- 'ok'");
}

- (void)testMacronsFallbacks {
    NSString *in = @"k\u0101l\u012b"; // kālī
    NSString *out = [RomanNormalizer normalize:in];
    XCTAssertTrue([out containsString:@"aa"]);
    XCTAssertTrue([out containsString:@"ii"]);
}

@end

