@import "../../util/Step.j"
@import "GatheringReservationDataStepPMR.j"

@implementation StoringReservationStepPMR : Step
{
}

- (void) setUpNotifications
{
  [self notificationNamed: ReservationStoredNews
                    calls: @selector(finishReservation:)];
}

-(void) finishReservation: aNotification
{
  var reservationID = [[aNotification object] valueForKey: 'reservation'];
  [reservationDataController offerOperationsOnJustFinishedReservation: reservationID];
  // No need for afterResigningInFavorOf because next event comes from user.
  [self resignInFavorOf: GatheringReservationDataStepPMR];
}

@end
