class Controller
  attr_accessor :test_view_builder
  def view(klass); test_view_builder || klass; end

  get '/' do
    redirect '/index.html'
  end

  get '/reservation/:number' do
    number = params[:number]
    ReservationView.new(:reservation => reservation_source[number]).to_pretty
  end

  delete '/reservation/:number' do
    number = params[:number]
    reservation_source[number].destroy
    redirect '/reservations'
  end

  get '/reservations' do 
    view(ReservationListView).new(:reservations => reservation_source.all).to_s
  end

  get '/animals' do 
    view(AnimalListView).new(:animals => animal_source.all).to_s
  end
end
