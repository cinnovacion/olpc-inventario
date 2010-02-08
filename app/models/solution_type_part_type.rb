class SolutionTypePartType < ActiveRecord::Base
  belongs_to :part_type
  belongs_to :solution_type
end
