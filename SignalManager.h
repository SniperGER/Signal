#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#if (TARGET_OS_SIMULATOR)
#define PREFERENCES_PATH @"/opt/simject/FESTIVAL/ml.festival.signal.plist"
#else
#define PREFERENCES_PATH @"/var/mobile/Library/Preferences/ml.festival.signal.plist"
#endif

#define kCFCoreFoundationVersionNumber_iOS_10_x_Max 1349.56
#define kCFCoreFoundationVersionNumber_iOS_11_0 1443.00

@class SBTelephonyManager, SBWiFiManager, SBAirplaneModeController;

@interface SignalManager : NSObject {
	SBTelephonyManager* telephonyManager;
	SBWiFiManager* wifiManager;
	SBAirplaneModeController* airplaneModeController;
	
	NSMutableDictionary* preferences;
	BOOL connectionEnabled;
	BOOL connectionInitialized;
	BOOL airplaneModeEnabled;
	
	NSTimer* connectionInitTimer;
}

+ (BOOL)enabled;

- (void)preferencesChanged;
- (BOOL)cellularRadioCapabilityIsActive;
- (BOOL)cellularConnectionInitialized;
- (BOOL)forceCustomCarrier;
- (void)airplaneModeChanged;
- (void)_updateState;
- (int)signalStrengthBars;
- (id)operatorName;
- (int)dataConnectionType:(int)currentConnectionType;

@end
