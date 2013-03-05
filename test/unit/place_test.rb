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
end
