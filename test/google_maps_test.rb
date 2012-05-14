require 'test_helper'

class GoogleMaps::GeocoderTest < ActiveSupport::TestCase
  def test_configure__free_key
    GoogleMaps.configure do |maps|
      maps.key "foobar"
    end
    
    assert_equal "foobar", GoogleMaps.key
    assert_equal false, GoogleMaps.enterprise_account?
    assert_equal :key, GoogleMaps.key_name
    assert_equal nil, GoogleMaps.geocoder_key_name
  end
  
  def test_configure__enterprise_key
    GoogleMaps.configure do |maps|
      maps.key "foobarenterprise"
      maps.use_enterprise_account
    end
    
    assert_equal "foobarenterprise", GoogleMaps.key
    assert GoogleMaps.enterprise_account?
    assert_equal :client, GoogleMaps.key_name
    assert_equal :clientId, GoogleMaps.geocoder_key_name
  end
  
  
end
