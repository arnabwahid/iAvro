//
//  DecoderEdgeTests.m
//

#import <XCTest/XCTest.h>
#import "TolerantDecoder.h"

@interface DecoderEdgeTests : XCTestCase
@end

@implementation DecoderEdgeTests

- (void)testSingleDeletionCandidatesContainDroppedCharVariant {
    NSArray *c = [TolerantDecoder candidatesFor:@"wrod" max:10];
    // dropping 'r' yields 'wod'
    XCTAssertTrue([c containsObject:@"wod"]);
}

- (void)testCapRespected {
    NSArray *c = [TolerantDecoder candidatesFor:@"abcdef" max:5];
    XCTAssertTrue(c.count <= 5);
}

@end

