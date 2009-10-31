@import <Critter4Us/page-for-making-reservations/state-machine/GatheringReservationDataStepPMR.j>
@import <Critter4Us/page-for-making-reservations/state-machine/GatheringGroupDataStepPMR.j>
@import "StateMachineTestCase.j"
@import <Critter4Us/util/Time.j>


@implementation GatheringReservationDataStepPMRTest : StateMachineTestCase
{
}

- (void) setUp
{
  sut = [GatheringReservationDataStepPMR alloc];
  [super setUp];
}

// At the beginning: Ready to gather data for a new reservation. 


- (void) test_start_by_initializing_collaborators
{
  [scenario
    during: function() {
      [sut start];
    }
  behold: function() {
      [sut.reservationDataController shouldReceive: @selector(beginningOfReservationWorkflow)];
      [sut.animalController shouldReceive: @selector(beginningOfReservationWorkflow)];
      [sut.procedureController shouldReceive: @selector(beginningOfReservationWorkflow)];
      [sut.groupController shouldReceive: @selector(beginningOfReservationWorkflow)];
      [self listenersShouldReceiveNotification: AdvisoriesAreIrrelevantNews];
    }];
}

// EVENT: The user has selected date, time, ... all but animals and procedures

- (void) test_when_data_is_available_pass_it_to_persistent_store_and_resign
{
  [scenario
    during: function() {
      var dict = [CPDictionary dictionary];
      [dict setValue: '2009-02-02' forKey: 'date'];
      [dict setValue: [Time morning] forKey: 'time'];
          
      [self sendNotification: ReservationDataAvailable withObject: dict];
    }
  behold: function() {
      [sut.persistentStore shouldReceive: @selector(makeURIsWith:)
                                    with: function(arg) {
          [self assert: "URIMaker" equals: [arg className]];
          return YES;
        }];
      [sut.persistentStore shouldReceive: @selector(loadInfoRelevantToDate:time:)
                                    with: ['2009-02-02', [Time morning]]];
      [sut.master shouldReceive: @selector(nextStep:)
                           with: GatheringGroupDataStepPMR];
    }];
}

// EVENT: User has chosen to work with an existing reservation.

- (void) test_when_user_wishes_to_edit_pass_to_persistent_store_and_resign
{
  [scenario
   during: function() {
      [self sendNotification: ModifyReservationNews
                  withObject: 33];
    }
   behold: function() {
      [sut.persistentStore shouldReceive: @selector(makeURIsWith:)
                                    with: function(arg) {
          [self assert: "EditingURIMaker" equals: [arg className]];
          [self assert: 33 equals: [arg reservationBeingEdited]];
          return YES;
        }];
      [sut.persistentStore shouldReceive: @selector(fetchReservation:)
                                    with: 33];
      [sut.master shouldReceive: @selector(nextStep:)
                           with: GatheringGroupDataStepPMR];
    }];
}

@end