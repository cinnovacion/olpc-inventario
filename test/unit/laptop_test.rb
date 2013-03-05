require 'test_helper'

class LaptopTest < ActiveSupport::TestCase
  test "serial number upcase" do
    l = default_person.laptops.create!(:serial_number => "shc12345678")
    assert_equal l.serial_number, "SHC12345678"
  end

  test "default state is deactivated" do
    l = default_person.laptops.create!(:serial_number => "SHC12345678")
    assert_equal l.status.internal_tag, "deactivated"
  end

  test "serial number is required" do
    assert_raises(ActiveRecord::RecordInvalid) {
      default_person.laptops.create!()
    }
  end

  test "serial number unique" do
    default_person.laptops.create!(:serial_number => "SHC12345678")
    assert_raises(ActiveRecord::RecordInvalid) {
      default_person.laptops.create!(:serial_number => "SHC12345678")
    }
  end

  test "getBlackList" do
    l1 = default_person.laptops.create!(:serial_number => "SHC12345678")
    l2 = default_person.laptops.create!(:serial_number => "SHC12345679")
    l1.update_attributes!(status: Status.stolen)
    blacklist = Laptop.getBlackList

    l1_found = false
    l2_found = false
    blacklist.each { |entry|
      l1_found = true if entry[:serial_number] == l1.serial_number
      l2_found = true if entry[:serial_number] == l2.serial_number
    }
    assert l1_found
    assert !l2_found
  end

  test "import_xls" do
    model = Model.first
    assert_difference("Laptop.count", 5) {
      Laptop.import_xls(fixture_path + "/files/laptops.xls",
                        arrived_at: Time.now, model_id: model.id,
                        status_id: Status.deactivated.id,
                        owner_id: default_person.id) 
    }

    shipment = Shipment.find_by_shipment_number!(12345)
    l = Laptop.find_by_serial_number!("SHC1000002")
    assert_equal model, l.model
    assert_equal Status.deactivated, l.status
    assert_equal l.shipment, shipment
  end

  test "import uuids" do
    l1 = default_person.laptops.create!(:serial_number => "SHC20000001")
    l2 = default_person.laptops.create!(:serial_number => "SHC20000002")
    l3 = default_person.laptops.create!(:serial_number => "SHC20000003")
    Laptop.import_uuids_from_csv(fixture_path + "/files/uuids.txt")

    l1.reload
    l2.reload
    l3.reload
    assert_equal "CCFA84AD-6C1A-BE3C-C427-A0FC8B523632", l1.uuid
    assert_nil l2.uuid
    assert_equal "CCFA84AD-6C1A-BE3C-C427-A0FC8B523631", l3.uuid
  end
end
