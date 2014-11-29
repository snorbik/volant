require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  setup do
    sign_in users(:john)
  end

  test "should get index" do
    get :index, format: 'html'
    assert_response :success
  end

end
