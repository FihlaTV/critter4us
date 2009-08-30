@import <AppKit/AppKit.j>

@implementation MainMenuCib : CPObject
{
  CPObject owner;
  CPMenu mainMenu;
  CPMenu windowMenu;
  CPMenuItem reservationMakerMenuItem;
  CPMenuItem reservationViewerMenuItem;
}

-(void) initializeWithOwner: anOwner
{
  owner = anOwner;
  
  [self addMainMenu];
  [self addWindowMenuToMainMenu];
  [self addWindowMenuItemThatMakesReservation];
  [self addWindowMenuItemThatViewsAllReservations];
}

-(void)addMainMenu
{
  mainMenu = [[CPMenu alloc] initWithTitle:@"MainMenu"];
  //  [mainMenu setAutoEnablesItems:NO];
  [CPApp setMainMenu: mainMenu];
  [CPMenu setMenuBarVisible:YES];  
}

-(void)addWindowMenuToMainMenu
{
  var windowMenuItem = [[CPMenuItem alloc] initWithTitle:@"Window" 
                                                  action:nil 
                                           keyEquivalent:nil];
  windowMenu = [[CPMenu alloc] initWithTitle:@"Window"];
  [windowMenuItem setSubmenu:windowMenu];
  [mainMenu addItem:windowMenuItem];
}



-(void)addWindowMenuItemThatMakesReservation
{
  reservationMakerMenuItem = 
       [self aWindowMenuItemwithTitle:@"Make a Reservation"
                               action:@selector(activateReservationMaker:)
                        keyEquivalent:'M'];
}

-(void)addWindowMenuItemThatViewsAllReservations
{
  reservationViewerMenuItem = 
      [self aWindowMenuItemwithTitle:@"View All Reservations" 
                              action:@selector(activateReservationViewer:) 
                       keyEquivalent:'V'];
}

// Util

-(CPMenuItem)aWindowMenuItemwithTitle: aTitle action: anAction keyEquivalent: aKeyEquivalent
{
  var item = [[CPMenuItem alloc] initWithTitle:aTitle
                                        action:anAction
                                 keyEquivalent:aKeyEquivalent];
  [item setTarget: owner];
  [item setKeyEquivalentModifierMask:CPControlKeyMask];  
  [windowMenu addItem:item];
  return item;
}


@end