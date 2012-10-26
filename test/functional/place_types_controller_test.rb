require 'test_helper'

class PlaceTypesControllerTest < ActionController::TestCase
  setup do
    @request.session[:user_id] = 1
  end

  test "new" do
    get :new
    assert_response :success
    assert_equal "ok", response_result
  end

  test "create" do
    assert_difference('PlaceType.count') do
      sc_save(nil, name: "Foo", internal_tag: "bar")
    end
    pt = PlaceType.find_by_name("Foo")
    assert_equal "Foo", pt.name
    assert_equal "bar", pt.internal_tag
  end

  test "delete" do
    sc_save(nil, name: "Foo", internal_tag: "tag")

    assert_difference('PlaceType.count', -1) do
      pt = PlaceType.find_by_name("Foo")
      sc_delete pt.id
    end
  end

  test "edit software version" do
    attribs = { name: "Foo", internal_tag: "tag" }
    sc_save(nil, attribs)

    pt = PlaceType.find_by_name("Foo")
    attribs[:name] = "Bar"
    sc_save(pt.id, attribs)

    pt.reload
    assert_equal "Bar", pt.name
  end
end
