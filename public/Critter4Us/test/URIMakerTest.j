@import <Critter4Us/persistence/URIMaker.j>
@import "TestUtil.j"


@implementation URIMakerTest : OJTestCase
{
  URImaker maker;
}

-(void) setUp
{
  maker = [[URIMaker alloc] init];
}

-(void) test_can_make_uri_to_fetch_animal_and_procedure_info_by_date
{
  [self assert: '/json/course_session_data_blob?date=2009-12-30&time=morning'
        equals: [maker reservationURIWithDate: '2009-12-30' time: 'morning']];
}

-(void) test_chooses_to_create_a_new_reservation_when_storing
{
  [self assert: '/json/store_reservation'
        equals: [maker POSTReservationURI]];
}

-(void) test_can_create_content_for_posting_a_reservation
{
  var data = {'aaa':'bbb'};
  [self assert: "data=%7B%22aaa%22%3A%22bbb%22%7D"
        equals: [maker POSTReservationContentFrom: data]];
}

-(void) test_can_make_uri_to_fetch_reservation_by_id
{
  [self assert: '/json/reservation/333'
        equals: [maker fetchReservationURI: 333]];
}


@end