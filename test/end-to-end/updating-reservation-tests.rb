$: << '../..' unless $in_rake
require 'test/testutil/requires'

class UpdatingReservationTests < EndToEndTestCase

  def setup 
    super
    Procedure.random(:name => 'venipuncture')
    Procedure.random(:name => 'physical', :days_delay => 3)
    
    Animal.random(:name => 'veinie')
    Animal.random(:name => 'bossie')
    Animal.random(:name => 'staggers')

    @id = make_reservation('2009-08-31', %w{veinie staggers}, %w{venipuncture})

    data = {
      'firstDate' => '2000-10-10',
      'lastDate' => '2000-10-11',
      'times' => [AFTERNOON],
      'instructor' => 'not morin',
      'course' => 'not vm333',
      'groups' => [ {'procedures' => %w{physical},
                      'animals' => %w{bossie} } ]
    }.to_json
    
    @response = post('/json/modify_reservation', :reservationID => @id.to_s, :data => data)
  end

  should "not change id" do
    assert_equal(reservation_id(@response), @id)
  end

  should "update the reservation for further requests" do 
    response = get("/json/reservation/#{@id}")
    actual = JSON(response.body)

    assert_equal([ {'animals' => %w{bossie}, 'procedures' => %w{physical} } ], 
                   actual["groups"])
    assert_equal('not vm333', actual['course'])
    assert_equal(['afternoon'], actual['times'])
    assert_equal("2000-10-10", actual['firstDate'])
    assert_equal({'physical' => ['bossie'], 'venipuncture' => ['bossie']},
                 actual['timeSensitiveExclusions'])
  end


  should "update exclusions for other dates" do 
    response = get("/json/animals_and_procedures_blob",
                   :timeslice => {
                     'firstDate' => '2000-10-10',
                     'lastDate' => '2000-10-11',
                     'times' => ['morning']}.to_json)
    actual = JSON(response.body)

    # Bossie can't be used for physical because she's in the blackout period.
    # However, she can be used for venipuncture because the request is for a different
    # time of day.
    assert_equal({'physical' => ['bossie'], 'venipuncture' => []},
                 actual['timeSensitiveExclusions'])
  end

end