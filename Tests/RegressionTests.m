//
//  RegressionTests.m
//  iAvroTests
//

#import <XCTest/XCTest.h>
#import "RomanNormalizer.h"
#import "TolerantDecoder.h"

@interface RegressionTests : XCTestCase
@end

@implementation RegressionTests

- (void)testDecoderTSV {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"decoder" ofType:@"tsv"];
    XCTAssertNotNil(path);
    NSError *err = nil;
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    XCTAssertNil(err);
    NSArray<NSString *> *lines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (NSString *line in lines) {
        if (line.length == 0) continue;
        if ([line hasPrefix:@"input\t"]) continue; // header
        NSArray *cols = [line componentsSeparatedByString:@"\t"];
        if (cols.count < 2) continue;
        NSString *input = cols[0];
        NSString *expected = cols[1];
        NSString *norm = [RomanNormalizer normalize:input];
        NSString *best = [TolerantDecoder bestFor:norm];
        XCTAssertEqualObjects(best, expected, @"Input=%@ norm=%@", input, norm);
    }
}

@end

