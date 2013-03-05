require 'test_helper'

class PlaceTest < ActiveSupport::TestCase
  test "register" do
    pt = PlaceType.first
    parent = Place.first
    attribs = { name: "My place", description: "foo", place_type_id: pt.id, place_id: parent.id }
    place = Place.register(attribs, [], default_person)
    assert_equal "foo", place.description
    assert_equal parent, place.place
    assert_equal pt, place.place_type
  end

  test "register_update" do
    place = create_place
    place.register_update({ description: "bar" }, [], default_person)
    assert_equal "bar", place.description
    place.reload
    assert_equal "bar", place.description
  end

  test "laptops_uuids" do
    activated = Status.find_by_internal_tag!("activated")
    stolen = Status.find_by_internal_tag!("stolen")
    deactivated = Status.find_by_internal_tag!("deactivated")

    place = create_place
    sub_place = create_place(name: "subplace", place_id: place.id)
    place.reload
    another_place = create_place

    person1 = register_person(id_document: "1", place: place)
    person2 = register_person(id_document: "2", place: place)
    person3 = register_person(id_document: "3", place: place)
    person4 = register_person(id_document: "4", place: place)
    person5 = register_person(id_document: "5", place: sub_place)
    person6 = register_person(id_document: "6", place: place)
    person7 = register_person(id_document: "7", place: place)
    person8 = register_person(id_document: "8", place: another_place)
    person9 = register_person(id_document: "9", place: root_place)

    # person1 has two laptops in hands
    person1.laptops.create!(serial_number: "SHC10000001", uuid: "ABC1",
                            status: activated)
    person1.laptops.create!(serial_number: "SHC10000002", uuid: "ABC2",
                            status: activated)

    # person2 has a laptop in hands
    person2.laptops.create!(serial_number: "SHC10000003", uuid: "ABC3",
                            status: activated)

    # person3 has a laptop assigned
    l = default_person.laptops.create!(serial_number: "SHC10000004",
                                       uuid: "ABC4", status: activated)
    Assignment.register(laptop_id: l.id, person_id: person3.id)

    # person4 has a laptop without UUID
    person4.laptops.create!(serial_number: "SHC10000005", status: activated)

    # person5 is in a sub place with a laptop assigned and in hands
    l = person5.laptops.create!(serial_number: "SHC10000006", uuid: "ABC5",
                                status: activated)
    Assignment.register(laptop_id: l.id, person_id: person5.id)

    # person6 has a deactivated laptop
    person6.laptops.create!(serial_number: "SHC10000007", uuid: "ABC7",
                            status: deactivated)

    # person7 has a stolen laptop
    person7.laptops.create!(serial_number: "SHC10000008", uuid: "ABC8",
                            status: stolen)

    # person8 has a laptop but is in an unrelated place
    person8.laptops.create!(serial_number: "SHC10000009", uuid: "ABC9",
                            status: activated)

    # person9 acts like a warehouse. 4 laptops in hands:
    #  1. no assignation
    #  2. assigned to person1 (in the place in question)
    #  3. assigned to person8 (unrelated place)
    #  4. assigned to self
    person9.laptops.create!(serial_number: "SHC20000001", uuid: "ABC1",
                            status: activated)
    l = person9.laptops.create!(serial_number: "SHC20000002", uuid: "ABC1")
    Assignment.register(laptop_id: l.id, person_id: person1.id)
    l = person9.laptops.create!(serial_number: "SHC20000003", uuid: "ABC1")
    Assignment.register(laptop_id: l.id, person_id: person8.id)
    l = person9.laptops.create!(serial_number: "SHC20000004", uuid: "ABC1")
    Assignment.register(laptop_id: l.id, person_id: person9.id)

    # ancestor user has a laptop as well
    default_person.laptops.create!(serial_number: "SHC12345678", uuid: "xxx",
                                   status: activated)

    ret = place.laptops_uuids
    assert_not_nil ret.detect {|l| l[:serial_number] == "SHC10000001" }
    assert_not_nil ret.detect {|l| l[:serial_number] == "SHC10000002" }
    assert_not_nil ret.detect {|l| l[:serial_number] == "SHC10000003" }
    assert_not_nil ret.detect {|l| l[:serial_number] == "SHC10000004" }
    assert_nil ret.detect {|l| l[:serial_number] == "SHC10000005" }
    assert_not_nil ret.detect {|l| l[:serial_number] == "SHC10000006" }
    assert_nil ret.detect {|l| l[:serial_number] == "SHC10000007" }
    assert_nil ret.detect {|l| l[:serial_number] == "SHC10000008" }
    assert_nil ret.detect {|l| l[:serial_number] == "SHC10000009" }

    # ancestor logic testing
    assert_not_nil ret.detect {|l| l[:serial_number] == "SHC12345678" }
    assert_not_nil ret.detect {|l| l[:serial_number] == "SHC20000001" }
    assert_not_nil ret.detect {|l| l[:serial_number] == "SHC20000002" }
    assert_nil ret.detect {|l| l[:serial_number] == "SHC20000003" }
    assert_not_nil ret.detect {|l| l[:serial_number] == "SHC20000004" }

    # all entries have uuid
    assert_nil ret.detect {|l| l[:uuid].blank? }
  end
end
