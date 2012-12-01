class SolutionTypePartType < ActiveRecord::Base
  belongs_to :part_type
  belongs_to :solution_type
  attr_accessible :part_type, :part_type_id
  attr_accessible :solution_type, :solution_type_id
end
