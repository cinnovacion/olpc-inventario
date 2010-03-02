class DefaultValue < ActiveRecord::Base

  validates_uniqueness_of :key, :message => "La llave debe ser unica."

  def self.getColumnas()
    [ 
     {:name => _("Id"), :key => "default_values.id", :related_attribute => "id", :width => 50},
     {:name => _("Key"), :key => "default_values.key", :related_attribute => "getKey", :width => 100},
     {:name => _("Value"), :key => "default_values.value", :related_attribute => "getValue", :width => 256}
    ] 
  end

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
