//
//  RomanNormalizer.h
//  Avro Keyboard
//

#import <Foundation/Foundation.h>

@interface RomanNormalizer : NSObject

// Returns a normalized copy of the given latin/roman input string.
+ (NSString *)normalize:(NSString *)input;

@end

