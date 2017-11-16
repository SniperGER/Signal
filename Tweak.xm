#import "SignalManager.h"
#import "SBTelephonyManager.h"

static SignalManager* signalManager;

%group Signal

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)arg1 {
	%orig;
	
	signalManager = [[SignalManager alloc] init];
}

%end	// %hook SpringBoard

%hook SBTelephonyManager

- (void)_setRegistrationStatus:(int)arg1 {
	if ([signalManager cellularConnectionInitialized]) {
		%orig(2);
	} else {
		%orig;
	}
}

- (void)_setCellRegistrationStatus:(int)arg1 {
	if ([signalManager cellularConnectionInitialized]) {
		%orig(2);
	} else {
		%orig;
	}
}

- (void)airplaneModeChanged {
	%orig;
	[signalManager airplaneModeChanged];
}

- (void)_updateState {
	%orig;
	[signalManager _updateState];
}

- (BOOL)cellularRadioCapabilityIsActive {
	return [signalManager cellularRadioCapabilityIsActive];
}

- (id)operatorName {
	if (([signalManager cellularRadioCapabilityIsActive] &&
		[signalManager cellularConnectionInitialized] &&
		[signalManager operatorName]) ||
		[signalManager forceCustomCarrier]) {
		return [signalManager operatorName];
	}
	
	return %orig;
}

- (int)signalStrengthBars {
	return [signalManager signalStrengthBars];
}

- (int)dataConnectionType {
	return [signalManager dataConnectionType:%orig];
}


%end	// %hook SBTelephonyManager

%hook SBWiFiManager

- (void)updateSignalStrengthFromRawRSSI:(int)arg1 andScaledRSSI:(float)arg2 {
	%orig;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[[%c(SBTelephonyManager) sharedTelephonyManager] _updateState];
	});
}

%end	// %hook SBWiFiManager

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[signalManager preferencesChanged];
}

%end	// %group Signal

%ctor {
	if ([SignalManager enabled]) {
		NSLog(@"[Signal] initializing");
		%init(Signal);
		
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallback, CFSTR("ml.festival.signal.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	}
}
