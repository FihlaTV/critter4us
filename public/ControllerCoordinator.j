@import "AwakeningObject.j"

@implementation ControllerCoordinator : AwakeningObject
{
  ResultController resultController;
  ReservationController reservationController;
  AnimalController animalController;
  ProcedureController procedureController;
  CourseSessionController courseSessionController;
  PersistentStore persistentStore;
}


-(void) awakeFromCib
{
  if (awakened) return;
  [super awakeFromCib];
  [courseSessionController makeViewsAcceptData];
  [animalController hideViews];
  [procedureController hideViews];
  [reservationController hideViews];
  [resultController hideViews];
}

- (void) setUpNotifications
{
  [super setUpNotifications];

  [NotificationCenter
   addObserver: self
   selector: @selector(switchToAnimalChoosing:)
   name: CourseSessionDescribedNews
   object: nil];

  [NotificationCenter
   addObserver: self
   selector: @selector(makeReservation:)
   name: ReservationRequestedNews
   object: nil];

  [NotificationCenter
   addObserver: self
   selector: @selector(chosenProceduresChanged:)
   name: ProcedureUpdateNews
   object: nil];
}

- (void) switchToAnimalChoosing: (CPNotification) ignored
{
  [courseSessionController displaySelectedSession];

  var dict = [CPMutableDictionary dictionary];
  [courseSessionController spillIt: dict];
  [animalController loadExclusionsForDate: [dict valueForKey: 'date']
                                     time: [dict valueForKey: 'time']];

  [animalController unchooseAllAnimals];
  [animalController showViews];

  [procedureController unchooseAllProcedures];
  [procedureController showViews];

  [reservationController showViews];
  [resultController hideViews];
}

- (void) chosenProceduresChanged: aNotification
{
  var procedures = [aNotification object];
  [animalController offerAnimalsForProcedures: procedures];
}

- (void) makeReservation: (CPNotification) ignored
{
  var dict = [CPMutableDictionary dictionary];
  [courseSessionController spillIt: dict];
  [procedureController spillIt: dict];
  [animalController spillIt: dict];

  var reservationID = [persistentStore makeReservation: dict];
  
  [resultController offerReservationView: reservationID];
  [resultController showViews];

  [courseSessionController makeViewsAcceptData];
  [animalController hideViews];
  [procedureController hideViews];
  [reservationController hideViews];
}



@end
