require 'test_helper'

class SchoolInfosControllerTest < ActionController::TestCase
  setup do
    @request.session[:user_id] = 1
  end

  test "new" do
    get :new
    assert_response :success
    assert_equal "ok", response_result
  end

  test "create" do
    attribs = { server_hostname: "myserver.com", place_id: root_place.id }
    assert_difference('SchoolInfo.count') do
      sc_save(nil, attribs)
    end
    info = SchoolInfo.find_by_server_hostname!("myserver.com")
    assert_equal(root_place.id, info.place_id)
  end

  test "edit" do
    attribs = { server_hostname: "myserver.com", place_id: root_place.id }
    sc_save(nil, attribs)

    info = SchoolInfo.find_by_server_hostname!("myserver.com")

    attribs = { server_hostname: "otherserver.com", wan_ip_address: "1.2.3.4" }
    sc_save(info.id, attribs)

    info.reload
    assert_equal("otherserver.com", info.server_hostname)
    assert_equal("1.2.3.4", info.wan_ip_address)
  end

  test "delete" do
    attribs = { server_hostname: "myserver.com", place_id: root_place.id }
    sc_save(nil, attribs)

    info = SchoolInfo.find_by_server_hostname!("myserver.com")
    assert_difference('SchoolInfo.count', -1) do
      sc_delete info.id
    end
  end
end
