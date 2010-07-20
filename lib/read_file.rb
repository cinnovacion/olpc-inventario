#     Copyright Paraguay Educa 2009
#
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>
# 
#                                                                          

# # #
# Author: Martin Abente
# E-mail Address:  (tincho_02@hotmail.com | mabente@paraguayeduca.org) 
# 2009
# # #

require "parseexcel"
require 'tempfile'

module ReadFile

  #Loads from a txt file the data provided by shipments arrival.
  # dataHash must provide :
  #   :arrived_at, for shipment creation.
  #   :place_id, for shipment and box creation.
  #    And for laptop creation :
  #     :build_version,
  #     :model_id,
  #     :owner_id
  def self.laptopsFromFile(filename, worksheet, dataHash)
    
   _shipment = 0
   #_box_serial = 2
   _laptop_serial = 3

    Laptop.transaction do
      Spreadsheet::ParseExcel.parse(filename).worksheet(worksheet).each { |row|
        dataArray = row.map { |cell| cell ? cell.to_s('utf-8') : "" }

        #First we check if the shipment exists, else we created it.
        shipment = Shipment.find_by_shipment_number(dataArray[_shipment])
        if !shipment

          attribs = Hash.new
          attribs[:shipment_number] = dataArray[_shipment]
          attribs[:arrived_at] = dataHash[:arrived_at]
          attribs[:comment] = "##{dataArray[_shipment]} from script"
          shipment = Shipment.new(attribs)
          shipment.save!
        end

        #The we check for the box existance.
        #box = Box.find_by_serial_number(dataArray[_box_serial])
        #if !box

          #attribs = Hash.new
          #attribs[:serial_number] = dataArray[_box_serial]
          #attribs[:shipment_id] = shipment.id
          #attribs[:place_id] = dataHash[:place_id]
          #box = Box.new(attribs)
          #box.save!
        #end

        #Now we start creating the laptop entry.
        attribs = Hash.new
        attribs[:serial_number] = dataArray[_laptop_serial]
        attribs[:build_version] = dataHash[:build_version]
        attribs[:model_id] = dataHash[:model_id]
        attribs[:shipment_arrival_id] = shipment.id
        attribs[:owner_id] = dataHash[:owner_id]
        attribs[:assignee_id] = dataHash[:assignee_id]
        attribs[:status_id] = dataHash[:status_id]
        #attribs[:box_serial_number] = dataArray[_box_serial]
        #attribs[:box_id] = box.id
        Laptop.create!(attribs)
      }
    end
  end

  #This going to frad from Daniel's uuids list and update uuid field.
  def self.uuidFromFile(filename, separator)
    File.open(filename).each { |row|
      dataArray = row.split(separator).map { |column| column.strip }
      laptop = Laptop.find_by_serial_number(dataArray[0])
      if laptop
        laptop.uuid = dataArray[1]
        laptop.save!
      else
        raise "#{dataArray[0]} is not a valid serial number."
      end
    }
    nil
  end

  #This reads from that small python app i made incase everything goes wrong.
  def self.laptopsFromPlanC(dataGrid,dataHash)
    dataGrid.each { |dataArray|
      attribs = Hash.new
      attribs[:movement_type_id] = dataHash[:movement_type_id]
      attribs[:id_document] = dataArray[3]
      attribs[:serial_number_laptop] = dataArray[4]
      attribs[:serial_number_battery] = dataArray[5]
      attribs[:serial_number_charger] = dataArray[6]
      attribs[:comment] = "Entrega desde el sistema planC a #{dataArray[1]} #{dataArray[2]} en #{dataArray[0]} el #{dataArray[7]}."
      Movement.register(attribs)
    }
  end

  def self.titleize(str)
    # titleize doesn't handle multibyte chars well, so we provide our own
    # version
    #
    # Remove this function when the solution to 
    # https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/2794
    # is available in a required version of Ruby
    str.mb_chars.downcase.to_s.gsub(/\b('?[\S])/u) { $1.mb_chars.upcase }
  end

  #Reads from Teo's school kids file.
  # The Schools, shifts, grades and sections must be already added.
  def self.kidsFromFile(filename, worksheet, place_id, register)

    #We get all the constant values.
    student_profile_id = Profile.find_by_internal_tag("student").id
    city = Place.find_by_id(place_id)

    gradeHash = Hash.new()
    gradeHash["1"] = "first_grade"
    gradeHash["2"] = "second_grade"
    gradeHash["3"] = "third_grade"
    gradeHash["4"] = "fourth_grade"
    gradeHash["5"] = "fifth_grade"
    gradeHash["6"] = "sixth_grade"
    gradeHash["7"] = "seventh_grade"
    gradeHash["8"] = "eighth_grade"
    gradeHash["9"] = "ninth_grade"
    gradeHash["p"] = "kinder"
    gradeHash["Educ  Especial"] = "special"

    shiftHash = Hash.new()
    shiftHash["m"] = "Turno Mañana"
    shiftHash["t"] = "Turno Tarde"
    shiftHash["c"] = "Turno Completo"

    sectionHash = Hash.new()
    sectionHash["a"] = "Seccion A"
    sectionHash["b"] = "Seccion B"
    sectionHash["c"] = "Seccion C"
    sectionHash["d"] = "Seccion D"

    #Caacupe specific data
    sectionHash["colon"] = "Seccion Colon"
    sectionHash["futuro"] = "Seccion Futuro"
    sectionHash["yegros"] = "Seccion Yegros"
    sectionHash["cap. figari"] = "Seccion Cap. Figari"
    sectionHash["esperatti"] = "Seccion Esperatti"
    sectionHash["hernandarias"] = "Seccion Hernandarias"
    sectionHash["pedro juan c."] = "Seccion Pedro Juan C."
    sectionHash["M.A.C."] = "Seccion M.A.C."
    sectionHash["R.S."] = "Seccion R.S."
    sectionHash["tte. rojas silva"] = "Seccion Tte. Rojas Silva"
    sectionHash["pestalozzi"] = "Seccion Pestalozzi"
    sectionHash["pte. franco"] = "Seccion Pte. Franco"
    sectionHash["mcal. Lopez"] = "Seccion Mcal. Lopez"


    _name = 0
    _lastname = 1
    _ci = 2
    _school = 3
    _grade = 4
    _shift = 5
    _section = 6
    _laptop_sn = 7

    Person.transaction do
    #There we go!
    Spreadsheet::ParseExcel.parse(filename).worksheet(worksheet).each { |row|
      dataArray = row.map() { |c| c ? c.to_s('utf-8') : "" }
 
      schoolInfo = dataArray[_school].strip
      shiftInfo = shiftHash[dataArray[_shift]]
      gradeInfo = gradeHash[dataArray[_grade]]
      sectionInfo = sectionHash[dataArray[_section]]

      section = Place.theSwissArmyKnifeFuntion(city.id, schoolInfo, shiftInfo, gradeInfo, sectionInfo)

      kidAttribs = Hash.new

      name = titleize(dataArray[_name].strip)
      lastname = titleize(dataArray[_lastname].strip)
      kidAttribs[:name] = name
      kidAttribs[:lastname] = lastname

      if dataArray[_ci] != ""
        cedula = Person.cedulaCleaner!(dataArray[_ci])
      else
        cedula = name+"_"+dataArray[_school]+"_"+rand(999999).to_s
      end
      kidAttribs[:id_document] = cedula

      profiles = [student_profile_id]
      performs = [[section.id, student_profile_id]]

      Person.register(kidAttribs, performs, "", register)

      laptop_sn = dataArray[_laptop_sn]
      if laptop_sn != ""
        laptop = Laptop.find_by_serial_number(laptop_sn)
        if laptop == nil
           raise "Can't find laptop #{laptop_sn}"
        end

        assignment = Hash.new
        assignment[:serial_number_laptop] = dataArray[_laptop_sn]
        assignment[:id_document] = cedula
        assignment[:comment] = "From students import"
        Assignment.register(assignment)
      end

    }
    end

    true
  end

  def self.teachersFromFile(filename, worksheet, register)

    teacher_profile_id = Profile.find_by_internal_tag("teacher").id

    gradeHash = Hash.new("Dummy Grade")
    gradeHash["1"] = "first_grade"
    gradeHash["2"] = "second_grade"
    gradeHash["3"] = "third_grade"
    gradeHash["4"] = "fourth_grade"
    gradeHash["5"] = "fifth_grade"
    gradeHash["6"] = "sixth_grade"
    gradeHash["7"] = "seventh_grade"
    gradeHash["8"] = "eighth_grade"
    gradeHash["9"] = "ninth_grade"
    gradeHash["p"] = "kinder"
    gradeHash["Educ. Especial"] = "special"

    _name =  0
    _lastname = 1
    _id_document = 2
    _school_name = 3

   Person.transaction do
     Spreadsheet::ParseExcel.parse(filename).worksheet(worksheet).each { |row|
       dataArray = row.map() { |c| c ? c.to_s('utf-8') : "" }

       name  = dataArray[_name]
       lastname  = dataArray[_lastname]
       id_document = dataArray[_id_document].gsub(/,| /,'')
       school_name = dataArray[_school_name]
       raise "There is no #{school_name} school name" if school_name == "Dummy Grade"
       school = Place.find_by_name(school_name)
       raise "You can not access #{school_name} school data" if !school

       attribs = Hash.new
       attribs[:name] = name
       attribs[:lastname] = lastname
       attribs[:id_document] = id_document
       new_performs = [[school.id, teacher_profile_id]]

       teacher = Person.find_by_id_document(id_document)
       if !teacher
         Person.register(attribs, new_performs, "", register)
       end
     }
   end
  end

  #Returns the temporal file path.
  def self.fromParam(upload_file, prefix = "spreadsheet")
    path = ""
    case upload_file
      when ActionController::UploadedStringIO
        path = Tempfile.new(prefix).path
        File.open(path, "w") { |file| file.write(upload_file.read) }
      when ActionController::UploadedTempfile
        path = upload_file.path
    end
    path
  end

  #Loads from xls files and returns a list.
  def self.fromXls(filename,worksheet=0)
    wb = Spreadsheet::ParseExcel.parse(filename)
    rows = wb.worksheet(worksheet).map() { |r| r }.compact
    grid = rows.map() { |r| r.map() { |c| c.to_s('utf-8')}.compact rescue nil }
  end

  #Loads from plain text file and returns a list
  def self.fromPlainText(filename,separator)
    File.open(filename).map { |row|
      row.split(separator).map { |column|
        column.strip
      }
    }
  end

end
