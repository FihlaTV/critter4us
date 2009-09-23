@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Constants.j"

@implementation AwakeningObject : CPObject
{

  // For testing
  BOOL awakened;
}

- (void)awakeFromCib
{
  if (awakened) {
    alert([self description] + " has awoken twice. This may not be a problem, but should be reported.");
  }
  awakened = YES;
  [self setUpNotifications];
}

- (void) setUpNotifications
{
}

- (void) notificationNamed: name calls: (SEL) selector
{
  [NotificationCenter addObserver: self selector: selector name: name object: nil];
}


- (void) stopObserving
{
  [[CPNotificationCenter defaultCenter] removeObserver: self];
}


@end
