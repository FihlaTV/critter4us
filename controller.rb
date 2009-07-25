require 'rubygems'
require 'sinatra/base'
require 'json'


class Controller < Sinatra::Base

  attr_writer :persistent_store

  def initialize(settings = {})
    super()
    @persistent_store = settings[:persistent_store] || PersistentStore.new
  end

  get '/json/procedures' do
    jsonically do 
      typing_as 'procedures' do
        @persistent_store.procedure_names.sort
      end
    end
  end

  get '/json/all_animals' do
    jsonically do 
      typing_as 'animals' do 
        @persistent_store.all_animals.sort
      end
    end
  end


  private

  def jsonically
    response['Content-Type'] = 'application/json'
    yield.to_json
  end

  def typing_as(type)
    {type.to_s => yield }
  end
    

end
