require 'test_helper'

class AssignmentsControllerTest < ActionController::TestCase
  setup do
    @request.session[:user_id] = 1
  end

  test "new" do
    get :new
    assert_response :success
    assert_equal "ok", response_result
  end

 test "verify_save" do
    laptop = Laptop.find_by_serial_number!("SHC00000000")
    request = {
      laptop_id: laptop.id,
      person_id: default_person.id,
      comment: "foo",
    }

    sc_verify_save(nil, request)
    assert response_dict["obj_data"].include? laptop.serial_number
    assert response_dict["obj_data"].include? "foo"
  end

  test "save" do
    laptop = Laptop.find_by_serial_number!("SHC00000000")
    request = {
      laptop_id: laptop.id,
      person_id: default_person.id,
      comment: "foo",
    }
    assert_difference('Assignment.count') do
      sc_save(nil, request)
    end
  end

  test "can't delete" do
    laptop = Laptop.find_by_serial_number!("SHC00000000")
    request = {
      laptop_id: laptop.id,
      person_id: default_person.id,
      comment: "foo",
    }
    sc_save(nil, request)

    assert_raises(AbstractController::ActionNotFound) do
      sc_delete(Assignment.first.id)
    end
  end

  test "can't edit" do
    laptop = Laptop.find_by_serial_number!("SHC00000000")
    # trying to edit doesn't end up saving the changes
    request = {
      laptop_id: laptop.id,
      person_id: default_person.id,
      comment: "foo",
    }
    sc_save(nil, request)

    first_assignment = Assignment.first
    request[:comment] = "bar"
    sc_save(first_assignment.id, request)
    first_assignment.reload
    assert_equal "foo", first_assignment.comment
  end

  test "details" do
    laptop = Laptop.find_by_serial_number!("SHC00000000")
    request = {
      laptop_id: laptop.id,
      person_id: default_person.id,
      comment: "foo",
    }
    sc_save(nil, request)
    laptop = Laptop.find_by_serial_number("SHC00000000")
    assignment = Assignment.find_by_laptop_id(laptop)
    get :new, id: assignment.id
    assert_response :success
    assert_equal "ok", response_result
  end
 
  test "save_mass_assignment" do
    # assign two laptops to two different people
    attribs = {
      name: "Name",
      lastname: "Lastname",
      id_document: "123",
    }
    admin_profile = Profile.find_by_internal_tag("root")
    performs = [[root_place.id, admin_profile.id]]
    person_two = Person.register(attribs, performs, "", default_person)

    data = [
      { person: default_person.barcode, laptop: "SHC00000000" },
      { person: person_two.barcode, laptop: "SHC00000001"}
    ]

    assert_difference('Assignment.count', 2) do
      post :save_mass_assignment, deliveries: data.to_json
    end
    assert_response :success
    assert_equal "ok", response_result
  end

  test "single_mass_assignment" do
    get :single_mass_assignment
    assert_response :success
    assert_equal "ok", response_result
  end

  test "save_single_mass_assignment" do
    # assign 2 laptops to the same person
    request = {
      person_id: default_person.id,
      laptops: "  SHC00000000\n   \t \n SHC00000001\n"
    }
    assert_difference('Assignment.count', 2) do
      sc_post :save_single_mass_assignment, nil, request
    end
  end
end
