require 'test_helper'

class SoftwareVersionTest < ActiveSupport::TestCase
  test "Name required" do
    assert_raise(ActiveRecord::RecordInvalid) {
      SoftwareVersion.create!(:vhash => "bbcd2c7ef7dc30e68f06a28ddaa23120fb587808d397e46f5b0970095d3d99c6")
    }
  end

  test "Empty hash ok" do
    SoftwareVersion.create!(:name => "no hash")
  end

  test "Hash uniqueness" do
    SoftwareVersion.create!(:name => "one", :vhash => "bbcd2c7ef7dc30e68f06a28ddaa23120fb587808d397e46f5b0970095d3d99c6")
    assert_raise(ActiveRecord::RecordInvalid) {
      SoftwareVersion.create!(:name => "two", :vhash => "bbcd2c7ef7dc30e68f06a28ddaa23120fb587808d397e46f5b0970095d3d99c6")
    }
  end

  test "Bad hash" do
    assert_raise(ActiveRecord::RecordInvalid) {
      SoftwareVersion.create!(:name => "foo", :vhash => "bad")
    }
  end
end
