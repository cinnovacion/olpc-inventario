class SparePartsRegistry < ActiveRecord::Base

  belongs_to :place
  belongs_to :person
  belongs_to :owner, :class_name => "Person", :foreign_key => :owner_id
  belongs_to :part_type

  validates_presence_of :place_id, :message => "Debe proveer la localidad"
  validates_presence_of :person_id, :message => "Debe proveer la persona responsable"
  validates_presence_of :owner_id, :message => "Debe proveer el propietario"
  validates_presence_of :part_type_id, :message => "Debe proveer el tipo de parte"

  def self.register(register, amount, part_type, owner, serial)

    attribs = Hash.new
    attribs[:person_id] = register.id
    attribs[:owner_id] = owner.id
    attribs[:place_id] = owner.place.id
    attribs[:amount] = amount
    attribs[:part_type_id] = part_type.id
    attribs[:device_serial] = serial

    SparePartsRegistry.create!(attribs)
  end

  def before_save
    self.created_at = Date.today
  end

  ###
  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  def self.setScope(places_ids)

    find_include = [:place => :ancestor_dependencies]
    find_conditions = ["place_dependencies.ancestor_id in (?)", places_ids]

    scope = { :find => {:conditions => find_conditions, :include => find_include } }
    SparePartsRegistry.with_scope(scope) do
      yield
    end

  end

end
