require 'test_helper'

class DataImportControllerTest < ActionController::TestCase
  setup do
    @request.session[:user_id] = 1
  end

  test "initialdata" do
    get :initialData
    assert_response :success
    assert_equal "ok", response_result
  end

  test "import students" do
    before = Person.count
    post :import, {
      place_id: root_place.id,
      model: "students",
      data: fixture_file_upload('/files/students.xls')
    }

    assert_response :success
    assert_equal "ok", response_result
    assert before != Person.count
  end

  test "import teachers" do
    before = Person.count
    post :import, {
      place_id: root_place.id,
      model: "teachers",
      data: fixture_file_upload('/files/teachers.xls')
    }

    assert_response :success
    assert_equal "ok", response_result
    assert before != Person.count
  end

  test "import uuids" do
    l1 = default_person.laptops.create!(serial_number: "SHC20000001")
    l2 = default_person.laptops.create!(serial_number: "SHC20000003")
    post :import, {
      place_id: root_place.id,
      model: "uuids",
      data: fixture_file_upload('/files/uuids.txt')
    }

    assert_response :success
    assert_equal "ok", response_result
    l1.reload
    assert !l1.uuid.blank?
  end
end
