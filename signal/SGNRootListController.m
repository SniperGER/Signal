#include "SGNRootListController.h"

@implementation SGNRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}
	
	NSLog(@"[Signal] specifiers: %@", _specifiers);
	
	return _specifiers;
}
	
- (id)readPreferenceValue:(PSSpecifier*)specifier {
	id properties = [specifier properties];
	
	NSString* path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", properties[@"defaults"]];
	NSDictionary* settings = [NSDictionary dictionaryWithContentsOfFile:path];
	
	if ([properties[@"key"] isEqualToString:@"showWiFiOnSignalBars"]) {
		[specifier setProperty:[NSNumber numberWithBool:[settings[@"fakeCellularConnection"] boolValue]] forKey:@"enabled"];
	}
	
	if ([properties[@"key"] isEqualToString:@"overrideSignalStrength"] ||
		[properties[@"key"] isEqualToString:@"signalStrengthBars"]) {
		[specifier setProperty:[NSNumber numberWithBool:![settings[@"showWiFiOnSignalBars"] boolValue]] forKey:@"enabled"];
	}
	
	return (settings[properties[@"key"]]) ?: properties[@"default"];
}
	
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	id properties = [specifier properties];
	
	NSString* path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", properties[@"defaults"]];
	NSMutableDictionary* settings = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	
	[settings setObject:value forKey:properties[@"key"]];
	[settings writeToFile:path atomically:YES];
	
	CFStringRef notificationName = (CFStringRef)properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self reload];
	});
}
	
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)killSpringBoard {
	system("killall SpringBoard");
}
#pragma GCC diagnostic pop

@end
