@import <Critter4Us/controller/ProcedureInterfaceController.j>
@import "ScenarioTestCase.j"

@implementation ProcedureInterfaceControllerTest : ScenarioTestCase
{
  CPArray procedures;
}

- (void)setUp
{
  sut = [[ProcedureInterfaceController alloc] init];
  scenario = [[Scenario alloc] initForTest: self andSut: sut];

  [scenario sutHasUpwardCollaborators: ['unchosenProcedureTable',
					'chosenProcedureTable',
					'containingView']];
}


- (void)testBeginning
{
  [scenario
   during: function() {
      [sut beginUsingProcedures: ['cc', 'B', 'aaa']];
    }
  behold: function() {
      [sut.unchosenProcedureTable shouldReceive: @selector(reloadData)];
      [sut.chosenProcedureTable shouldReceive: @selector(reloadData)];
    }
  andSo: function() {
      [self unchosenProcedureTableWillContain: ["aaa", "B", "cc"]];
      [self chosenProcedureTableWillContain: []];
    }
   ]
}


- (void)testBeginningWithSomeProceduresChosen
{
  [scenario
   during: function() {
      [sut beginUsingChosenProcedures: ['cc', 'B', 'aaa']
                   unchosenProcedures: ['z', 'f']];
    }
  behold: function() {
      [sut.unchosenProcedureTable shouldReceive: @selector(reloadData)];
      [sut.chosenProcedureTable shouldReceive: @selector(reloadData)];
    }
  andSo: function() {
      [self unchosenProcedureTableWillContain: ['f', 'z']];
      [self chosenProcedureTableWillContain: ["aaa", "B", "cc"]];
    }
   ]
}


-(void) testBeginningAgain
{
  [scenario 
    previousAction: function() {
      [sut beginUsingProcedures: ["cc", "B", "aaa"]];
      [self selectProcedure: "cc"];
      [self unchosenProcedureTableWillContain: ["aaa", "B"]];
      [self chosenProcedureTableWillContain: ["cc"]];
    }
  during: function() {
      [sut beginUsingProcedures: ["cc", "B", "aaa"]];
    }
  behold: function() {
      [sut.unchosenProcedureTable shouldReceive: @selector(reloadData)];
      [sut.chosenProcedureTable shouldReceive: @selector(reloadData)];
    }
  andSo: function() {
      [self unchosenProcedureTableWillContain: ["aaa", "B", 'cc']];
      [self chosenProcedureTableWillContain: []];
    }];
}


- (void)testChoosingAProcedure
{
  [scenario
   previousAction: function() {
      [sut beginUsingProcedures: ["artificial insemination", "floating teeth"]];
    }
  during: function() {
      [self selectProcedure: "artificial insemination"];
    }
  behold: function() {
      [self listenersWillReceiveNotification: ProcedureUpdateNews
            containingObject: [@"artificial insemination"]];
      [sut.unchosenProcedureTable shouldReceive: @selector(reloadData)];
      [sut.chosenProcedureTable shouldReceive: @selector(reloadData)];
    }
  andSo: function() {
      [self unchosenProcedureTableWillContain: ["floating teeth"]];
      [self chosenProcedureTableWillContain: ["artificial insemination"]];
    }
   ];
}


- (void)testPutBackAProcedure
{
  [scenario
   previousAction: function() {
      [sut beginUsingProcedures: ["alpha", "Betical", "order"]];
      [self selectProcedure: "Betical"];
    }
  during: function() {
      [self putBackProcedure: "Betical"];
    }
  behold: function() {
      [self listenersWillReceiveNotification: ProcedureUpdateNews
            containingObject: []];
      [sut.unchosenProcedureTable shouldReceive: @selector(reloadData)];
      [sut.chosenProcedureTable shouldReceive: @selector(reloadData)];
    }
  andSo: function() {
      [self unchosenProcedureTableWillContain: ["alpha", "Betical", "order"]];
      [self chosenProcedureTableWillContain: []];
    }
   ];
}


- (void)testSPillingProcedures
{
  var dict = [CPMutableDictionary dictionary];
  [scenario
   previousAction: function() {
      [sut beginUsingProcedures: ["alpha", "Betical", "order"]];
      [self selectProcedure: "Betical"];
    }
  testAction: function() {
      [sut spillIt: dict];
    }
  andSo: function() {
      [self assert: ['Betical'] equals: [dict valueForKey: 'procedures']]
    }
   ];
}



- (void) selectProcedure: (CPString) aName
{
  var index = [sut.unchosenProcedures indexOfObject: aName];
  [sut.unchosenProcedureTable shouldReceive: @selector(clickedRow)
                              andReturn: index];
  [sut chooseProcedure: sut.unchosenProcedureTable];
}

- (void) putBackProcedure: (CPString) aName
{
  var index = [sut.chosenProcedures indexOfObject: aName];
  [sut.chosenProcedureTable shouldReceive: @selector(clickedRow)
                            andReturn: index];
  [sut unchooseProcedure: sut.chosenProcedureTable];
}


- (void) unchosenProcedureTableWillContain: (CPArray) someProcedures
{
  [self onlyColumnInTable: sut.unchosenProcedureTable
	named: @"unchosen procedure table"
        willContain: someProcedures];
}

-(void) chosenProcedureTableWillContain: (CPArray) someProcedures
{
  [self onlyColumnInTable: sut.chosenProcedureTable
	named: @"chosen procedure table"
        willContain: someProcedures];
}

@end	