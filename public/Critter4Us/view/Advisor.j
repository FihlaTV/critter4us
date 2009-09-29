@import "../util/AwakeningObject.j"


@implementation Advisor : CritterObject
{
  id textFieldMaker;
  id panelMaker;
  id controllerMaker;
}

- (id) init
{
  self = [super init];
  textFieldMaker = function() { return [CPTextField alloc] };
  panelMaker = function() { return [CPPanel alloc] };
  controllerMaker = function() { return [PanelController alloc]; };
  [self setUpNotifications];
  return self;
}

- (void) setUpNotifications
{
  [self notificationNamed: AdviceAboutAnimalsDroppedNews
                    calls: @selector(spawnAdvice:)];
}




- (void) spawnAdvice: aNotification
{
  var horizontalSpaceForText = 400;
  var verticalSpaceForText = 120;
  var advisoryColor = [CPColor colorWithRed: 0.99 green: 0.98 blue: 0.70 alpha: 1.0];

  var textField = [textFieldMaker() initWithFrame:
                                   CGRectMake(0, 0, horizontalSpaceForText, 1200)];
  [textField setBackgroundColor: advisoryColor];
  [textField setStringValue: [aNotification object]];
  [textField setLineBreakMode: CPLineBreakByWordWrapping];

  var scroller = [[CPScrollView alloc] initWithFrame:
                          CGRectMake(0, 0, horizontalSpaceForText + [CPScroller scrollerWidth], verticalSpaceForText)];
  [scroller setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [scroller setAutohidesScrollers:NO];
  [scroller setDocumentView:textField];

  var rect = CGRectMake(600, 60, [scroller bounds].size.width, [scroller bounds].size.height);
  var panel = [[panelMaker() alloc] initWithContentRect: rect
                                          styleMask: CPTitledWindowMask |
                                                     CPClosableWindowMask |
                                                     CPMiniaturizableWindowMask |
                                                     CPResizableWindowMask];

  [panel setFloatingPanel:YES];
  [panel setTitle:@"Advisory"];
  [panel setContentView: scroller];
  [panel setDelegate: controller];
}

@end
