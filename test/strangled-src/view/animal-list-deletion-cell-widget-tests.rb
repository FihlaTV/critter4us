require './test/testutil/requires'
require './strangled-src/model/requires'
require './strangled-src/view/requires'

class AnimalListDeletionCellWidgetTests < Test::Unit::TestCase
  include ViewHelper
  include HtmlAssertions

  def setup
    super
    @proposed_removal_from_service_date = '2010-09-08'
    @animal = flexmock("animal", :id => 'some id').by_default
    @widget = AnimalDeletionCell.new(:animal => @animal, :proposed_removal_from_service_date => @proposed_removal_from_service_date)
  end

  should "produce a 'delete' button if in no future reservations" do
    during { 
      @widget.to_html
    }.behold! { 
      @animal.should_receive(:dates_used_after_beginning_of).
              with(@proposed_removal_from_service_date).
              and_return([])
    }
    action = "animal/#{@animal.id}"
    default_date = @proposed_removal_from_service_date
    assert_text_has_attributes(@result, 'form', :method=>"POST", :action => action)
    assert_text_has_attributes(@result, 'input',
                               :type=>"submit",  :value => 'Remove from service')
    assert_text_has_attributes(@result, 'input', :name => "_method", :value => "DELETE")
    assert_text_has_attributes(@result, 'input',
                               :type => "text", :value => default_date)
    # assert_xhtml(@result) do
    #   form(:method => "POST", :action => action) do
    #     input(:type => "submit", :value => 'Remove from service')
    #     input(:name => "_method", :value => "DELETE")
    #     input(:type => "text", :value => default_date)
    #   end
  end

  should "procedure a list of dates if future reservations" do 
    dates_to_be_used = ['2012-01-02', '2013-03-01', '2013-03-02']
    during { 
      @widget.to_html
    }.behold! { 
      @animal.should_receive(:dates_used_after_beginning_of).
              with(@proposed_removal_from_service_date).
              and_return(dates_to_be_used)
    }
    assert { @result =~ /#{dates_to_be_used.join('.*')}/  } 
  end
end
