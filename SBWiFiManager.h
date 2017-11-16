#import <Foundation/Foundation.h>

@interface SBWiFiManager : NSObject

+ (id)sharedInstance;
- (BOOL)isAssociated;
- (int)signalStrengthBars;
- (id)currentNetworkName;

@end
