class AddUsefulNotifications < ActiveRecord::Migration
  def self.up
    Notification.transaction do
      Notification.create({:name => "Problema reportado", :description => "Un problema ha sido reportado", :internal_tag => "problem_report", :active => true})
      Notification.create({:name => "Problema Solucionado", :description => "Un problema ha sido solucionado", :internal_tag => "problem_solution", :active => true})
    end
  end

  def self.down
  end
end
