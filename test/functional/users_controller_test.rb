require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @request.session[:user_id] = 1
  end

  def create_teacher
    attribs = {
      name: "Foo",
      id_document: "foo"
    }
    profile = Profile.find_by_internal_tag("teacher")
    performs = [[root_place.id, profile.id]]
    person = Person.register(attribs, performs, "", default_person)
  end

  test "new" do
    get :new
    assert_response :success
    assert_equal "ok", response_result
  end

  test "create" do
    person = create_teacher
    assert_difference('User.count') do
      user = { person_id: person.id, usuario: "foo", password: "12345", password2: "12345" }
      sc_save(nil, user)
    end
  end

  test "password mismatch" do
    person = create_teacher
    user = { person_id: person.id, usuario: "foo", password: "12345", password2: "different" }
    sc_post_raw(:save, nil, user)
    assert_equal "error", response_result
  end

  test "update password" do
    person = create_teacher
    user = User.create!(usuario: "foo", password: "123456", person: person)
    sc_save(user.id, password: "12345", password2: "12345")
  end

  test "update no password change" do
    person = create_teacher
    user = User.create!(usuario: "foo", password: "123456", person: person)
    orig_clave = user.clave

    sc_save(user.id, usuario: "asdf")
    sc_save(user.id, usuario: "asdf", password: "", password2: "")

    user.reload
    assert_equal "asdf", user.usuario
    assert_equal orig_clave, user.clave
  end

  test "delete" do
    person = create_teacher
    user = User.create!(usuario: "foo", password: "123456", person: person)
    assert_difference('User.count', -1) do
      sc_delete(user.id)
    end
  end

  test "no create permissions" do
    person = create_teacher
    user = User.create!(usuario: "foo", password: "123456", person: person)

    profile = Profile.find_by_internal_tag("root")
    performs = [[root_place.id, profile.id]]
    attribs = {
      name: "Foo",
      id_document: "foo123"
    }
    Person.register(attribs, performs, "", default_person)

    @request.session[:user_id] = user.id
    sc_post_raw :save, nil, {
      person_id: person.id, usuario: "foo2", password: "12345"
    }
    assert_equal "error", response_result
  end

  test "no update permissions" do
    person = create_teacher
    user = User.create!(usuario: "foo", password: "123456", person: person)

    @request.session[:user_id] = user.id
    sc_post_raw :save, default_person.user.id, usuario: "foo7"
    assert_equal "error", response_result
  end

  test "no delete permissions" do
    person = create_teacher
    user = User.create!(usuario: "foo", password: "123456", person: person)

    @request.session[:user_id] = user.id
    user = User.create!(usuario: "foo2", password: "123456", person: person)
    post :delete, payload: [default_person.user.id].to_json
    assert_equal "error", response_result
  end
end
