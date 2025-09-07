//
//  Top1RegressionTests.m
//

#import <XCTest/XCTest.h>
#import "RomanNormalizer.h"
#import "Suggestion.h"

@interface Top1RegressionTests : XCTestCase
@end

@implementation Top1RegressionTests

- (void)testTop1BengaliFromTable {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"top1" ofType:@"tsv"];
    XCTAssertNotNil(path);
    NSError *err = nil;
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    XCTAssertNil(err);
    NSArray<NSString *> *lines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (NSString *line in lines) {
        if (line.length == 0) continue;
        if ([line hasPrefix:@"roman\t"]) continue;
        NSArray *cols = [line componentsSeparatedByString:@"\t"];
        if (cols.count < 2) continue;
        NSString *roman = cols[0];
        NSString *expectedBn = cols[1];
        NSString *norm = [RomanNormalizer normalize:roman];
        NSArray *sug = [[Suggestion sharedInstance] getList:norm];
        XCTAssertGreaterThan(sug.count, 0U, @"No suggestions for %@", roman);
        NSString *top = sug.firstObject;
        XCTAssertEqualObjects(top, expectedBn, @"Top-1 mismatch for roman=%@ norm=%@ (top=%@)", roman, norm, top);
    }
}

@end

