require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  setup do
    @request.session[:user_id] = 1
  end

  test "people_laptops form" do
    get :people_laptops
    assert_response :success
    assert_equal "ok", response_result
  end
end
