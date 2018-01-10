#import <IOKit/pwr_mgt/IOPMLib.h>
#import "AppDelegate.h"
#import "gamepad.h"

//extern void *_gamepad;
static IOPMAssertionID assertionID;

@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // TODO: call terminate procedure of VGS
    // TODO: destroy game pad
    /*
    if (_gamepad) {
        gamepad_term(_gamepad);
        _gamepad = NULL;
    }
     */
}

// exit app when closed
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep, kIOPMAssertionLevelOn, CFSTR("playing game"), &assertionID);
    // TODO: set enable input
}

- (void)applicationDidResignActive:(NSNotification *)notification
{
    // TODO: set disable input
    IOPMAssertionRelease(assertionID);
}

@end

