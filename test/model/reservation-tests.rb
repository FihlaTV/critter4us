$: << '../..' unless $in_rake
require 'test/testutil/requires'
require 'model/requires'

class ReservationModelTests < Test::Unit::TestCase
  def setup
    empty_tables
  end

  should "create a single use of an animal and procedure" do
    Procedure.random(:name => 'procedure')
    Animal.random(:name => 'animal')
    
    test_data = {
      :instructor => 'marge',
      :course => 'vm333',
      :date => Date.new(2001, 2, 4),
      :morning => true,
      :groups => [
                  {:procedures => ['procedure'],
                    :animals => ['animal']}
                ]
    }
    actual_reservation = Reservation.create_with_groups(test_data)
    assert { actual_reservation.groupings.size == 1 }

    actual_grouping = actual_reservation.groupings[0]
    assert { actual_grouping.reservation == actual_reservation } 
    assert { actual_grouping.uses.size == 1 }

    actual_use = actual_grouping.uses[0]
    assert { actual_use.grouping == actual_grouping }

    assert { actual_use.animal.name == 'animal' }
    assert { actual_use.procedure.name == 'procedure' }

    # TODO: these group-erasing methods should be put in own test.

    assert { actual_reservation.uses.size == 1 }
    assert { actual_reservation.uses[0].id == actual_grouping.uses[0].id } 
    assert { actual_use.reservation == actual_reservation }

    assert { actual_reservation.animal_names == ['animal'] }
    assert { actual_reservation.procedure_names == ['procedure'] }
  end

  context "multiple animals and procedures in one group" do 

    setup do
      @p1 = Procedure.random(:name => 'p1')
      @p2 = Procedure.random(:name => 'p2')
      @a1 = Animal.random(:name => 'a1')
      @a2 = Animal.random(:name => 'a2')
      test_data = {
        :instructor => 'marge',
        :course => 'vm333',
        :date => Date.new(2001, 2, 4),
        :morning => false,
        :groups => [ {:procedures => ['p1', 'p2'],
                       :animals => ['a1', 'a2']} ]
      }
      @reservation = Reservation.create_with_groups(test_data)
    end

    should "create the cross-product of procedures and animals" do
      deny { @reservation.morning}
      assert { Use.all.size == 4 }
      assert { Use[:procedure_id => @p1.id, :animal_id => @a1.id] } 
      assert { Use[:procedure_id => @p1.id, :animal_id => @a2.id] } 
      assert { Use[:procedure_id => @p2.id, :animal_id => @a1.id] } 
      assert { Use[:procedure_id => @p2.id, :animal_id => @a2.id] } 
    end

    should "include the cross-product in a single grouping" do
      assert { @reservation.groupings.size == 1 } 
      Use.all.each do | use |
        assert { use.grouping.id == Grouping.first.id }
      end
    end

    should "be able to list all the animals involved" do
      assert { @reservation.animal_names == [ @a1.name, @a2.name] }
    end


    should "be able to list all the procedures involved" do
      assert { @reservation.procedure_names == [ @p1.name, @p2.name] }
    end
  end


  context "multiple groups" do 

    setup do
      @p1 = Procedure.random(:name => 'p1')
      @p2 = Procedure.random(:name => 'p2')
      @p3 = Procedure.random(:name => 'p3')
      @a1 = Animal.random(:name => 'a1')
      @a2 = Animal.random(:name => 'a2')
      test_data = {
        :instructor => 'marge',
        :course => 'vm333',
        :date => Date.new(2001, 2, 4),
        :morning => false,
        :groups => [ {:procedures => ['p1', 'p2'],
                       :animals => ['a1']},
                     {:procedures => ['p3'],
                       :animals => ['a2']}]
      }
      @reservation = Reservation.create_with_groups(test_data)

      @p1_a1 = Use[:procedure_id => @p1.id, :animal_id => @a1.id]
      @p2_a1 = Use[:procedure_id => @p2.id, :animal_id => @a1.id]
      @p3_a2 = Use[:procedure_id => @p3.id, :animal_id => @a2.id]
    end

    should "create the cross-product only within a group" do
      assert { Use.all.size == 3 }
      assert { @p1_a1 } 
      assert { @p2_a1 } 
      assert { @p3_a2 } 
    end

    should "use two groups" do
      assert { @reservation.groupings.size == 2 } 
      assert { @p1_a1.grouping == @p2_a1.grouping  } 
      assert { @p1_a1.grouping != @p3_a2.grouping } 
    end

    should "be able to list all the animals involved" do
      assert { @reservation.animal_names == [ @a1.name, @a2.name] }
    end


    should "be able to list all the procedures involved" do
      assert { @reservation.procedure_names == [ @p1.name, @p2.name, @p3.name] }
    end
  end


  should "delete both self and associated uses and groupings" do
    reservation = Reservation.random(:instructor => 'marge') do 
      use Animal.random(:name => 'animal')
      use Procedure.random(:name => 'procedure')
    end

    assert { Reservation[:instructor => 'marge'] }
    assert { Reservation.all.size == 1 }
    assert { Grouping.all.size == 1 }
    assert { Use.all.size == 1 }

    reservation.destroy

    deny { Reservation[:instructor => 'marge'] }
    assert { Reservation.all.size == 0 }
    assert { Grouping.all.size == 0 }
    assert { Use.all.size == 0 }
  end

  should "leave other reservations and uses alone" do
    deleteme = Reservation.random(:instructor => 'deleteme')
    saveme = Reservation.random(:instructor => 'saveme')
    deleteme.destroy
    deny { Reservation[:instructor => 'deleteme'] }
    assert { Reservation[:instructor => 'saveme'] }
  end
end
