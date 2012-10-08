require 'test_helper'

class SoftwareVersionsControllerTest < ActionController::TestCase
  setup do
    @request.session[:user_id] = 1
  end

  test "new" do
    get :new
    assert_response :success
    assert_equal "ok", response_result
  end

  test "create software version" do
    model = Model.first
    assert_difference('SoftwareVersion.count') do
      version = { name: "Foo", model_id: model.id, description: "foo" }
      sc_save(nil, version)
    end
    version = SoftwareVersion.find_by_name("Foo")
    assert_equal model, version.model
    assert_equal "foo", version.description
  end

  test "delete software version" do
    model = Model.first
    version = { name: "Foo", model_id: model.id, description: "foo" }
    sc_save(nil, version)

    assert_difference('SoftwareVersion.count', -1) do
      version = SoftwareVersion.find_by_name("Foo")
      sc_delete version.id
    end
  end

  test "edit software version" do
    model = Model.first
    attribs = { name: "Foo", model_id: model.id, description: "foo" }
    sc_save(nil, attribs)

    version = SoftwareVersion.find_by_name("Foo")
    attribs[:name] = "Bar"
    sc_save(version.id, attribs)

    version.reload
    assert_equal "Bar", version.name
  end

end
