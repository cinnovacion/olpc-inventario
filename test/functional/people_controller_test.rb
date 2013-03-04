require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  setup do
    @request.session[:user_id] = 1
  end

  test "movePeople" do
    attribs = { name: "My place", description: "foo", place_type_id: PlaceType.first.id, place_id: root_place.id }
    place = Place.register(attribs, [], default_person)

    attribs = {
      people_ids: [default_person.id],
      src_place_id: root_place.id,
      dst_place_id: place.id,
      add_comment: true
    }
    post :movePeople, payload: attribs.to_json
    assert_response :success
    assert_equal "ok", response_result
  end
end
