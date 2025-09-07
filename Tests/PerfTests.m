//
//  PerfTests.m
//

#import <XCTest/XCTest.h>
#import "TolerantDecoder.h"

@interface PerfTests : XCTestCase
@end

@implementation PerfTests

- (void)testDecoderPerformanceSmallStrings {
    [self measureBlock:^{
        for (int i = 0; i < 200; i++) {
            (void)[TolerantDecoder candidatesFor:@"stp" max:8];
            (void)[TolerantDecoder candidatesFor:@"wotld" max:8];
            (void)[TolerantDecoder candidatesFor:@"tezt" max:8];
        }
    }];
}

@end

