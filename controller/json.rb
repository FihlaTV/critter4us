class Controller

  get '/json/course_session_data_blob' do
    internal = move_to_internal_format(params)
    timeslice.move_to(internal[:date], internal[:time], ignored_reservation)
    procedure_names = procedure_source.sorted_names
    jsonically do 
      answer = {
        'animals' => timeslice.available_animals_by_name,
        'procedures' => procedure_names,
        'kindMap' => animal_source.kind_map,
        'exclusions' => self.exclusions(procedure_names)
        
      }
      answer
    end
  end

  post '/json/store_reservation' do
    tweak_reservation do | hash | 
      reservation_source.create_with_groups(hash)
    end
  end

  post '/json/modify_reservation' do
    id = params['reservationID'].to_i;
    tweak_reservation do | hash | 
      reservation_source[id].with_updated_groups(hash)
    end
  end

  get '/json/reservation/:number' do
    number = params[:number]
    jsonically do 
      reservation = reservation_source[number]
      timeslice.move_to(reservation.date, reservation.time, ignored_reservation)
      procedure_names = procedure_source.sorted_names
      reservation_data = {
        :instructor => reservation.instructor,
        :course => reservation.course,
        :date => reservation.date.to_s,
        :time => reservation.time,
        :groups => reservation.groups.collect { | g | g.in_wire_format },
        :procedures => procedure_names,
        :animals => timeslice.available_animals_by_name,
        :kindMap => animal_source.kind_map,
        :exclusions => self.exclusions(procedure_names),
        :id => reservation.pk.to_s
      }
      # pp reservation_data
    end
  end


  # tested
  def symbol_keys(hash)
    retval = {}
    hash.each do | k, v | 
      retval[k.to_sym] = v
    end
    return retval
  end

  def move_to_internal_format(hash)
    result = symbol_keys(hash)
    result[:date] = Date.parse(result[:date]) if result[:date]
    if result[:groups]
      result[:groups] = result[:groups].collect { | group | 
        symbol_keys(group)
      }
    end
    result
  end

  def exclusions(procedure_names)  # TODO: Why bother with hash_maker?
    excluded_pairs = []
    timeslice.add_excluded_pairs(excluded_pairs)
    hash_maker.keys_and_pairs(procedure_names, excluded_pairs)
  end

  private

  def tweak_reservation
    hash = move_to_internal_format(JSON.parse(params['data']))
    reservation = yield hash
    jsonically do
      typing_as "reservation" do 
        reservation.pk.to_s
      end
    end
  end

  def jsonically
    response['Content-Type'] = 'application/json'
    yield.to_json
  end

  def typing_as(type)
    {type.to_s => yield }
  end

  def ignored_reservation
    ignoring = params[:ignoring]
    return nil unless ignoring
    Reservation[ignoring.to_i]
  end



end