require 'test_helper'

class PlacesControllerTest < ActionController::TestCase
  setup do
    @request.session[:user_id] = 1
  end

  test "schools_leases" do
    post :schools_leases
    assert_response :success
  end
end
