require 'test_helper'

class PlaceTypeTest < ActiveSupport::TestCase
  test "name required" do
    assert_raise(ActiveRecord::RecordInvalid) {
      PlaceType.create!(internal_tag: "foo")
    }
  end

  test "tag required" do
    assert_raise(ActiveRecord::RecordInvalid) {
      PlaceType.create!(name: "foo")
    }
  end

  test "unique internal_tag" do
    PlaceType.create!(name: "one", internal_tag: "foo")
    assert_raise(ActiveRecord::RecordInvalid) {
      PlaceType.create!(name: "two", internal_tag: "foo")
    }
  end

  test "create" do
    PlaceType.create!(name: "tname", internal_tag: "ttag")
  end
end
