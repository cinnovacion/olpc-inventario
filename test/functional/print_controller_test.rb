require 'test_helper'

class PrintControllerTest < ActionController::TestCase
  setup do
    @request.session[:user_id] = 1
  end

  test "barcodes" do
    attribs = {
      places: [root_place.id],
      profile_filter: "developer",
      laptop_filter: ["with"],
    }

    post :barcodes, print_params: attribs.to_json
    assert_response :success
  end

  test "statuses_distribution" do
    post :statuses_distribution, print_params: [root_place.id].to_json
    assert_response :success
  end
end
