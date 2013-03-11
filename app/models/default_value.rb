class DefaultValue < ActiveRecord::Base
  attr_accessible :key, :value

  validates_uniqueness_of :key, :message => N_("The key must be unique.")

  FIELDS = [ 
     {name: _("Id"), column: :id, width: 50},
     {name: _("Key"), column: :key},
     {name: _("Value"), column: :value, width: 256}
  ] 

  def getKey
    self.key ? self.key : ""
  end

  def getValue
    self.value ? self.value : ""
  end

  def self.setJsonValue(key, value)

    default = DefaultValue.find_by_key(key)
    json_valued = value.to_json

    if !default
  
      DefaultValue.create({ :key => key, :value => json_valued })
    else

      default.value = json_valued
      default.save! ? default : nil
    end
  end

  def self.getJsonValue(key)

    default = DefaultValue.find_by_key(key)
    default ? JSON.parse(default.value) : nil
  end

end
