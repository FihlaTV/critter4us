@import "../view/UnconditionalPopup.j"
@import "../controller/PanelController.j"
@import "../model/Group.j"
@import "ConstantsPMR.j"

/* This controller knows that the view is some kind of
   CPCollectionView for groups, but it should be insulated from any
   knowledge of how that view represents them on the screen.
*/

@implementation GroupControllerPMR : PanelController
{
  CPButton newGroupButton;
  CPCollectionView readOnlyProcedureCollectionView;
  CPCollectionView readOnlyAnimalCollectionView;
  CPCollectionView groupCollectionView;

  UnconditionalPopup unconditionalPopup;
}


- (void) awakeFromCib
{
  unconditionalPopup = [[UnconditionalPopup alloc] init];
}

- (void) beginningOfReservationWorkflow
{
  [groupCollectionView becomeEmpty];
  [self disappear];
  [newGroupButton setHidden: YES];
  [groupCollectionView setHidden: YES];
}

- (void) prepareToEditGroups
{
  [newGroupButton setHidden: NO];
  [groupCollectionView setHidden: NO];
  [groupCollectionView addNamedObjectToContent: [self emptyGroup]];
}

- (void) newGroup: sender
{
  [self addEmptyGroupToCollection];
  [groupCollectionView setNeedsDisplay: YES];
  [self differentGroupChosen: UnusedArgument];
}

- (void) differentGroupChosen: sender
{
  [NotificationCenter postNotificationName: SwitchToGroupNews
                                    object: [groupCollectionView currentRepresentedObject]];
}

-(void) pretendCurrentGroupWasFreshlyChosen // alias for above message
{
  [self differentGroupChosen: UnusedArgument];
}



- (void) spillIt: (CPMutableDictionary) dict
{
  var allGroups = [[groupCollectionView content] copy];
  [dict setValue: allGroups forKey: 'groups'];
}

- (void) updateCurrentGroup
{
  var group = [groupCollectionView currentRepresentedObject];
  [group setProcedures: [readOnlyProcedureCollectionView content]
               animals: [readOnlyAnimalCollectionView content]];
  if ([group containsExcludedAnimals])
  {
    [unconditionalPopup setMessage: [self extraAnimalsMessage: [group animalsIncorrectlyPresent]]];
    [unconditionalPopup run];
  }
  [groupCollectionView currentNameHasChanged];
}

- (void) allPossibleObjects: groups
{
  [groupCollectionView becomeEmpty];
  var enumerator = [groups objectEnumerator];
  var item;
  while(one = [enumerator nextObject])
  {
    [groupCollectionView addNamedObjectToContent: one]
  }
  [self differentGroupChosen: UnusedArgument];
}

- (void) updateProcedures: procedures
{
  var enumerator = [[groupCollectionView content] objectEnumerator];
  var group;
  while(group = [enumerator nextObject])
  {
    [group updateProcedures: procedures];
  }
  [self pretendCurrentGroupWasFreshlyChosen];
  [self offerAdviceIfAnimalsWereDropped]
}

// util

-(Group) emptyGroup
{
  return [[Group alloc] initWithProcedures: [] animals: []];
}

- (void) addEmptyGroupToCollection
{
  [groupCollectionView addNamedObjectToContent: [self emptyGroup]];
}

- (void) extraAnimalsMessage: extras
{
  return "You have found a bug. Please report it. These animals should not have been allowed in the group: " + 
    [extras description]
}

-(void) offerAdviceIfAnimalsWereDropped
{
  var groupMessages = [];
  var enumerator = [[groupCollectionView items] objectEnumerator];
  var item;
  while(item = [enumerator nextObject])
  {
    var fresh = [[item representedObject] freshlyExcludedAnimalNames];
    [fresh sortUsingSelector: @selector(caseInsensitiveCompare:)];
    var msg = "Group " + [item invariantId] + " is missing " + fresh.join(", ") + ".";
  }

  var prelude = "Some animals you had already chosen are unavailable on this new date or time. They have been removed as described below. You'll have to add animals to replace them. (Changing the date back won't add them back - sorry!)";

  var whole = (prelude + "\n\n" + msg)
  [NotificationCenter postNotificationName: AdviceAboutAnimalsDroppedNews
                                    object: whole];
}

@end

