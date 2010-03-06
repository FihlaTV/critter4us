require 'util/extensions'

class Controller

  before do
    if request.path =~ %r{/json/}
      response['Content-Type'] = 'application/json'
    end
  end

  get '/json/animals_and_procedures_blob' do
    availability = @availability_source.new(@internalizer.make_timeslice(params['timeslice']),
                                            @internalizer.integer_or_nil(params['ignoring']))

    externalize(:animals => availability.animals_that_can_be_reserved,
                :procedures => availability.procedures_that_can_be_assigned,
                :kindMap => availability.kind_map,
                :timeSensitiveExclusions => availability.exclusions_due_to_reservations,
                :timelessExclusions => availability.exclusions_due_to_animal)
  end

  post '/json/store_reservation' do
    reservation_data = @internalizer.convert(params)[:data]
    new_reservation = reservation_source.create_with_groups(reservation_data)
    externalize(reservation_id(new_reservation))
  end

  post '/json/modify_reservation' do
    internal = @internalizer.convert(params)
    id = internal[:reservationID]
    reservation_data = internal[:data]
    updated_reservation = reservation_source[id].with_updated_groups(reservation_data)
    externalize(reservation_id(updated_reservation))
  end

  post '/json/take_animals_out_of_service' do
    internal = @internalizer.convert(params)[:data]
    internal[:animals].each do | animal_name |
      Animal[:name => animal_name].remove_from_service_as_of(internal[:date])
    end
  end

  get '/json/reservation/:number' do
    reservation_to_fetch = @internalizer.find_reservation(params, 'number')
    reservation_to_ignore = @internalizer.find_reservation(params, 'ignoring')
    availability = @availability_source.new(reservation_to_fetch.timeslice,
                                            reservation_to_ignore)
    externalize(reservation_hash(reservation_to_fetch).merge(
                availability.animals_and_procedures_and_exclusions))
  end

  get '/json/animals_that_can_be_taken_out_of_service' do
    # Note: this params list contains a single date, not full timeslice data
    timeslice = @internalizer.make_timeslice_from_date(params['date'])
    availability = @availability_source.new(timeslice)
#    animals = timeslice.animals_that_can_be_reserved
#    hashes = timeslice.hashes_from_animals_to_pending_dates(animals)
#    animals_without_uses = filter_unused_animals(hashes)
    externalize('unused animals' => availability.animals_without_uses)
  end

  private

  def reservation_id(reservation) 
    {"reservation" => reservation.pk.to_s}
  end

  def reservation_hash(reservation)
    {:instructor => reservation.instructor,
      :course => reservation.course,
      :firstDate => reservation.first_date,
      :lastDate => reservation.last_date,
      :times => reservation.times,
      :groups => reservation.groups,
      :id => reservation.pk.to_s
    }
  end

  def externalize(hash)
    @externalizer.convert(hash)
  end

  # TODO: MOVE
  def filter_unused_animals(hashes)
    hashes.find_all { | hash |
      hash.only_value.empty?
    }.collect { | hash | 
      hash.only_key
    }.sort
  end
end
