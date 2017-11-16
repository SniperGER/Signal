#import "SignalManager.h"
#import "SBTelephonyManager.h"
#import "SBWiFiManager.h"

@implementation SignalManager

+ (BOOL)enabled {
	NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:PREFERENCES_PATH];
	
	if ([dict objectForKey:@"enabled"]) {
		return [[dict objectForKey:@"enabled"] boolValue];
	}
	
	return YES;
}

- (id)init {
	if (self = [super init]) {
		telephonyManager = [objc_getClass("SBTelephonyManager") sharedTelephonyManager];
		wifiManager = [objc_getClass("SBWiFiManager") sharedInstance];
		[self loadPreferences];
		
		if ([[preferences objectForKey:@"fakeCellularConnection"] boolValue]) {
			[self setCellularConnectionEnabled:YES];
		}
		
	}
	
	return self;
}

- (void)loadPreferences {
	preferences = [NSMutableDictionary dictionaryWithContentsOfFile:PREFERENCES_PATH];
	
	if (!preferences) {
		preferences = [NSMutableDictionary new];
	}
	
	// Determine whether Signal is enabled or not
	if (![preferences objectForKey:@"enabled"]) {
		[preferences setValue:[NSNumber numberWithBool:YES] forKey:@"enabled"];
	}
	
	// Fake the cellular connection
	if (![preferences objectForKey:@"fakeCellularConnection"]) {
		[preferences setValue:[NSNumber numberWithBool:YES] forKey:@"fakeCellularConnection"];
	}
	
	// Show WiFi connection strength on signal dots
	if (![preferences objectForKey:@"showWiFiOnSignalBars"]) {
		[preferences setValue:[NSNumber numberWithBool:NO] forKey:@"showWiFiOnSignalBars"];
	}
	
	// Override the data connection type when actually connected to a network (WiFi or Cellular)
	if (![preferences objectForKey:@"overrideConnectionTypeWhenOnline"]) {
		[preferences setValue:[NSNumber numberWithBool:NO] forKey:@"overrideConnectionTypeWhenOnline"];
	}
	
	// Override the data connection type if the user is not connected to any network
	if (![preferences objectForKey:@"overrideConnectionTypeWhenOffline"]) {
		[preferences setValue:[NSNumber numberWithBool:YES] forKey:@"overrideConnectionTypeWhenOffline"];
	}
	
	// Set the data connection type if the user decides to override it
	if (![preferences objectForKey:@"dataConnectionType"]) {
		[preferences setValue:[NSNumber numberWithInt:7] forKey:@"dataConnectionType"];
	}
	
	// Override the Operator Name
	if (![preferences objectForKey:@"operatorName"]) {
		[preferences setValue:@"Carrier" forKey:@"operatorName"];
	}
	
	// Always show the custom operator name
	if (![preferences objectForKey:@"operatorNameShowAlways"]) {
		[preferences setValue:[NSNumber numberWithBool:NO] forKey:@"operatorNameShowAlways"];
	}
	
	// Enables signal bar/dot count override
	if (![preferences objectForKey:@"overrideSignalStrength"]) {
		[preferences setValue:[NSNumber numberWithBool:YES] forKey:@"overrideSignalStrength"];
	}
	
	// Set the amount of signal bars (or dots on pre-iOS 11) shown to the user
	if (![preferences objectForKey:@"signalStrengthBars"]) {
		[preferences setValue:[NSNumber numberWithInt:5] forKey:@"signalStrengthBars"];
	}
	
	[preferences writeToFile:PREFERENCES_PATH atomically:YES];
}

- (void)preferencesChanged {
	[self loadPreferences];
	
	[self setCellularConnectionEnabled:[[preferences objectForKey:@"fakeCellularConnection"] boolValue]];
	
	[telephonyManager airplaneModeChanged];
}

- (BOOL)cellularRadioCapabilityIsActive {
	return [[preferences objectForKey:@"fakeCellularConnection"] boolValue] && connectionEnabled;
}

- (BOOL)cellularConnectionInitialized {
	if ([[preferences objectForKey:@"showWiFiOnSignalBars"] boolValue]) {
		return [wifiManager isAssociated] && connectionInitialized;
	} else {
		return connectionInitialized;
	}
}

- (BOOL)forceCustomCarrier {
	return [[preferences objectForKey:@"operatorNameShowAlways"] boolValue];
}

