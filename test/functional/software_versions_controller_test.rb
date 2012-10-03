require 'test_helper'

class SoftwareVersionsControllerTest < ActionController::TestCase
  setup do
    @software_version = software_versions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:software_versions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create software_version" do
    assert_difference('SoftwareVersion.count') do
      post :create, :software_version => @software_version.attributes
    end

    assert_redirected_to software_version_path(assigns(:software_version))
  end

  test "should show software_version" do
    get :show, :id => @software_version.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @software_version.to_param
    assert_response :success
  end

  test "should update software_version" do
    put :update, :id => @software_version.to_param, :software_version => @software_version.attributes
    assert_redirected_to software_version_path(assigns(:software_version))
  end

  test "should destroy software_version" do
    assert_difference('SoftwareVersion.count', -1) do
      delete :destroy, :id => @software_version.to_param
    end

    assert_redirected_to software_versions_path
  end
end
