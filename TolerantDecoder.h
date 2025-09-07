//
//  TolerantDecoder.h
//  Avro Keyboard
//

#import <Foundation/Foundation.h>

@interface TolerantDecoder : NSObject

// Generate up to N roman input candidates including the original.
+ (NSArray<NSString *> *)candidatesFor:(NSString *)roman max:(NSUInteger)maxCount;

// Convenience: choose the single best roman candidate for lookup.
+ (NSString *)bestFor:(NSString *)roman;

@end

