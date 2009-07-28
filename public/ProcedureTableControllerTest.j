@import "ProcedureTableController.j"
@import "Mock.j"

@implementation ProcedureTableControllerTest : OJTestCase
{
  ProcedureTableController controller;
  Mock store;
}

- (void)setUp
{
  controller = [[ProcedureTableController alloc] init];
  store = [[Mock alloc] init];
  [store shouldReceive: @selector(allProcedureNames)
         andReturn: [CPArray arrayWithArray: ['procedure1', 'procedure2']]];

  controller.persistentStore = store 
  [controller awakeFromCib];
}

- (void)testThatAwakeningFetchesNumberOfProcedures
{
  [self assertTrue: [store wereExpectationsFulfilled]];
}

- (void)testRowsOfTableEqualsNumberOfProcedures
{
  [self assert: 2
        equals: [controller numberOfRowsInTableView: 'table view ignored']];
}

- (void)testObjectValueForTableIsAnimalName
{
  [self assert: "procedure1"
        equals: [controller tableView: 'ignored'
	                    objectValueForTableColumn: 'ignored'
			    row: 0]];
}

@end	