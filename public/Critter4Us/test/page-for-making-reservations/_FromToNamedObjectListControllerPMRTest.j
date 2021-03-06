@import <Critter4Us/page-for-making-reservations/FromToNamedObjectListControllerPMR.j>
@import <Critter4Us/view/NamedObjectCollectionView.j>
@import <Critter4Us/model/NamedObject.j>
@import <Critter4Us/model/Group.j>
@import <Critter4Us/test/testutil/ScenarioTestCase.j>

@implementation _FromToNamedObjectListControllerPMRTest : ScenarioTestCase
{
  NamedObject betsy;
  NamedObject spike;
  NamedObject fang;
}

- (void)setUp
{
  sut = [[FromToNamedObjectListControllerPMR alloc] init];
  scenario = [[Scenario alloc] initForTest: self andSut: sut];
  [scenario sutHasUpwardCollaborators: ['available', 'used']];

  betsy = [[NamedObject alloc] initWithName: 'betsy'];
  spike = [[NamedObject alloc] initWithName: 'spike'];
  fang = [[NamedObject alloc] initWithName: 'fang'];
}


- (void) testSelectionMovesObjectFromAvailableToUsed
{
  [scenario 
    during: function() { 
      [sut objectsRemoved: [betsy, spike] fromList: sut.available];
    }
  behold: function() { 
      [sut.used shouldReceive: @selector(addContent:)
                         with: [[betsy, spike]]];
      [sut.used shouldReceive: @selector(setNeedsDisplay:)
                         with: YES];
    }];
}

- (void) testSelectionMovesObjectFromUsedToAvailable
{
  [scenario 
    during: function() { 
      [sut objectsRemoved: [betsy, spike] fromList: sut.used];
    }
  behold: function() { 
      [sut.available shouldReceive: @selector(addContent:)
                         with: [[betsy, spike]]];
      [sut.available shouldReceive: @selector(setNeedsDisplay:)
                         with: YES];
    }];
}

- (void)testMovingAnObjectAnnouncesUsedListIsUpdated
{
  [scenario
   previously: function() {
      [sut allPossibleObjects: [betsy, spike]];
    }
  during: function() {
      [sut objectsRemoved: [betsy] fromList: sut.available];
    }
  behold: function() {
      [sut.used shouldReceive: @selector(content)
                    andReturn: [betsy]];
            [self listenersWillReceiveNotification: DifferentObjectsUsedNews
                                  containingObject: sut
                                            andKey: 'used'
                                              with: [betsy]];
    }];
}



- (void) testPresetsDoNotCountAsNotifiableMovement
{
  [scenario 
    previously: function() { 
      [sut allPossibleObjects: [betsy, spike, fang]];
    }
    during: function() { 
      [sut presetUsed: [betsy, fang] ];
    }
  behold: function() {
      [self listenersShouldHearNo: DifferentObjectsUsedNews];
    }];
}



- (void) testCanBackUpToBeginningOfReservationWorkflow
{
  [scenario
    previously: function() {
      [sut appear];
      [self assertTrue: [sut wouldShowPanel]];
      [sut.available setContent: [[NamedObject alloc] initWithName: 'a']];
      [sut.used setContent: [[NamedObject alloc] initWithName: 'u']];
    }
    during: function() {
      [sut beginningOfReservationWorkflow];
    }
  behold: function() {
      [sut.panel shouldReceive: @selector(orderOut:)];
    }
  andSo: function() {
      [self assertFalse: [sut wouldShowPanel]];
      [self assert: [] equals: [sut.used content]];
      [self assert: [] equals: [sut.available content]];
    }];
}

- (void)testWithholdingNamedObjectsLeavesThemOutOfAvailableList
{
  [scenario
   previously: function() {
      [sut allPossibleObjects: [betsy, spike, fang]];
    }
  during: function() { 
      [sut withholdNamedObjects: [fang, betsy]];
    }
  behold: function() {
      [sut.available shouldReceive: @selector(setNeedsDisplay:) with: YES];
    }
  andSo: function() {
      [self assert: [spike]
            equals: [sut.available content]];
    }];
}

- (void)testWithholdingDoes_NOT_Accumulate
{
  [scenario
   previously: function() {
      [sut allPossibleObjects: [betsy, spike, fang]];
      [sut withholdNamedObjects: [betsy]];
    }
  testAction: function() {
      [sut withholdNamedObjects: [spike]];
    }
  andSo: function() {
      [self assert: [betsy, fang]
            equals: [sut.available content]];
    }];
}

- (void)testWithholdingNamedObjectsNeedNotBePermanent
{
  [scenario
   previously: function() { 
      [sut allPossibleObjects: [betsy, spike, fang]];
      [sut withholdNamedObjects: [fang, betsy]];
    }
  testAction: function() { 
      [sut withholdNamedObjects: []];
    }
  andSo: function() { 
      [self assert: [betsy, spike, fang]
            equals: [sut.available content]];
    }];
}

- (void) testWithholdingAppliesToChosenNamedObjectsAsWell
{
  [scenario
  previously: function() {
      [sut allPossibleObjects: [betsy, spike, fang]];
      [self simulateChoiceOf: [spike,fang]];
      [self assert: [betsy] equals: [sut.available content]];
      [self assert: [spike, fang] equals: [sut.used content]];
    }
  testAction: function() { 
      [sut withholdNamedObjects: [betsy, fang]];
    }
  andSo: function() {
      [self assert: [] equals: [sut.available content]];
      [self assert: [spike] equals: [sut.used content]];
    }];
}

- (void) testWithholdingAnNamedObjectDoes_Not_RechooseItIfItReappears
{
  [scenario
  previously: function() {
      [sut allPossibleObjects: [betsy, spike, fang]];
      [self simulateChoiceOf: [spike, fang]];
      [sut withholdNamedObjects: [betsy, fang]];
      [self assert: [] equals: [sut.available content]];
      [self assert: [spike] equals: [sut.used content]];
    }
  testAction: function() { 
      [sut withholdNamedObjects: []];
    }
  andSo: function() {
      [self assert: [betsy, fang] equals: [sut.available content]];
      [self assert: [spike] equals: [sut.used content]];
    }];
}

-(void) simulateChoiceOf: animals
{
  var copy = [[sut.available content] copy];
  [copy removeObjectsInArray: animals];
  [sut.available setContent: copy];
  [sut.used setContent: animals];
}



@end	
