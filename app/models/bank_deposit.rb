class BankDeposit < ActiveRecord::Base

  belongs_to :problem_solution

  def self.getColumnas()
    [ 
     {:name => _("Id"), :key => "bank_deposits.id", :related_attribute => "getId", :width => 50},
     {:name => _("Solution"), :key => "problem_solutions.id", :related_attribute => "getSolutionId", :width => 100},
     {:name => _("Deposit"), :key => "bank_deposits.deposit", :related_attribute => "getDeposit", :width => 100},
     {:name => _("Amount"), :key => "bank_deposits.amount", :related_attribute => "getAmount", :width => 100},
     {:name => _("Created at"), :key => "bank_deposits.created_at", :related_attribute => "getCreatedAt", :width => 100},
     {:name => _("Deposited at"), :key => "bank_deposits.deposited_at", :related_attribute => "getDepositedAt", :width => 100},
     {:name => _("Bank"), :key => "bank_deposits.bank", :related_attribute => "getBank", :width => 100}
    ]
  end

  def self.register(problem_solution_id, data_list)

    BankDeposit.transaction do

      to_be_destroy = BankDeposit.find_all_by_problem_solution_id(problem_solution_id)
      BankDeposit.destroy(to_be_destroy) if to_be_destroy != []

      data_list.each { |data|
      
        BankDeposit.create!({ 
                              :problem_solution_id => problem_solution_id,
                              :deposit => data[0],
                              :amount => data[1],
                              :deposited_at => data[2],
                              :bank => "Familiar" 
        })
      }
    end

  end

  def self.check(solution_type, data_list)
  
    return false if solution_type.requirePart && data_list == []
    true
  end

  def before_create
    self.created_at = Date.today
  end

  def getId
    self.id.to_s
  end

  def getSolutionId
    self.problem_solution_id ? self.problem_solution_id.to_s : ""
  end

  def getDeposit
   self.deposit ? self.deposit : ""
  end

  def getAmount
    self.amount ? self.amount : ""
  end

  def getCreatedAt
    self.created_at ? self.created_at.to_s : ""
  end

  def getBank
    self.bank ? self.bank : ""
  end

  def getDepositedAt
    self.deposited_at ? self.deposited_at.to_s : ""
  end

  ###
  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  def self.setScope(places_ids)

    find_include = [:problem_solution => {:problem_report => {:place => :ancestor_dependencies}}]
    find_conditions = ["place_dependencies.ancestor_id in (?)", places_ids]

    scope = { :find => {:conditions => find_conditions, :include => find_include } }
    BankDeposit.with_scope(scope) do
      yield
    end

  end

end
