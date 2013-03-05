require 'test_helper'

class PlacesControllerTest < ActionController::TestCase
  setup do
    @request.session[:user_id] = 1
  end
end
