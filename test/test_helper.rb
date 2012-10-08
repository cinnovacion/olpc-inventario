ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  def default_person
    Person.find_by_id_document('default')
  end

  def response_result
    dict = JSON.parse(@response.body)
    return dict["result"]
  end

  def sc_save(id, attribs)
    data = { "fields" => attribs }
    if !id.nil?
      data["id"] = id
    end
    post :save, :payload => data.to_json
    assert_response :success
    assert_equal "ok", response_result
  end

  def sc_delete(ids)
    if !ids.respond_to?(:each)
      ids = [ids]
    end

    post :delete, :payload => ids.to_json
    assert_response :success
    assert_equal "ok", response_result
  end

end
