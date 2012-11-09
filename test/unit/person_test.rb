# encoding: UTF-8

require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  test "teachers import" do
    # Create Importschool2 first. This way we test importing into an existing
    # place, as well as creating a new place as part of the import.
    pt = PlaceType.find_by_internal_tag!("school")
    attribs = {
      name: "Importschool2",
      place_type_id: pt.id,
      place_id: root_place.id
    }
    importschool2 = Place.register(attribs, [], default_person)

    assert_difference("Person.count", 4) {
      assert_difference("Place.count") {
        Person.import_teachers_xls(fixture_path + "/files/teachers.xls",
                                   root_place.id, default_person)
      }
    }

    # Verify various details of imported data
    importschool = Place.find_by_name!("Importschool")
    assert_equal importschool2, Person.find_by_id_document!("4444").place

    ima = Person.find_by_name!("Ima")
    assert_equal "Teácher", ima.lastname
    assert !ima.id_document.blank?

    daniel = Person.find_by_id_document!("12345")
    assert_equal "Daniel", daniel.name
    assert_equal importschool, daniel.place
    assert_equal 0, daniel.laptops_assigned.count

    ihave = Person.find_by_name!("Ihave")
    assert_equal 1, ihave.laptops_assigned.count
    assert_equal ihave, Laptop.find_by_serial_number!("SHC00000000").assignee
  end

  test "students import" do
    # Create Importschool2 first. This way we test importing into an existing
    # place, as well as creating a new place as part of the import.
    pt = PlaceType.find_by_internal_tag!("school")
    attribs = {
      name: "Importschool2",
      place_type_id: pt.id,
      place_id: root_place.id
    }
    importschool2 = Place.register(attribs, [], default_person)

    assert_difference("Person.count", 4) {
      Person.import_students_xls(fixture_path + "/files/students.xls",
                                   root_place.id, default_person)
    }

    # Verify various details of imported data
    student1 = Person.find_by_name!("Student1")
    assert_equal "67676", student1.id_document
    place = student1.place
    assert_equal "first_grade", place.place_type.internal_tag
    assert_equal "school", place.place.place_type.internal_tag

    student2 = Person.find_by_name!("Student2")
    assert !student2.id_document.blank?
    place = student2.place
    assert_equal "section", place.place_type.internal_tag
    assert_equal "second_grade", place.place.place_type.internal_tag
    assert_equal "school", place.place.place.place_type.internal_tag
    assert_equal "Importschool2", place.place.place.name

    student3 = Person.find_by_name!("Student3")
    place = student3.place
    assert_equal "section", place.place_type.internal_tag
    assert_equal "third_grade", place.place.place_type.internal_tag
    assert_equal "shift", place.place.place.place_type.internal_tag
    assert_equal "school", place.place.place.place.place_type.internal_tag
    assert_equal "Importschool3", place.place.place.place.name

    student4 = Person.find_by_name!("Student4")
    assert_equal 1, student4.laptops_assigned.count
    assert_equal student4, Laptop.find_by_serial_number!("SHC00000000").assignee
  end
end
