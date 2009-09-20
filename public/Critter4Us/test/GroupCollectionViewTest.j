@import <Critter4Us/view/GroupCollectionView.j>
@import "ScenarioTestCase.j"

@implementation GroupCollectionViewTest : ScenarioTestCase
{
  GroupCollectionView sut;
  
  NamedObject someNamedObject;
  NamedObject anotherNamedObject;
  NamedObject unnamedObject;
}

- (void) setUp
{
  sut = [[GroupCollectionView alloc] initWithFrame: CGRectMakeZero()];
  scenario = [[Scenario alloc] initForTest: self andSut: sut];
  [scenario sutHasDownwardCollaborators: ['controller']];

  someNamedObject = [[NamedObject alloc] initWithName: 'some named object'];
  anotherNamedObject = [[NamedObject alloc] initWithName: 'another named object'];
  unnamedObject = [[NamedObject alloc] initWithName: ''];
}

- (void) testCollectionIsInitiallyEmpty
{
  [self assert: [] equals: [sut content]];
  [self assertTrue: -1 == [sut.currentIndex]];
}

- (void) testCollectionCanBecomeEmptyAgain
{
  [sut addNamedObjectToContent: someNamedObject];
  [sut becomeEmpty];
  [self assert: [] equals: [sut content]];
  [self assertTrue: -1 == [sut.currentIndex]];
}

- (void) testCanAddContent
{
  [sut addNamedObjectToContent: someNamedObject];
  [self assert: [someNamedObject] equals: [sut content]];
  [sut addNamedObjectToContent: anotherNamedObject];
  [self assert: [someNamedObject, anotherNamedObject] equals: [sut content]];
}

- (void) testAddingMakesANewArrayDoesNotReuseOldOne
{
  // CPCollectionViews don't consider adding an element to existing
  // content to be a change, so modifying and setting a copy is appropriate.
  var original = [sut content];
  [sut addNamedObjectToContent: someNamedObject];
  [self assertFalse: [sut content] == original];
}

- (void) testAnAddedElementBecomesTheCurrentOne
{
  [sut addNamedObjectToContent: someNamedObject];
  [self assert: someNamedObject equals: [sut currentRepresentedObject]];
  [sut addNamedObjectToContent: anotherNamedObject];
  [self assert: anotherNamedObject equals: [sut currentRepresentedObject]];
}

- (void) testAnAddedElementBecomesVisiblyCurrent
{
  [sut addNamedObjectToContent: someNamedObject];
  [self assertTrue: [self isVisiblyCurrent: 0]];
}

- (void) testAndThePreviouslyElementReverts
{
  [sut addNamedObjectToContent: someNamedObject];
  [sut addNamedObjectToContent: someNamedObject];
  [self assertFalse: [self isVisiblyCurrent: 0]];
  [self assertTrue: [self isVisiblyCurrent: 1]];
}



- (void) testButtonTitleIsObjectName
{
  [sut setContent: [someNamedObject]];
  [self assert: [someNamedObject name]
        equals: [self titleForItem: 0]];
}

- (void) test_butAnEmptyNameCanBeReplacedWithSomethingDescriptive
{
  [sut setDefaultName: 'default'];
  [sut setContent: [unnamedObject]];
  [self assert: "default"
        equals: [self titleForItem: 0]];
}

- (void) test_theItemCanBeToldToRefreshItsTitle
{
  [sut addNamedObjectToContent: unnamedObject];
  [unnamedObject setName: 'new name'];
  [sut currentNameHasChanged];
  [self assert: 'new name'
        equals: [self titleForItem: 0]];
}

- (void) testClickingAButtonActsToSelectThatCollectionViewIndex
{
  [scenario
    previousAction: function() {
      [CPApplication sharedApplication]; // Needed for performClick: to work.
      [sut setTarget: sut.controller];
      [sut setAction: @selector(newGroupChosen:)];
      [sut addNamedObjectToContent: someNamedObject];
      [sut addNamedObjectToContent: anotherNamedObject];
    }
  during: function() {
      [[self buttonAt: 1] performClick: UnusedArgument];
    }
  behold: function() {
      [sut.controller shouldReceive: @selector(newGroupChosen:)
                               with: sut];
    }];
}


// util

- (CPString) titleForItem: index
{
  return [[self buttonAt: index] title];
}


// TODO: Making the button look like the default button is a lame way to 
// make it stand out. I can't figure out how to make the theme state change, though. 
   
- (CPBoolean) isVisiblyCurrent: index
{
  // No way to ask the button if it's the default button, so we have its item
  // keep track of whether it thinks it is.
  // return [[button themeState] isEqual: CPThemeStateDefault];
  return [[self buttonAt: index] distinguished];
}

- (ConformingButton) buttonAt: index
{
  var item = [[sut items] objectAtIndex: index];
  return [item view];
}


@end
