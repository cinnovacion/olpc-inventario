require 'test_helper'

class SchoolInfoTest < ActiveSupport::TestCase
  test "place required" do
    assert_raise(ActiveRecord::RecordInvalid) {
      SchoolInfo.create!(server_hostname: "foo", lease_duration: 2)
    }
  end

  test "new with expiry" do
    pt = PlaceType.first
    attribs = { name: "School", place_type_id: pt.id, place_id: root_place.id }
    school = Place.register(attribs, [], default_person)

    info = SchoolInfo.create!(
      place_id: school.id,
      lease_expiry: "2099-01-02",
      server_hostname: "myserver.com",
      wan_ip_address: "1.2.3.4",
      wan_netmask: "255.255.255.0",
      wan_gateway: "1.2.3.1"
    )
    assert_equal("myserver.com", info.server_hostname)
    assert_equal(nil, info.lease_duration)
    assert_equal(Date.new(2099, 1, 2), info.lease_expiry)
    info.lease_info
  end

  test "new with duration" do
    pt = PlaceType.first
    attribs = { name: "School", place_type_id: pt.id, place_id: root_place.id }
    school = Place.register(attribs, [], default_person)

    info = SchoolInfo.create!(
      place_id: school.id,
      lease_duration: 3,
      server_hostname: "myserver.com",
      wan_ip_address: "1.2.3.4",
      wan_netmask: "255.255.255.0",
      wan_gateway: "1.2.3.1"
    )
    assert_equal("myserver.com", info.server_hostname)
    assert_equal(3, info.lease_duration)
    assert_equal(nil, info.lease_expiry)
    info.lease_info
  end

  test "new with both" do
    pt = PlaceType.first
    attribs = { name: "School", place_type_id: pt.id, place_id: root_place.id }
    school = Place.register(attribs, [], default_person)

    assert_raises(ActiveRecord::RecordInvalid) {
      info = SchoolInfo.create!(
        place_id: school.id,
        lease_duration: 3,
        lease_expiry: "2055-04-05",
        server_hostname: "myserver.com",
        wan_ip_address: "1.2.3.4",
        wan_netmask: "255.255.255.0",
        wan_gateway: "1.2.3.1"
      )
    }
  end
end
