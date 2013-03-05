require 'test_helper'

class PerformTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "move_people" do
    src_place = create_place(name: "Source")
    dst_place = create_place(name: "Dest")

    attribs = {
      name: "Name",
      lastname: "Lastname",
      id_document: "123",
    }
    admin_profile = Profile.find_by_internal_tag("root")
    performs = [[src_place.id, admin_profile.id]]
    person_one = Person.register(attribs, performs, "", default_person)

    attribs[:id_document] = "456"
    person_two = Person.register(attribs, performs, "", default_person)

    attribs[:id_document] = "789"
    person_three = Person.register(attribs, performs, "", default_person)

    Perform.move_people([person_one.id, person_three.id], src_place, dst_place, 
                        default_person, true)
    person_one.reload
    person_two.reload
    person_three.reload

    # Check requested performs were updated
    assert_equal dst_place, person_one.place
    assert_equal src_place, person_two.place
    assert_equal dst_place, person_three.place

    # Check that the added comment mentions source, dest and the responsible
    # person
    assert_match /Source/, person_one.notes
    assert_match /Dest/, person_one.notes
    assert_match /Default/, person_one.notes
  end

end
