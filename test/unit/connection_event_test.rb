require 'test_helper'

class ConnectionEventTest < ActiveSupport::TestCase
  test "create" do
    event = Laptop.first.connection_events.create!()
    assert_not_nil event.connected_at
    Laptop.first.connection_events.create!(stolen: FALSE,
                                           ip_address: "1.2.3.4",
                                           free_space: 5678,
                                           connected_at: "2012-01-03 13:55:01")
  end

  test "time formats" do
    Laptop.first.connection_events.create!(connected_at: "2013-01-28T21:52:31.822307")
    event = ConnectionEvent.first
    assert_equal Time.utc(2013, 1, 28, 21, 52, 31), event.connected_at
    event.destroy

    Laptop.first.connection_events.create!(connected_at: "2013-01-28T21:52:37")
    event = ConnectionEvent.first
    assert_equal Time.utc(2013, 1, 28, 21, 52, 37), event.connected_at
  end

  test "duplicates rejected" do
    Laptop.first.connection_events.create!(connected_at: "2012-01-01 01:01:01")
    assert_raises(ActiveRecord::RecordNotUnique) {
      Laptop.first.connection_events.create!(connected_at: "2012-01-01 01:01:01")
    }
  end

  test "laptop required" do
    assert_raises(ActiveRecord::RecordInvalid) {
      ConnectionEvent.create!(free_space: 4)
    }
  end

  test "bad software version" do
    assert_raises(ActiveRecord::RecordInvalid) {
      Laptop.first.connection_events.create!(vhash: "asdf")
    }
  end

  test "resolve software version" do
    vhash = "bbcd2c7ef7dc30e68f06a28ddaa23120fb587808d397e46f5b0970095d3d99c6"
    ver = SoftwareVersion.create!(name: "foo", vhash: vhash)
    event = Laptop.first.connection_events.create!(vhash: vhash)
    assert_equal ver, event.software_version
  end
end
