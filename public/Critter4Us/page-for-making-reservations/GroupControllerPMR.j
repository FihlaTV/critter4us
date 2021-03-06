@import "../view/UnconditionalPopup.j"
@import "../util/AwakeningObject.j"
@import "../model/Group.j"
@import "ConstantsPMR.j"

/* This controller knows that the view is some kind of
   CPCollectionView for groups, but it should be insulated from any
   knowledge of how that view represents them on the screen.
*/

@implementation GroupControllerPMR : AwakeningObject
{
  CPButton newGroupButton;
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
  [newGroupButton setHidden: YES];
  [groupCollectionView setHidden: YES];
}

- (void) prepareToEditGroups
{
  [newGroupButton setHidden: NO];
  [groupCollectionView setHidden: NO];
  [groupCollectionView addNamedObjectToContent: [self emptyGroup]];
}

- (void) showGroupButtons
{
  [newGroupButton setHidden: NO];
  [groupCollectionView setHidden: NO];
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



- (CPArray) groups
{
  return [[groupCollectionView content] copy];
}

- (void) setCurrentGroupProcedures: procedures animals: animals
{
  var group = [groupCollectionView currentRepresentedObject];
  [group setProcedures: procedures animals: animals];
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

- (void) redisplayInLightOf: procedures
{
  var enumerator = [[groupCollectionView content] objectEnumerator];
  var group;
  while(group = [enumerator nextObject])
  {
    // TODO: Suppose there are no procedures in a particular group.
    // Since exclusions are controlled by procedures, no already-chosen
    // animals will be excluded from the display. They will, however, be
    // removed when the first procedure is chosen, so is this worth fixing?
    [group exclusionsHaveChangedForThese: procedures];
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
    if ([fresh count] > 0) 
    {
      [groupMessages addObject: [self composeOneGroupMessage: fresh
                                                  taggedWith: [item invariantId]]];
    }
  }

  if ([groupMessages count] > 0) 
  {
    [NotificationCenter postNotificationName: AdviceAboutAnimalsDroppedNews
                                      object: [self composeWholeMessage: groupMessages]];
  }
}

// TODO: Put composition in own class?
- (CPString) composeOneGroupMessage: animalNames taggedWith: groupId
{
  [animalNames sortUsingSelector: @selector(caseInsensitiveCompare:)];
  return "Group " + groupId + " is missing " + animalNames.join(", ") + ".";
}

- (CPString) composeWholeMessage: groupMessages
{

  var prelude = "Some animals you had already chosen are unavailable on this new date or time. They have been removed as described below. You'll have to add animals to replace them. (Changing the date back won't add them back - sorry!)";

  return (prelude + "\n\n" + groupMessages.join("\n"));
}

@end

