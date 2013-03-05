require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  setup do
    @request.session[:user_id] = 1
  end

  test "movePeople" do
    place = create_place

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
