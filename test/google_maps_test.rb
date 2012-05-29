require 'test_helper'

class GoogleMaps::GeocoderTest < ActiveSupport::TestCase
  def test_configure__free_account
    GoogleMaps.configure do |maps|
    end
    
    assert_equal false, GoogleMaps.enterprise_account?
  end
  
  def test_configure__enterprise_account
    GoogleMaps.configure do |maps|
      maps.client "foobar"
      maps.sign_key "foobarkey"
      maps.use_enterprise_account
    end
    
    assert_equal "foobar", GoogleMaps.client
    assert GoogleMaps.enterprise_account?
  end
end
