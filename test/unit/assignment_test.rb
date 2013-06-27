require 'test_helper'

class AssignmentTest < ActiveSupport::TestCase
  test "can't delete person with laptop assigned" do
    # Found about 250 laptops in the Nicaragua production db, assigned to
    # a non-existant person.
    l = default_person.laptops.create!(serial_number: "SHC12345678")
    assignee = Person.create!(name: "Assignee", id_document: "assignee")
    Assignment.register(laptop_id: l.id, person_id: assignee.id)
    assert_raise(ActiveRecord::StatementInvalid) { assignee.destroy }
  end

  test "laptops get activated upon assignment" do
    l = default_person.laptops.create!(serial_number: "SHC12345678")
    assert_equal "deactivated", l.status.internal_tag

    Assignment.register(laptop_id: l.id, person_id: default_person.id)

    l.reload
    assert_equal "activated", l.status.internal_tag
  end

  test "laptops get deactivated upon desassignment" do
    l = default_person.laptops.create!(serial_number: "SHC12345678")
    Assignment.register(laptop_id: l.id, person_id: default_person.id)
    l.reload
    assert_equal "activated", l.status.internal_tag

    Assignment.register(laptop_id: l.id)
    l.reload
    assert_equal "deactivated", l.status.internal_tag
  end

  test "register" do
    laptop = Laptop.find_by_serial_number!("SHC00000000")
    assignment = Assignment.register(laptop_id: laptop.id,
                                     person_id: default_person.id)

    laptop.reload
    assert_equal default_person.id, assignment.destination_person_id
    assert_equal default_person.id, laptop.assignee_id
  end

  test "register deassignment" do
    laptop = Laptop.find_by_serial_number!("SHC00000000")
    Assignment.register(laptop_id: laptop.id, person_id: default_person.id)
    assignment = Assignment.register(laptop_id: laptop.id)

    laptop.reload
    assert_equal nil, assignment.destination_person_id
    assert_equal nil, laptop.assignee_id
  end

  test "register bad person" do
    laptop = Laptop.find_by_serial_number!("SHC00000000")
    assert_raise(ActiveRecord::RecordNotFound) do
      Assignment.register(laptop_id: laptop.id, person_id: "hello")
    end
  end

  test "register bad laptop" do
    bad_id = Laptop.maximum(:id) + 1
    assert_raise(ActiveRecord::RecordNotFound) do
      Assignment.register(laptop_id: bad_id, person_id: default_person.id)
    end
  end

  test "register many" do
    assert_difference("Assignment.count", 2) {
      c = Assignment.register_many(["SHC00000000", "SHC00000001"],
                                   person_id: default_person.id,
                                   comment: "foo")
      assert_equal 2, c
   }
    l = Laptop.find_by_serial_number!("SHC00000000")
    assert_equal default_person, l.assignee
    assert_equal "foo", Assignment.first.comment
  end

  test "register many bad laptop" do
    assert_raise(ActiveRecord::RecordNotFound) {
      Assignment.register_many(["SHC"], person_id: default_person.id)
    }
  end

  test "barcode scan" do
    attribs = {
      name: "Name",
      lastname: "Lastname",
      id_document: "123",
    }
    admin_profile = Profile.find_by_internal_tag("root")
    performs = [[root_place.id, admin_profile.id]]
    person_two = Person.register(attribs, performs, "", default_person)

    data = [
      { "person" => default_person.barcode, "laptop" => "SHC00000000" },
      { "person" => person_two.barcode, "laptop" => "SHC00000001"}
    ]
    assert_difference('Assignment.count', 2) {
      c = Assignment.register_barcode_scan(data, comment: "foasdfo")
      assert_equal 2, c
    }

    l = Laptop.find_by_serial_number!("SHC00000000")
    assert_equal default_person, l.assignee
    l = Laptop.find_by_serial_number!("SHC00000001")
    assert_equal person_two, l.assignee

    assert_equal "foasdfo", Assignment.first.comment
  end
end
