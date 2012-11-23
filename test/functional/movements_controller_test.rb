require 'test_helper'

class MovementsControllerTest < ActionController::TestCase
  setup do
    @request.session[:user_id] = 1
  end

  def create_other_person(id_document = "123")
    attribs = {
      name: "Name",
      lastname: "Lastname",
      id_document: id_document,
    }
    admin_profile = Profile.find_by_internal_tag("root")
    performs = [[root_place.id, admin_profile.id]]
    Person.register(attribs, performs, "", default_person)
  end

  test "new" do
    get :new
    assert_response :success
    assert_equal "ok", response_result
  end

  test "details" do
    laptop = Laptop.find_by_serial_number!("SHC00000000")
    m = Movement.register(laptop_id: laptop.id, person_id: default_person.id)

    get :new, id: m.id
    assert_response :success
    assert_equal "ok", response_result
  end

  test "verify_save" do
    person = create_other_person
    delivery = MovementType.find_by_internal_tag!("entrega_alumno")
    laptop = Laptop.find_by_serial_number!("SHC00000000")
    request = {
      laptop_id: laptop.id,
      person_id: person.id,
      movement_type_id: delivery.id,
      comment: "foo",
    }

    sc_verify_save(nil, request)
    assert response_dict["obj_data"].include? laptop.serial_number
    assert response_dict["obj_data"].include? "foo"
  end

  test "save" do
    person = create_other_person
    laptop = Laptop.find_by_serial_number!("SHC00000000")
    assert_not_equal laptop.owner, person

    delivery = MovementType.find_by_internal_tag!("entrega_alumno")
    request = {
      laptop_id: laptop.id,
      person_id: person.id,
      movement_type_id: delivery.id,
      comment: "foo",
    }
    assert_difference('Movement.count') do
      sc_save(nil, request)
    end

    laptop.reload
    assert_equal person, laptop.owner
  end

  test "can't delete" do
    person = create_other_person
    laptop = Laptop.find_by_serial_number!("SHC00000000")
    delivery = MovementType.find_by_internal_tag!("entrega_alumno")
    request = {
      laptop_id: laptop.id,
      person_id: person.id,
      movement_type_id: delivery.id,
      comment: "foo",
    }
    sc_save(nil, request)

    assert_raises(AbstractController::ActionNotFound) do
      sc_delete(Movement.first.id)
    end
  end

  test "can't edit" do
    # trying to edit doesn't end up saving the changes
    person = create_other_person
    laptop = Laptop.find_by_serial_number!("SHC00000000")
    delivery = MovementType.find_by_internal_tag!("entrega_alumno")
    request = {
      laptop_id: laptop.id,
      person_id: person.id,
      movement_type_id: delivery.id,
      comment: "foo",
    }
    sc_save(nil, request)

    first_movement = Movement.first
    request[:comment] = "bar"

    sc_post_raw(:save, first_movement.id, request)
    assert_equal "error", response_result

    first_movement.reload
    assert_equal "foo", first_movement.comment
  end

  test "save_mass_movement" do
    # deliver two laptops to two different people
    delivery = MovementType.find_by_internal_tag!("entrega_alumno")
    person_one = create_other_person("123")
    person_two = create_other_person("456")

    data = [
      { person: person_one.barcode, laptop: "SHC00000000" },
      { person: person_two.barcode, laptop: "SHC00000001"}
    ]

    assert_difference('Movement.count', 2) do
      post :save_mass_movement, deliveries: data.to_json, movement_type: delivery.id
    end
    assert_response :success
    assert_equal "ok", response_result
  end

  test "register_handout" do
  end

  test "single_mass_delivery" do
    get :single_mass_delivery
    assert_response :success
    assert_equal "ok", response_result
  end

  test "save_single_mass_delivery" do
    # assign 2 laptops to the same person
    delivery = MovementType.find_by_internal_tag!("entrega_alumno")
    person = create_other_person
    request = {
      person_id: person.id,
      laptops: "  SHC00000000\n   \t \n SHC00000001\n",
      movement_type_id: delivery.id,
    }
    assert_difference('Movement.count', 2) do
      sc_post :save_single_mass_delivery, nil, request
    end
  end
end
