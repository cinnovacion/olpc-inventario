require 'test_helper'

class ConnectionEventsControllerTest < ActionController::TestCase
  setup do
    @request.session[:user_id] = 1
  end

  test "cant save" do
    assert_raises(AbstractController::ActionNotFound) do
      sc_save(nil, laptop_id: Laptop.first.id, ip_address: "1.2.3.4")
    end
  end

  test "cant delete" do
    event = Laptop.first.connection_events.create!()
    assert_raises(AbstractController::ActionNotFound) do
      sc_delete(event.id)
    end
  end

  test "report event" do
    assert_difference('ConnectionEvent.count') do
      post :report, laptop: Laptop.first.serial_number,
                          ip_address: "1.2.3.4", free_space: 678,
                          stolen: false, connected_at: "2009-01-02 03:04:05"
      assert_response :success
    end
    event = ConnectionEvent.first
    assert_equal Laptop.first, event.laptop
    assert_equal "1.2.3.4", event.ip_address
    assert_equal 678, event.free_space
    assert_equal Time.utc(2009, 1, 2, 3, 4, 5), event.connected_at
    assert !event.stolen
    assert_nil event.vhash
  end

  test "duplicate reports successful but ignored" do
    attribs = {
      laptop: Laptop.first.serial_number,
      ip_address: "1.2.3.4",
      connected_at: "2011-01-01 01:02:03",
    }

    assert_difference('ConnectionEvent.count') do
      post :report, attribs
      assert_response :success
      post :report, attribs
      assert_response :success
    end
  end

  test "details" do
    laptop = Laptop.first
    event = laptop.connection_events.create!(stolen: false,
                                             ip_address: "1.2.3.4",
                                             free_space: 5678)
    get :new, id: event.id
    assert_response :success
    assert_equal "ok", response_result
  end
end
