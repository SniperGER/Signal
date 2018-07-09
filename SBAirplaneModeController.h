#import <Foundation/Foundation.h>

@interface SBAirplaneModeController : NSObject

+ (id)sharedInstance;
- (BOOL)isInAirplaneMode;
- (void)airplaneModeChanged;

@end
