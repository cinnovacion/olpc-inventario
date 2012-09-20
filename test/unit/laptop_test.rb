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
end
