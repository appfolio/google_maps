require 'test_helper'

class GoogleMaps::GeocoderTest < ActiveSupport::TestCase

  def test_locate__castilian
    GoogleMaps::Geocoder.expects(:url).with(:address => "50 Castilian Drive, Goleta, CA", :ssl => false, :sensor => false).returns(:url)
    RestClient.expects(:get).with(:url).returns(castilian_json)
    result = GoogleMaps::Geocoder.locate!("50 Castilian Drive, Goleta, CA")

    assert result.status.ok?

    assert_equal 1, result.count
    location = result.first
    assert_equal "50 Castilian Dr, Goleta, CA 93117, USA", location.formatted_address
    assert_equal BigDecimal.new("34.4344759"), location.latitude
    assert_equal BigDecimal.new("-119.863908"), location.longitude
    assert location.street_address?
    assert location.location_type.rooftop?
    assert_equal ['street_address'], location.types
  end

  def test_locate__new_york
    GoogleMaps::Geocoder.expects(:url).with(:address => "New York", :ssl => false, :sensor => false).returns(:url)
    RestClient.expects(:get).with(:url).returns(new_york_json)
    result = GoogleMaps::Geocoder.locate!("New York")
    assert result.status.ok?

    assert_equal 2, result.count

    ny_ny = result.first
    assert_equal "New York, NY, USA", ny_ny.formatted_address
    assert_equal BigDecimal.new("40.7143528"), ny_ny.latitude
    assert_equal BigDecimal.new("-74.0059731"), ny_ny.longitude
    assert !ny_ny.street_address?
    assert ny_ny.location_type.approximate?
    assert_equal ["locality", "political"], ny_ny.types

    manhattan_ny = result.last
    assert_equal "Manhattan, New York, NY, USA", manhattan_ny.formatted_address
    assert_equal BigDecimal.new("40.7834345"), manhattan_ny.latitude
    assert_equal BigDecimal.new("-73.9662495"), manhattan_ny.longitude
    assert !manhattan_ny.street_address?
    assert !manhattan_ny.location_type.rooftop?
    assert manhattan_ny.location_type.approximate?
    assert_equal ["sublocality", "political"], manhattan_ny.types
  end
  
  def test_locate__error
    error = StandardError.new("there was an error doing that")
    
    GoogleMaps::Geocoder.expects(:url).returns(:url)
    RestClient.expects(:get).with(:url).raises(error)
    error_raised = false
    begin
      GoogleMaps::Geocoder.locate!("New York")
    rescue => e
      error_raised = true
      assert e.is_a?(GoogleMaps::GeocodeFailed), e.class.name
      assert_equal "Failed while geocoding 'New York': StandardError: there was an error doing that", e.message
    end
    
    assert error_raised
  end
  

  def test_url_base_path
    assert_equal "http://#{GoogleMaps::Geocoder::URI_BASE}", GoogleMaps::Geocoder.uri_base_path
    assert_equal "http://#{GoogleMaps::Geocoder::URI_BASE}", GoogleMaps::Geocoder.uri_base_path(:ssl => false)
    assert_equal "https://#{GoogleMaps::Geocoder::URI_BASE}", GoogleMaps::Geocoder.uri_base_path(:ssl => true)
  end

  def test_url
    assert_url_parts expected_url("address=50+Castilian+Drive%2C+Goleta%2C+CA&sensor=true"), GoogleMaps::Geocoder.url(ordered_hash(:sensor => true, :ssl => false, :address => "50 Castilian Drive, Goleta, CA"))
    assert_url_parts expected_url("address=50+Castilian+Drive%2C+Goleta%2C+CA&sensor=false", true), GoogleMaps::Geocoder.url(ordered_hash(:sensor => false, :ssl => true, :address => "50 Castilian Drive, Goleta, CA"))
  end

  def test_url__with_client_id
    GoogleMaps.key "bar"
    GoogleMaps.use_enterprise_account
    assert_url_parts expected_url("address=A&sensor=false&clientId=foo"), GoogleMaps::Geocoder.url(ordered_hash(:sensor => false, :address => "A", :clientId => 'foo'))
    assert_url_parts expected_url("address=A&sensor=false&clientId=bar"), GoogleMaps::Geocoder.url(ordered_hash(:sensor => false, :address => "A"))
  end

  private

  def assert_url_parts(expected, actual)
    expected_base_url, expected_url_params = expected.split('?')
    actual_base_url, actual_url_params = actual.split('?')
    assert_equal expected_base_url, actual_base_url

    expected_params = url_params(expected_url_params)
    actual_params   = url_params(actual_url_params)
    assert_equal expected_params, actual_params
  end

  def url_params(params)
    {}.tap do |hash|
      params.split('&').each do |param|
        hash[param.split('=').first]  = param.split('=').last
      end
    end
  end

  def expected_url(parameters, ssl = false)
    "http#{'s' if ssl}://#{GoogleMaps::Geocoder::URI_BASE}?#{parameters}"
  end

  def ordered_hash(hash)
    oh = ActiveSupport::OrderedHash.new
    oh[:address] = hash[:address] if hash[:address]
    oh[:sensor] = hash[:sensor] if hash[:sensor]
    oh[:clientId] = hash[:clientId] if hash[:clientId]
    oh.merge!(hash)
    oh
  end
end