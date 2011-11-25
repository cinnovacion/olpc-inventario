# # # #
#  Seed Data Generator:
#
#  Author: Martin Abente - tincho_02@hotmail.com
#  For Paraguay Educa OLPC project 2009
#

module SeedData

  DEFAULT_OUTPUT = Rails.root.join("init_data_#{Date.today.to_s}.rb")

  #####
  #  Generates an ruby script with all necesisary information for data seeding
  #
  def self.generate(tables, filepath = DEFAULT_OUTPUT, extra_seeds = [], banned_attributes = {})

    banned_attributes.default = []
    output = File.new(filepath, "w")

    append_seed(output, "lib/seed_data_ext.rb")

    output.write("\n\t######\n\t#  Seeding Data\n\t#\t\n")
    tables.each { |table|

      model = table.singularize.camelize.constantize 
      output.write("\t#{model.to_s}.transaction do\n\n")
      model.find(:all, :order => "id ASC").each { |object|

        output.write("\t\tcreate_if_not_exists(#{model}, #{extract_attributes(object, banned_attributes[table])})\n")
      }
      output.write("\tend\n\n")

    }

    extra_seeds.each { |seed_filepath|

      append_seed(output, seed_filepath)
    }

    output.close
  end

  private

  #####
  #  Extracts table's non banned attributes
  #
  def self.extract_attributes(object, banned_attributes)

    attribs = []
    attribs = object.attributes.keys - banned_attributes

    "{#{attribs.map { |attrib| ":#{attrib.to_s} => \"#{object.send(attrib)}\"" }.join(', ')}}"
  end

  ####
  #  Appends external scripts
  #
  def self.append_seed(output, seed_path)

    seed = File.open(seed_path,"r")

    seed_code = seed.readlines.join
    seed.close

    output.write(seed_code)
  end

end

