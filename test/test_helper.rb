ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  def create_place(attribs = {})
    options = {
      name: "Some place",
      description: "Foo",
      place_type_id: PlaceType.first.id,
      place_id: root_place.id,
    }.merge(attribs)
    Place.register(options, [], default_person)
  end

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

  def sc_post_raw(request, ids, attribs, request_attribs = {})
    data = { "fields" => attribs }
    if !ids.nil? and ids.respond_to?(:count)
      data["ids"] = ids
    else
      data["id"] = ids
    end
    request_attribs = { payload: data.to_json }.merge(request_attribs)
    post request, request_attribs
    assert_response :success
  end

  def sc_post(request, ids, attribs, request_attribs = {})
    sc_post_raw(request, ids, attribs, request_attribs)
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
    if response_result == "error"
      puts response_dict["msg"] if !response_dict["msg"].blank?
      puts response_dict["codigo"] if !response_dict["codigo"].blank?
    end

    assert_response :success
    assert_equal "ok", response_result
  end

end
