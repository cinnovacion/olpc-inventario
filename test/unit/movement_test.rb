require 'test_helper'

class MovementTest < ActiveSupport::TestCase
  def other_person(id_document = "123")
    attribs = {
      name: "Name",
      lastname: "Lastname",
      id_document: id_document,
    }
    admin_profile = Profile.find_by_internal_tag("root")
    performs = [[root_place.id, admin_profile.id]]
    Person.register(attribs, performs, "", default_person)
  end

  test "register single handout" do
    person_two = other_person
    laptop = Laptop.find_by_serial_number!("SHC00000000")
    assert_equal "deactivated", laptop.status.internal_tag
    Movement.register(
      laptop_id: laptop.id,
      person_id: person_two.id,
      comment: "foo"
    )

    laptop.reload
    assert_equal "activated", laptop.status.internal_tag
    assert_equal person_two, laptop.owner

    # check that default movement type is entrega
    assert_equal "entrega_alumno", Movement.first.movement_type.internal_tag
  end

  test "register return" do
    person_two = other_person
    movement_type = MovementType.find_by_internal_tag!("devolucion")
    laptop = Laptop.find_by_serial_number!("SHC00000000")
    laptop.update_attributes!(status: Status.find_by_internal_tag!("activated"))
    Movement.register(
      laptop_id: laptop.id,
      person_id: person_two.id,
      comment: "foo",
      movement_type_id: movement_type.id,
    )

    laptop.reload
    assert_equal "deactivated", laptop.status.internal_tag
  end

  test "register repair" do
    person_two = other_person
    movement_type = MovementType.find_by_internal_tag!("reparacion")
    laptop = Laptop.find_by_serial_number!("SHC00000000")
    Movement.register(
      laptop_id: laptop.id,
      person_id: person_two.id,
      comment: "foo",
      movement_type_id: movement_type.id,
    )

    laptop.reload
    assert_equal "on_repair", laptop.status.internal_tag
  end

 test "create without laptop" do
    person_two = other_person
    assert_raise(ActiveRecord::RecordNotFound) {
      Movement.register(
        person_id: person_two.id,
        comment: "foo"
      )
    }
  end

  test "create bad laptop" do
    person_two = other_person
    assert_raise(ActiveRecord::RecordNotFound) {
      Movement.register(
        laptop_id: Laptop.maximum(:id) + 1,
        person_id: person_two.id,
        comment: "foo"
      )
    }
  end

  test "create bad person" do
    laptop = Laptop.find_by_serial_number!("SHC00000000")
    assert_raise(ActiveRecord::RecordNotFound) {
      Movement.register(
        laptop_id: laptop.id,
        person_id: Person.maximum(:id) + 1,
        comment: "foo"
      )
    }
  end

  test "create bad movement type" do
    person_two = other_person
    laptop = Laptop.find_by_serial_number!("SHC00000000")
    assert_raise(ActiveRecord::RecordNotFound) {
      Movement.register(
        laptop_id: laptop.id,
        person_id: person_two.id,
        comment: "foo",
        movement_type_id: MovementType.maximum(:id) + 1,
      )
    }
  end

  test "barcode scan" do
    person_two = other_person
    details = [
      {"person" => default_person.barcode, "laptop" => "SHC00000000"},
      {"person" => person_two.barcode, "laptop" => "SHC00000001"},
    ]
    assert_difference('Movement.count', 2) {
      count = Movement.register_barcode_scan(details, comment: "Barcode")
      assert_equal 2, count
    }

    l1 = Laptop.find_by_serial_number!("SHC00000000")
    l2 = Laptop.find_by_serial_number!("SHC00000001")
    assert_equal default_person, l1.owner
    assert_equal person_two, l2.owner
    assert_equal "Barcode", Movement.first.comment
  end

  test "barcode scan missing data skipped" do
    person_two = other_person
    details = [
      {"person" => default_person.barcode, "laptop" => "SHC00000000"},
      {"laptop" => "SHC00000001"}, # no person
      {"person" => person_two.barcode}, # no laptop
      {}, # nothing
    ]
    assert_difference('Movement.count', 1) {
      count = Movement.register_barcode_scan(details, comment: "Barcode")
    }
  end

  test "register handout" do
    person_one = other_person
    l1 = Laptop.find_by_serial_number!("SHC00000000")
    assignment = Assignment.register(laptop_id: l1.id, person_id: person_one.id)
    assert_not_equal l1.owner, person_one

    person_two = other_person("two")
    l2 = Laptop.find_by_serial_number!("SHC00000001")
    assignment = Assignment.register(laptop_id: l2.id, person_id: person_two.id)
    assert_not_equal l2.owner, person_two

    assert_difference('Movement.count', 2) {
      count, not_recognised = Movement.register_handout(
        [l1.serial_number, l2.serial_number],
        comment: "handout")
      assert_equal 2, count
      assert_equal 0, not_recognised.size
    }

    l1.reload
    l2.reload
    assert_equal person_one, l1.owner
    assert_equal person_two, l2.owner
    assert_equal "handout", Movement.first.comment
  end

  test "register handout with unrecognised laptops" do
    person_one = other_person
    l1 = Laptop.find_by_serial_number!("SHC00000000")
    assignment = Assignment.register(laptop_id: l1.id, person_id: person_one.id)

    count, not_recognised = Movement.register_handout(
      ["ABC456", l1.serial_number, "ABC123"],
      comment: "handout")
    assert_equal 1, count
    assert_equal 2, not_recognised.size
    assert not_recognised.include?("ABC123")
    assert not_recognised.include?("ABC456")
  end

  test "register handout of unassigned laptop" do
    l1 = Laptop.find_by_serial_number!("SHC00000000")
    assert_nil l1.assignee
    assert_raise(RuntimeError) {
      Movement.register_handout([l1.serial_number], comment: "handout")
    }
  end

  test "fsm" do
    APP_CONFIG["enable_movement_type_checking"] = true
    person_two = other_person
    laptop = Laptop.find_by_serial_number!("SHC00000000")

    entrega_type = MovementType.find_by_internal_tag!("entrega_alumno")
    return_type = MovementType.find_by_internal_tag!("devolucion")

    Movement.register(laptop_id: laptop.id, person_id: person_two.id,
                      movement_type_id: entrega_type.id)

    # delivery should be followed by return, not another delivery
    assert_raise(RuntimeError) {
      Movement.register(laptop_id: laptop.id, person_id: default_person.id,
                        movement_type_id: entrega_type.id)
    }

    Movement.register(laptop_id: laptop.id, person_id: default_person.id,
                      movement_type_id: return_type.id)

    # return cannot be followed by another return
    assert_raise(RuntimeError) {
      Movement.register(laptop_id: laptop.id, person_id: person_two.id,
                        movement_type_id: return_type.id)
    }
  end

  test "fsm disable" do
    APP_CONFIG["enable_movement_type_checking"] = false
    person_two = other_person
    laptop = Laptop.find_by_serial_number!("SHC00000000")

    entrega_type = MovementType.find_by_internal_tag!("entrega_alumno")

    # check that 2 consecutive handouts are allowed
    Movement.register(laptop_id: laptop.id, person_id: person_two.id,
                      movement_type_id: entrega_type.id)
    Movement.register(laptop_id: laptop.id, person_id: default_person.id,
                      movement_type_id: entrega_type.id)
  end

  test "return" do
    person_two = other_person
    laptop = Laptop.find_by_serial_number!("SHC00000000")
    loan_type = MovementType.find_by_internal_tag!("prestamo")
    return_type = MovementType.find_by_internal_tag!("devolucion")

    m1 = Movement.register(laptop_id: laptop.id, person_id: person_two.id,
                           movement_type_id: loan_type.id,
                           return_date: "2045-01-13")
    assert !m1.returned

    Movement.register(laptop_id: laptop.id, person_id: default_person.id,
                      movement_type_id: return_type.id)
    m1.reload
    assert m1.returned
  end
end
