require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "username required" do
    person = Person.create!(name: "Foo", id_document: "foo")
    assert_raise(ActiveRecord::RecordInvalid) {
      User.create!(password: "foobar", person: person)
    }
  end

  test "password required" do
    person = Person.create!(name: "Foo", id_document: "foo")
    assert_raise(ActiveRecord::RecordInvalid) {
      User.create!(usuario: "foobar", person: person)
    }
  end

  test "password min length" do
    person = Person.create!(name: "Foo", id_document: "foo")
    assert_raise(ActiveRecord::RecordInvalid) {
      User.create!(usuario: "foobar", password: "123", person: person)
    }
  end

  test "create" do
    person = Person.create!(name: "Foo", id_document: "foo")
    User.create!(usuario: "foobar", password: "123456", person: person)
  end

  test "create bad person" do
    person_id = Person.maximum(:id) + 1
    assert_raise(ActiveRecord::InvalidForeignKey) {
      User.create!(usuario: "foobar", password: "123456", person_id: person_id)
    }
  end

  test "update" do
    person = Person.create!(name: "Foo", id_document: "foo")
    u = User.create!(usuario: "foobar", password: "123456", person: person)
    u.update_attributes!(usuario: "changed")
    u.reload
    assert_equal "changed", u.usuario
  end
end
