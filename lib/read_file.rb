# encoding: UTF-8
#
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

require 'tempfile'

module ReadFile
  def self.titleize(str)
    # titleize doesn't handle multibyte chars well, so we provide our own
    # version
    #
    # Remove this function when the solution to 
    # https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/2794
    # is available in a required version of Ruby
    str.mb_chars.downcase.to_s.gsub(/\b('?[\S])/u) { $1.mb_chars.upcase }
  end

  # Spreadsheets exported from Excel often result in the grade numbers
  # ending up as float (e.g. "1.0") even if you try hard to mark the
  # field as a string. Handle that here.
  def self.numberCleaner(string)
    string.to_s.strip.gsub(/(\.\d+)|(\,\d+)/, "")
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
    Spreadsheet.open(filename).worksheet(worksheet).each { |row|
      next if row == nil
      dataArray = row.map() { |c| c ? c.to_s : "" }

      name = dataArray[_name].to_s.strip
      lastname = dataArray[_lastname].to_s.strip
      next if name == "" and lastname == ""

      grade = numberCleaner(dataArray[_grade])
      gradeInfo = gradeHash[grade]

      schoolInfo = numberCleaner(dataArray[_school])
      shiftInfo = shiftHash[dataArray[_shift].to_s.downcase.strip]
      sectionInfo = sectionHash[dataArray[_section].to_s.downcase.strip]

      # Make sure there is a school.
      if schoolInfo == ""
        raise "Invalid school (of %s %s)" % [name, lastname]
      end

      # try to detect user error in importing a spreadsheet of teacher info
      # (we can only do this when the teacher spreadsheet includes assignments,
      #  otherwise the only field we can look at is blank, which is valid here)
      if !gradeInfo and dataArray[_grade] and dataArray[_grade] != ""
        raise "Invalid grade %s (of %s %s)" % [dataArray[_grade], name, lastname]
      end

      # Assert that shift info is valid, if given
      if !shiftInfo and dataArray[_shift] and dataArray[_shift] != ""
        raise "Invalid shift %s (of %s %s)" % [dataArray[_shift], name, lastname]
        # Would be cool to show the row number
      end

      # Assert that section info is valid, if given
      if !sectionInfo and dataArray[_section] and dataArray[_section] != ""
        raise "Invalid section %s (of %s %s)" % [dataArray[_section], name, lastname]
        # Would be cool to show the row number
      end

      section = Place.theSwissArmyKnifeFuntion(city.id, schoolInfo, shiftInfo, gradeInfo, sectionInfo)

      name = titleize(name)
      lastname = titleize(lastname)
      id_document = numberCleaner(dataArray[_ci])

      kid = Person.find_by_id_document(id_document)
      if !kid
        kidAttribs = Hash.new
        kidAttribs[:name] = name
        kidAttribs[:lastname] = lastname
        kidAttribs[:id_document] = id_document

        profiles = [student_profile_id]
        performs = [[section.id, student_profile_id]]
        kid = Person.register(kidAttribs, performs, "", register, schoolInfo)
      end

      laptop_sn = dataArray[_laptop_sn].to_s.strip.upcase
      if laptop_sn != ""
        laptop = Laptop.find_by_serial_number(laptop_sn)
        if laptop == nil
           raise "Can't find laptop #{laptop_sn} (of #{name} #{lastname})"
        end

        assignment = Hash.new
        assignment[:serial_number_laptop] = laptop_sn
        assignment[:person_id] = kid.id
        assignment[:comment] = "From students import"
        Assignment.register(assignment)
      end

    }
    end

    true
  end

  def self.teachersFromFile(filename, worksheet, place_id, register)

    teacher_profile_id = Profile.find_by_internal_tag("teacher").id
    city = Place.find_by_id(place_id)

    _name =  0
    _lastname = 1
    _id_document = 2
    _school_name = 3
    _laptop_sn = 4

   Person.transaction do
     Spreadsheet.open(filename).worksheet(worksheet).each { |row|
       next if row == nil
       dataArray = row.map() { |c| c ? c.to_s : "" }

       name = dataArray[_name].to_s.strip
       lastname = dataArray[_lastname].to_s.strip
       school_name = numberCleaner(dataArray[_school_name])

       next if name == "" and lastname == ""
       raise _("No school provided for #{name} #{lastname}") if school_name == ""

       name = titleize(name)
       lastname = titleize(lastname)
       id_document = numberCleaner(dataArray[_id_document])
       school = Place.theSwissArmyKnifeFuntion(city.id, school_name, nil, nil, nil)

       teacher = Person.find_by_id_document(id_document)
       if !teacher
         attribs = Hash.new
         attribs[:name] = name
         attribs[:lastname] = lastname
         attribs[:id_document] = id_document
         new_performs = [[school.id, teacher_profile_id]]

         teacher = Person.register(attribs, new_performs, "", register, school_name)
       end

       laptop_sn = dataArray[_laptop_sn].to_s.strip.upcase
       if laptop_sn != ""
         laptop = Laptop.find_by_serial_number(laptop_sn)
         if laptop == nil
            raise "Can't find laptop #{laptop_sn} (for #{name} #{lastname})"
         end

         assignment = Hash.new
         assignment[:serial_number_laptop] = laptop_sn
         assignment[:id_document] = teacher.id_document
         assignment[:comment] = "From teachers import"
         Assignment.register(assignment)
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
end
