require 'test/testutil/requires'
require 'test/testutil/config'
require 'test/testutil/dbhelpers'
require 'admin/tables'
require 'model'

class Date
  def inspect
    to_s
  end
end
    

class ExclusionMapTests < Test::Unit::TestCase
  BoundaryCases = [
# Reservation attempt for date after previously-made reservation
      # DELAY       USED-ON        TRY-AGAIN          OK?
[          0,       1, :morning,     1, :morning,        :NO ],        # 1
[          0,       1, :morning,     1, :afternoon,        :yes ],

[          1,       1, :morning,     1, :afternoon,      :NO ],
[          1,       1, :afternoon,   2, :morning,        :YES ],       # 4

[          2,       1, :afternoon,   3, :morning,        :YES ],

# Reservation attempt for date before previously-made reservation
      # DELAY       USED-ON        TRY-FOR-BEFORE          OK?
[          0,       1, :afternoon,   1, :afternoon,        :NO ],
[          0,       1, :afternoon,   1, :morning,          :yes],

[          1,       2, :afternoon,   2, :afternoon,        :NO],
[          1,       2, :afternoon,   2, :morning,          :NO],  # no new info but just in case
[          1,       2, :afternoon,   1, :afternoon,        :YES],     # 10
[          1,       2, :morning,     1, :morning  ,        :YES], # no new
[          1,       2, :morning,     1, :afternoon,        :YES], # perhaps surprising

[          2,       3, :afternoon,   3, :morning,          :NO],
[          2,       3, :morning,     2, :morning,          :NO],
[          2,       3, :morning,     1, :afternoon,        :YES],
[          2,       3, :afternoon,     1, :afternoon,      :YES], # no new


[          7,       3, :afternoon,     1, :afternoon,      :NO], # no new
    ]

  def self.boundary_test(row, index)
    defn = %Q{
      def test_boundary_case_#{index}
        # puts "=========== boundary test #{index}"
        # puts #{row.inspect}.inspect
        boundary = BoundaryCases[#{index}]
        prior_reservation(*boundary[0,3])
        run_attempt(*boundary[3,2])
        assert_reservation_success(boundary.last)
      end
    }
    class_eval defn
  end

  BoundaryCases.each_with_index do | row, index |
    boundary_test(row, index)
  end

  def excluded?(is_ok)
    is_ok == :NO
  end

  def prior_reservation(delay, date, time)
    @animal = Animal.create(:name => "bossie")
    @procedure = Procedure.create(:name => 'only', :days_delay => delay)
    @reservation = Reservation.create(:date => Date.new(2009, 12, date),
                                      :morning => (time == :morning))
    @use = Use.create(:animal => @animal, :procedure => @procedure, :reservation => @reservation)
    # puts "all uses:"
    # puts DB[:expanded_uses].all.inspect
  end


  def run_attempt(attempt_date, attempt_time)
    # puts "attempt at #{[attempt_date, attempt_time].inspect}"
    @map = ExclusionMap.new(Date.new(2009, 12, attempt_date),
                            attempt_time == :morning)
  end

  def assert_reservation_success(is_ok)
    expected = excluded?(is_ok) ? [@animal.name] : []
    # puts "Expect: attempt ok? #{is_ok} excluded? #{expected}"
    # puts "Actual: #{@map.to_hash.inspect}"
    assert { @map.to_hash == { 'only' => expected } }
  end


  def setup
    empty_tables
  end

  should "produce no exclusions if no uses" do
    Procedure.create(:name => 'only', :days_delay => 14)
    map = ExclusionMap.new(Date.new(2009, 7, 23), true)
    assert { map.to_hash == { 'only' => [] } }
  end

  should "work with a typical example" do
    venipuncture = Procedure.create(:name => 'venipuncture', :days_delay => 7)
    physical_exam = Procedure.create(:name => 'physical exam', :days_delay => 1)
    
    veinie = Animal.create(:name => 'veinie')
    bossie = Animal.create(:name => 'bossie')
    staggers = Animal.create(:name => 'staggers')

    eight31 = Reservation.create(:date => Date.new(2009, 8, 31)) # Previous Monday
    nine1 = Reservation.create(:date => Date.new(2009, 9, 1))  # Previous Tuesday
    nine7 = Reservation.create(:date => Date.new(2009, 9, 7))  # Today, Monday

    Use.create(:animal => bossie, :procedure => venipuncture,
               :reservation => eight31);
    Use.create(:animal => staggers, :procedure => venipuncture,
               :reservation => nine1);
    Use.create(:animal => veinie, :procedure => venipuncture,
               :reservation => nine7);
    Use.create(:animal => veinie, :procedure => physical_exam,
               :reservation => nine7);

    # What can not be scheduled today?
    actual = ExclusionMap.new(Date.new(2009, 9, 7), true).to_hash
    assert { actual['venipuncture'].include?('staggers') }
    assert { actual['venipuncture'].include?('veinie') }
    deny { actual['venipuncture'].include?('bossie') }
    assert { actual['physical exam'].include?('veinie') }
    deny { actual['physical exam'].include?('staggers') }
    deny { actual['physical exam'].include?('bossie') }

    # What can not be scheduled tomorrow?
    actual = ExclusionMap.new(Date.new(2009, 9, 8), true).to_hash
    deny { actual['venipuncture'].include?('staggers') }
    assert { actual['venipuncture'].include?('veinie') }
    deny { actual['venipuncture'].include?('bossie') }
    deny { actual['physical exam'].include?('veinie') }
    deny { actual['physical exam'].include?('staggers') }
    deny { actual['physical exam'].include?('bossie') }

    # What can not be scheduled next Sunday?
    actual = ExclusionMap.new(Date.new(2009, 9, 13), true).to_hash
    deny { actual['venipuncture'].include?('staggers') }
    assert { actual['venipuncture'].include?('veinie') }
    deny { actual['venipuncture'].include?('bossie') }
    deny { actual['physical exam'].include?('veinie') }
    deny { actual['physical exam'].include?('staggers') }
    deny { actual['physical exam'].include?('bossie') }

    # What can not be scheduled next Monday?
    actual = ExclusionMap.new(Date.new(2009, 9, 14), true).to_hash
    deny { actual['venipuncture'].include?('staggers') }
    deny { actual['venipuncture'].include?('veinie') }
    deny { actual['venipuncture'].include?('bossie') }
    deny { actual['physical exam'].include?('veinie') }
    deny { actual['physical exam'].include?('staggers') }
    deny { actual['physical exam'].include?('bossie') }
  end


end