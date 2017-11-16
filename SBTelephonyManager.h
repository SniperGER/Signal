#import <Foundation/Foundation.h>

@interface SBTelephonyManager : NSObject
	
+ (id)sharedTelephonyManager;
+ (id)sharedTelephonyManagerCreatingIfNecessary:(BOOL)arg1;
- (BOOL)hasCellularTelephony;
- (BOOL)hasCellularData;
- (void)_setRegistrationStatus:(int)arg1;
- (void)_setCellRegistrationStatus:(int)arg1;
- (BOOL)isInAirplaneMode;
- (void)_setIsNetworkTethering:(BOOL)arg1 withNumberOfDevices:(int)arg2;
- (void)_setSignalStrength:(int)arg1 andBars:(int)arg2;
- (int)signalStrengthBars;
- (void)_updateState;
- (void)airplaneModeChanged;
- (void)_updateDataConnectionType;
	
@end
