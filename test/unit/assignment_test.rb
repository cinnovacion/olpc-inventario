require 'test_helper'

class AssignmentTest < ActiveSupport::TestCase
  test "can't delete person with laptop assigned" do
    # Found about 250 laptops in the Nicaragua production db, assigned to
    # a non-existant person.
    l = default_person.laptops.create!(:serial_number => "SHC12345678")

    assignee = Person.create!(:name => "Assignee", :id_document => "assignee")
    Assignment.register(:serial_number_laptop => "SHC12345678", :person_id => assignee.id)
    assert_raise(ActiveRecord::StatementInvalid) { assignee.destroy }
  end

  test "laptops get activated upon assignment" do
    l = default_person.laptops.create!(:serial_number => "SHC12345678")
    assert_equal "deactivated", l.status.internal_tag

    Assignment.register(:serial_number_laptop => "SHC12345678", :person_id => default_person.id)

    l.reload
    assert_equal "activated", l.status.internal_tag
  end

  test "register" do
    assignment = Assignment.register(serial_number_laptop: "SHC00000000",
                                     person_id: default_person.id)
    assert_equal default_person.id, assignment.destination_person_id
    laptop = Laptop.find_by_serial_number("SHC00000000")
    assert_equal default_person.id, laptop.assignee_id
  end

  test "register deassignment" do
    Assignment.register(serial_number_laptop: "SHC00000000",
                                     person_id: default_person.id)
    assignment = Assignment.register(serial_number_laptop: "SHC00000000")
    assert_equal nil, assignment.destination_person_id
    laptop = Laptop.find_by_serial_number("SHC00000000")
    assert_equal nil, laptop.assignee_id
  end

  test "register bad person" do
    assert_raise(ActiveRecord::RecordNotFound) do
      Assignment.register(serial_number_laptop: "SHC00000000", person_id: "hello")
    end
  end

  test "register bad laptop" do
    assert_raise(ActiveRecord::RecordNotFound) do
      Assignment.register(serial_number_laptop: "SHC", person_id: default_person.id)
    end
  end
end
