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

  def root_place
    Place.find_by_name("Rootland")
  end

  def response_dict
    JSON.parse(@response.body)
  end

  def response_result
    return response_dict["result"]
  end

  def sc_post(request, id, attribs)
    data = { "fields" => attribs }
    if !id.nil?
      data["id"] = id
    end
    post request, :payload => data.to_json
    assert_response :success
    if response_result == "error"
      puts response_dict["msg"] if !response_dict["msg"].blank?
      puts response_dict["codigo"] if !response_dict["codigo"].blank?
    end
    assert_equal "ok", response_result
  end

  def sc_verify_save(id, attribs)
    sc_post :verify_save, id, attribs
  end

  def sc_save(id, attribs)
    sc_post :save, id, attribs
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
