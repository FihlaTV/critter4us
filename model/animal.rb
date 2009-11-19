require 'pp'

class Animal < Sequel::Model
  one_to_many :uses

  # Postgres 8.3.5 doesn't seem to recognize columns names with underscores. 
  # Try Animal.columns vs. DB[:animals].columns
  def procedure_description_kind 
    self.values[:procedure_description_kind]
  end

  def self.names; map(:name); end
  def self.sorted_names; names.sort; end

  # This doesn't work under 1.8.7 / Snow Leopard - perhaps because name isn't defined yet.
  # alias_method :in_wire_format, :name    
  def in_wire_format; name; end

  def self.kind_map
    map = {}
    Animal.all.each { | a | map[a.name] = a.kind }
    map
  end

  def remove_from_service(date)
    self.date_removed_from_service = date
    save_changes
  end

  # following are for testing

  def self.random(overrides = {})
    defaults = {
      :name => 'jake',
      :kind => 'gelding',
      :procedure_description_kind => 'equine'
    }
    create(defaults.merge(overrides));
  end

  def self.random_with_names(*names)
    names.each do | name | 
      random(:name => name)
    end
  end
end

