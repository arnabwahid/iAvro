//
//  Ranking.h
//  Avro Keyboard
//

#import <Foundation/Foundation.h>

@interface Ranking : NSObject

// Rank roman candidates by edit distance to input (lower is better)
+ (NSArray<NSString *> *)rankRoman:(NSArray<NSString *> *)candidates forInput:(NSString *)roman;

@end

