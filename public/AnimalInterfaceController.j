@import <Foundation/CPObject.j>

@implementation AnimalInterfaceController : CPObject
{
  // outlets
  CPTableView table;
  CPTableColumn nameColumn;
  CPTableColumn checkColumn;
  CPView containingView;
  id persistentStore;

  CPArray allAnimals;
  CPArray availableAnimals;
  CPMutableDictionary isChosen;
  CPDictionary exclusions;

  // For testing
  BOOL awakened;
}

- (void)awakeFromCib
{
  if (awakened) return;
  awakened = YES;
  allAnimals = [persistentStore allAnimalNames];

  [self allAnimalsAreAvailable];
  [self noAnimalsAreChosen]

  [self setUpNotifications];
  [containingView setHidden:YES]; 
  [table reloadData];
}

- (void)allAnimalsAreAvailable
{
  availableAnimals = [CPArray arrayWithArray: allAnimals];
  [availableAnimals sortUsingSelector: @selector(caseInsensitiveCompare:)];
}

- (void)noAnimalsAreChosen
{
  isChosen = [CPMutableDictionary dictionary];
  for(var i=0; i < [availableAnimals count]; i++)
    {
      [isChosen setValue: NO forKey: availableAnimals[i]];
    }
}


- (void) setUpNotifications
{
  [[CPNotificationCenter defaultCenter]
   addObserver: self
   selector: @selector(newExclusions:)
   name: @"exclusions"
   object: nil];

  [[CPNotificationCenter defaultCenter]
   addObserver: self
   selector: @selector(proceduresChosen:)
   name: @"procedures chosen"
   object: nil];

  [[CPNotificationCenter defaultCenter]
   addObserver: self
   selector: @selector(dateChosen:)
   name: @"date chosen"
   object: nil];

}


- (void)stopObserving
{
  [[CPNotificationCenter defaultCenter] removeObserver: self];
}

- (void) dateChosen: aNotification
{
  [containingView setHidden:NO];
}

- (void) newExclusions: aNotification
{
  exclusions = [aNotification object];
}

- (void) proceduresChosen: aNotification
{
  var procedures = [aNotification object];
  [self allAnimalsAreAvailable];
  [self removeAnimalsExcludedByProcedures: procedures];


  oldIsChosen = [CPMutableDictionary dictionaryWithDictionary: isChosen];
  [self noAnimalsAreChosen];
  [self chooseAnimalsAlreadyChosenIn: oldIsChosen];

  [table reloadData];
}

- (void) removeAnimalsExcludedByProcedures: procedures
{
  for (var i=0; i<[procedures count]; i++)
    {
      [self removeAnimalsExcludedByProcedure: [procedures objectAtIndex: i]];
    }
}
  
- (void) removeAnimalsExcludedByProcedure: (CPString) procedure
{
  var animalsToRemove = [exclusions objectForKey: procedure];
  
  for(var i=0; i < [animalsToRemove count]; i++) 
    {
      var goner = [animalsToRemove objectAtIndex: i];
      [availableAnimals removeObject: goner];
    }
}

- (void) chooseAnimalsAlreadyChosenIn: oldIsChosen
{
  for (var i=0; i<[availableAnimals count]; i++)
    {
      var name = availableAnimals[i];
      [isChosen setValue: [oldIsChosen valueForKey: name]
                forKey: name]
    }
}

- (void) toggleAnimal: (CPTable) sender
{
  [self toggleAnimalAtIndex: [sender clickedRow]];
}

- (void) toggleAnimalAtIndex: index
{
  var name = availableAnimals[index];
  [isChosen setValue: (![isChosen valueForKey: name]) forKey: name];
  [table reloadData];
}

- (CPInteger) numberOfRowsInTableView:(CPTableView)aTableView
{
  return [availableAnimals count];
}

- (void)tableView:(CPTableView)aTableView willDisplayCell:(id)aCell forTableColumn:(CPTableColumn)aTableColumn row:(id)rowIndex
{
  // TODO: Not implemented in cappuccino yet.
}

- (id)tableView:(CPTableView)aTableView objectValueForTableColumn: (CPTableColumn)column row:(CPInteger)rowIndex
{
  name = availableAnimals[rowIndex];
  if (column == nameColumn)
    {
      return name;
    }
  else
    {
      return [isChosen valueForKey: name];
    }
}

- (void) tableView: table setObjectValue: value forTableColumn: aColumn row: rowIndex
{
  alert("Will do nothing");
}


@end