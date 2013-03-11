class BankDeposit < ActiveRecord::Base
  belongs_to :problem_solution

  attr_accessible :problem_solution, :problem_solution_id
  attr_accessible :deposit, :amount, :desposited_at, :bank

  FIELDS = [
    {name: _("Id"), column: :id, width: 50},
    {name: _("Solution"), association: :problem_solution, column: :id},
    {name: _("Deposit"), column: :deposit},
    {name: _("Amount"), column: :amount},
    {name: _("Created at"), column: :created_at},
    {name: _("Deposited at"), column: :deposited_at},
    {name: _("Bank"), column: :bank}
  ]

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

  def getId
    self.id.to_s
  end

  def getDeposit
   self.deposit ? self.deposit : ""
  end

  def getAmount
    self.amount ? self.amount : ""
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
    scope = includes(:problem_solution => {:problem_report => {:place => :ancestor_dependencies}})
    scope = scope.where("place_dependencies.ancestor_id in (?)", places_ids)
    BankDeposit.with_scope(scope) do
      yield
    end
  end

end
