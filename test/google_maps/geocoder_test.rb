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

  def test_all_encompassing_json
    GoogleMaps::Geocoder.expects(:url).with(:address => "80 Leonard Street, New York, NY 10013", :ssl => false, :sensor => false).returns(:url)

    RestClient.expects(:get).with(:url).returns(all_encompassing_json)
    results = GoogleMaps::Geocoder.locate!("80 Leonard Street, New York, NY 10013")

    assert results.status.ok?

    result = results.first
    assert_equal "80", result.street_number
    assert_equal "Leonard Street", result.route
    assert_equal "Lower Manhattan", result.neighborhood
    assert_equal "Manhattan", result.sublocality
    assert_equal "New York", result.locality
    assert_equal "New York", result.administrative_area_level_1
    assert_equal "New York", result.administrative_area_level_2
    assert_equal "New York", result.administrative_area_level_3
    assert_equal "United States", result.country
    assert_equal "10013", result.postal_code
    assert_equal "Premise Long", result.premise
    assert_equal "Subpremise Long", result.subpremise
    assert_equal "Pretty Mountain Long", result.natural_feature
    assert_equal "La Guardia", result.airport
    assert_equal "Central Park", result.park
    assert_equal "Statue of Liberty", result.point_of_interest
    assert_equal "272510 Long", result.post_box
    assert_equal "13.5", result.floor
    assert_equal nil, result.room

    assert_equal "80", result.street_number(:short)
    assert_equal "Leonard St", result.route(:short)
    assert_equal "Lower Manhattan", result.neighborhood(:short)
    assert_equal "Manhattan", result.sublocality(:short)
    assert_equal "New York", result.locality(:short)
    assert_equal "NY", result.administrative_area_level_1(:short)
    assert_equal "New York", result.administrative_area_level_2(:short)
    assert_equal "New York", result.administrative_area_level_3(:short)
    assert_equal "US", result.country(:short)
    assert_equal "10013", result.postal_code(:short)
    assert_equal "Premise Short", result.premise(:short)
    assert_equal "Subpremise Short", result.subpremise(:short)
    assert_equal "Pretty Mountain Short", result.natural_feature(:short)
    assert_equal "La Guardia", result.airport(:short)
    assert_equal "Central Park", result.park(:short)
    assert_equal "Statue of Liberty", result.point_of_interest(:short)
    assert_equal "272510 Short", result.post_box(:short)
    assert_equal "13.5", result.floor(:short)
    assert_equal nil, result.room(:short)

    assert result.respond_to?(:street_number)
    assert result.respond_to?(:street_address?)

    assert_raise NoMethodError do
      result.this_field_is_not_present_in_address_components
    end
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
    assert_equal "http://#{GoogleMaps::Geocoder::URI_DOMAIN}#{GoogleMaps::Geocoder::URI_BASE}", GoogleMaps::Geocoder.uri_base_path
    assert_equal "http://#{GoogleMaps::Geocoder::URI_DOMAIN}#{GoogleMaps::Geocoder::URI_BASE}", GoogleMaps::Geocoder.uri_base_path(:ssl => false)
    assert_equal "https://#{GoogleMaps::Geocoder::URI_DOMAIN}#{GoogleMaps::Geocoder::URI_BASE}", GoogleMaps::Geocoder.uri_base_path(:ssl => true)
  end

  def test_url
    assert_url_parts expected_url("address=50+Castilian+Drive%2C+Goleta%2C+CA&sensor=true"), GoogleMaps::Geocoder.url(ordered_hash(:sensor => true, :ssl => false, :address => "50 Castilian Drive, Goleta, CA"))
    assert_url_parts expected_url("address=50+Castilian+Drive%2C+Goleta%2C+CA&sensor=false", true), GoogleMaps::Geocoder.url(ordered_hash(:sensor => false, :ssl => true, :address => "50 Castilian Drive, Goleta, CA"))
  end

  def test_url__with_enterprise_account
    GoogleMaps.client "clientID"
    GoogleMaps.key "vNIXE0xscrmjlyV-12Nj_BvUPaw="
    GoogleMaps.use_enterprise_account
    assert_equal expected_url("address=New+York&sensor=false&client=clientID&signature=KrU1TzVQM7Ur0i8i7K3huiw3MsA="), GoogleMaps::Geocoder.url(ordered_hash(:address => "New York", :sensor => false))
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
    "http#{'s' if ssl}://#{GoogleMaps::Geocoder::URI_DOMAIN}#{GoogleMaps::Geocoder::URI_BASE}?#{parameters}"
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
