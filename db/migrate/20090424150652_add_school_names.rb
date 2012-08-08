# encoding: UTF-8

class AddSchoolNames < ActiveRecord::Migration
  def self.up
    school_list = [
                    ["40", "Tte Farina"],
                    ["201", "Tte Aquino"],
                    ["254", "Herminia Machado"],
                    ["7423", "Sta Teresita (Municipal)"],
                    ["278", "Raul Pena"],
                    ["425", "Dr Pino"],
                    ["485", "Daniel Ortellado"],
                    ["691", "Prof. Cabrera"],
                    ["1080", "Cristo Rey"],
                    ["15215", "Sta Teresa del Niño Jesus (Cabanas)"]
                  ]
    Place.transaction do
      school_list.each { |school_def|
        school = Place.find_by_name(school_def[0])
        if school 
          school.description = school_def[1]
          school.save!
        end
      }
    end

  end

  def self.down
  end
end
