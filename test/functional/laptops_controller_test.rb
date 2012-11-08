require 'test_helper'

class LaptopsControllerTest < ActionController::TestCase
  setup do
    @request.session[:user_id] = 1
  end

  test "new single edit" do
    get :new
    assert_response :success
    assert_equal "ok", response_result
  end

  test "save single" do
    attribs = {
      serial_number: "SHC77777777",
      owner_id: default_person.id
    }
    assert_difference('Laptop.count') {
      sc_save(nil, attribs)
    }
  end

  test "edit single" do
    deactivated = Status.find_by_internal_tag!("deactivated")
    activated = Status.find_by_internal_tag!("activated")
    attribs = {
      serial_number: "SHC77777777",
      status_id: deactivated.id,
      owner_id: default_person.id
    }
    sc_save(nil, attribs)

    laptop = Laptop.find_by_serial_number("SHC77777777")
    attribs[:status_id] = activated.id
    sc_save(laptop.id, attribs)

    laptop.reload
    assert_equal activated, laptop.status
  end

  test "batch edit" do
    l1 = default_person.laptops.create!(serial_number: "SHC12345678")
    l2 = default_person.laptops.create!(serial_number: "SHC12345679")
    get :new, ids: [l1.id, l2.id].to_json
    assert_response :success
    assert_equal "ok", response_result

    ids = response_dict["ids"]
    assert_equal 2, ids.length
    assert ids.include?(l1.id)
    assert ids.include?(l2.id)
  end

  test "save batch edit" do
    activated = Status.find_by_internal_tag!("activated")
    deactivated = Status.find_by_internal_tag!("deactivated")
    l1 = default_person.laptops.create!(serial_number: "SHC12345678")
    l2 = default_person.laptops.create!(serial_number: "SHC12345679")
    l3 = default_person.laptops.create!(serial_number: "SHC12345670")
    assert_equal deactivated, l1.status
    assert_equal deactivated, l2.status
    assert_equal deactivated, l3.status

    attribs = { status_id: { updated: true, value: activated.id } }
    sc_save [l1.id, l3.id], attribs

    l1.reload
    l2.reload
    l3.reload
    assert_equal activated, l1.status
    assert_equal deactivated, l2.status
    assert_equal activated, l3.status
  end

  test "import xls" do
    activated = Status.find_by_internal_tag!("activated")
    xo1 = Model.find_by_name!("XO-1")
    attribs = {
      model_id: xo1.id,
      owner_id: default_person.id,
      status_id: activated.id,
    }
    assert_difference('Laptop.count', 5) {
      sc_post :save, nil, attribs,
              uploadfile: fixture_file_upload('/files/laptops.xls')
    }
  end
end