- (void)airplaneModeChanged {
	if ([telephonyManager isInAirplaneMode]) {
		connectionInitialized = NO;
	} else {
		if (connectionEnabled) {
			[self setCellularConnectionEnabled:YES];
		}
	}
}

- (void)_updateState {
	if ([[preferences objectForKey:@"showWiFiOnSignalBars"] boolValue]) {
		if (![wifiManager isAssociated]) {
			connectionInitialized = NO;
			[self _disableCellularConnection];
		} else if ([wifiManager isAssociated] &&
				   connectionEnabled &&
				   !connectionInitialized &&
				   ![telephonyManager isInAirplaneMode]) {
			[self _enableCellularConnection];
		}
	}
}

- (int)signalStrengthBars {
	if ([[preferences objectForKey:@"showWiFiOnSignalBars"] boolValue]) {
		switch ([wifiManager signalStrengthBars]) {
			case 0:
				return 0;
			case 1:
				return 1;
			case 2:
				return 3;
			case 3:
				return 5;
		}
	}
	
	if ([[preferences objectForKey:@"overrideSignalStrength"] boolValue]) {
		return [[preferences objectForKey:@"signalStrengthBars"] intValue];
	}
	
	return 0;
}

- (id)operatorName {
	if ([[preferences objectForKey:@"operatorNameShowAlways"] boolValue]) {
		if ([[preferences objectForKey:@"operatorName"] length] > 0) {
			return [preferences objectForKey:@"operatorName"];
		}
	}
	
	if ([[preferences objectForKey:@"fakeCellularConnection"] boolValue]) {
		if ([[preferences objectForKey:@"showWiFiOnSignalBars"] boolValue]) {
			if ([wifiManager isAssociated]) {
				return [wifiManager currentNetworkName];
			}
		}
		
		if ([[preferences objectForKey:@"operatorName"] length] > 0) {
			return [preferences objectForKey:@"operatorName"];
		}
	}
	
	return nil;
}

- (int)dataConnectionType:(int)currentConnectionType {
	if ([telephonyManager isInAirplaneMode]) {
		return currentConnectionType;
	}
	
	if ([[preferences objectForKey:@"fakeCellularConnection"] boolValue] &&
		[[preferences objectForKey:@"showWiFiOnSignalBars"] boolValue]) {
		if (currentConnectionType != 0 &&
			[[preferences objectForKey:@"overrideConnectionTypeWhenOnline"] boolValue]) {
			if (connectionEnabled && !connectionInitialized) {
				return 0;
			}
			
			return [[preferences objectForKey:@"dataConnectionType"] intValue];
		}
	} else {
		if (currentConnectionType != 0 &&
			[[preferences objectForKey:@"overrideConnectionTypeWhenOnline"] boolValue]) {
			return [[preferences objectForKey:@"dataConnectionType"] intValue];
		}
		
		if (currentConnectionType == 0 &&
			[[preferences objectForKey:@"overrideConnectionTypeWhenOffline"] boolValue]) {
			return [[preferences objectForKey:@"dataConnectionType"] intValue];
		}
	}
	
	return currentConnectionType;
}

- (void)setCellularConnectionEnabled:(BOOL)enabled {
	if (connectionEnabled == enabled) {
		return;
	}
	connectionEnabled = enabled;
	connectionInitialized = NO;
	
	[self _disableCellularConnection];
	[telephonyManager _updateState];
	
	if (enabled && ![telephonyManager isInAirplaneMode]) {
		[self _enableCellularConnection];
	}
}

- (void)_enableCellularConnection {
	if (connectionInitTimer) {
		[connectionInitTimer invalidate];
		connectionInitTimer = nil;
	}
	
	connectionInitTimer = [NSTimer scheduledTimerWithTimeInterval:3 repeats:NO block:^(NSTimer* timer) {
		if (([[preferences objectForKey:@"showWiFiOnSignalBars"] boolValue] && [wifiManager isAssociated]) ||
			![[preferences objectForKey:@"showWiFiOnSignalBars"] boolValue]) {
			connectionInitialized = YES;
			[telephonyManager _setRegistrationStatus:2];
			[telephonyManager _setCellRegistrationStatus:2];
		}
	}];
}

- (void)_disableCellularConnection {
	connectionInitialized = NO;
	[telephonyManager _setRegistrationStatus:3];
	[telephonyManager _setCellRegistrationStatus:3];
}

@end
