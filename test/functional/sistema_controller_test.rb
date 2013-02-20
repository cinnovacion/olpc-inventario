require 'test_helper'

class SistemaControllerTest < ActionController::TestCase
  setup do
    @request.session[:user_id] = 1
  end

  test "gui_content" do
    get :gui_content
    assert_response :success
    assert_equal "ok", response_result
  end
end
