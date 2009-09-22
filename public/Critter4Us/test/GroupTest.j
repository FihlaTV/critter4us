@import <Critter4Us/model/Animal.j>
@import <Critter4Us/model/Procedure.j>
@import <Critter4Us/model/Group.j>

@implementation GroupTest : OJTestCase
{
  Procedure floating;
  Procedure accupuncture;
  Procedure venipuncture;
  Animal betsy;
  Animal jake;
  Animal hoss;
}

- (void) setUp
{
  floating = [[Procedure alloc] initWithName: 'floating'];
  accupuncture = [[Procedure alloc] initWithName: 'accupuncture'];
  venipuncture = [[Procedure alloc] initWithName: 'venipuncture'];
  betsy = [[Animal alloc] initWithName: 'betsy' kind: 'cow'];
  jake = [[Animal alloc] initWithName: 'jake' kind: 'horse'];
  hoss = [[Animal alloc] initWithName: 'hoss' kind: 'horse'];
}

- (void) testGroupsCanBeEmpty
{
  var group = [[Group alloc] initWithProcedures: [] animals: []];
  [self assertTrue: [group isEmpty]];
}

- (void) testAGroupIsEmptyIfEitherProcedureOrAnimalListsAreEmpty
{
  [self assertTrue: [[[Group alloc] initWithProcedures: [floating] animals: []] isEmpty]];
  [self assertTrue: [[[Group alloc] initWithProcedures: [] animals: [betsy]] isEmpty]];

  [self assertFalse: [[[Group alloc] initWithProcedures: [floating] animals: [betsy]] isEmpty]];
}

- (void) testGroupsCanReturnListofProcedureNames
{
  var group = [[Group alloc] initWithProcedures: [floating, accupuncture, venipuncture]
                                        animals: [betsy]];

  [self assert: ["floating", "accupuncture", "venipuncture"]
        equals: [group procedureNames]];
}


- (void) testGroupsCanReturnListofAnimalNames
{
  var group = [[Group alloc] initWithProcedures: [floating, accupuncture, venipuncture]
                                        animals: [betsy]];

  [self assert: ["betsy"]
        equals: [group animalNames]];
}


- (void) testNamesAreFormedFromProcedures
{
  var group = [[Group alloc] initWithProcedures: [floating, accupuncture, venipuncture]
                                        animals: [betsy]];

  [self assert: "floating, accupuncture, venipuncture"
        equals: [group name]];
}

- (void) testNoProceduresMeansEmptyName
{
  var group = [[Group alloc] initWithProcedures: []
                                        animals: [betsy]];

  [self assert: ""
        equals: [group name]];
}

- (void) testEquality
{
  var original = [[Group alloc] initWithProcedures: [floating] animals: [betsy]];
  var same = [[Group alloc] initWithProcedures: [floating] animals: [betsy]];
  var animals = [[Group alloc] initWithProcedures: [floating] animals: []];
  var procedures = [[Group alloc] initWithProcedures: [] animals: [betsy]];

  [self assertTrue: [original isEqual: same]];
  [self assertFalse: [original isEqual: procedures]];
  [self assertFalse: [original isEqual: animals]];
}
    

- (void) testHash
{
  var original = [[Group alloc] initWithProcedures: [floating] animals: [betsy]];
  var same = [[Group alloc] initWithProcedures: [floating] animals: [betsy]];

  [self assert: [original hash] equals: [same hash]];
}
    

- (void) testHashForEmpties // because of peculiar hash implementation.
{
  var original = [[Group alloc] initWithProcedures: [CPArray array] animals: [CPArray array]];
  var same = [[Group alloc] initWithProcedures: [CPArray array] animals: [CPArray array]];

  [self assert: [original hash] equals: [same hash]];
}
    

- (void) testGroupsAreIndependent // old bug in Capp 0.7.1
{
  var group1 = [[Group alloc] initWithProcedures: [floating]
                                         animals: [betsy]];

  [self assert: "floating" equals: [[[group1 procedures] objectAtIndex: 0] name]];
  var group2 = [[Group alloc] initWithProcedures: [accupuncture]
                                         animals: [betsy]];
  [self assert: "floating" equals: [[[group1 procedures] objectAtIndex: 0] name]];
}

- (void) testGroupsCanCheckWhetherExcludedAnimalsHaveBeenPutInsideThem
{
  var procedureExcludingAnimal = [[Procedure alloc] initWithName: 'excluder' excluding: [betsy, jake]];
  var brokenGroup = [[Group alloc] initWithProcedures: [procedureExcludingAnimal]
                                              animals: [betsy, hoss]];
  var okGroup = [[Group alloc] initWithProcedures: [procedureExcludingAnimal]
                                          animals: [hoss]];

  [self assertFalse: [okGroup containsExcludedAnimals]];
  [self assertTrue: [brokenGroup containsExcludedAnimals]];
  [self assert: [betsy] equals: [brokenGroup animalsIncorrectlyPresent]];
}


@end