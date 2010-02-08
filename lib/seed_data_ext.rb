  
  #####
  #  Basic methods
  #
  def create_if_not_exists(tClass, attrHash)

    object = tClass.find_by_id(attrHash[:id])
    if !object

      object = tClass.new
      attrHash.keys.each { |key|
   
        object.send("#{key}=", attrHash[key])
      }

      object.save!
    end

    object
  end

