require 'test_helper'
require 'mocha'

class Geocode::GoogleTest < Test::Unit::TestCase

  def test_locate__castilian
    RestClient.expects(:get).with(expected_url("sensor=false&address=50+Castilian+Drive%2C+Goleta%2C+CA")).returns(castilian_json)
    result = Geocode::Google.locate!("50 Castilian Drive, Goleta, CA")

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
    RestClient.expects(:get).with(expected_url("sensor=false&address=New+York")).returns(new_york_json)
    result = Geocode::Google.locate!("New York")
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

  def test_url_base_path
    assert_equal "http://#{Geocode::Google::GEOCODE_URI_BASE}", Geocode::Google.uri_base_path
    assert_equal "http://#{Geocode::Google::GEOCODE_URI_BASE}", Geocode::Google.uri_base_path(:ssl => false)
    assert_equal "https://#{Geocode::Google::GEOCODE_URI_BASE}", Geocode::Google.uri_base_path(:ssl => true)
  end

  def test_url

    assert_equal expected_url("sensor=true&address=50+Castilian+Drive%2C+Goleta%2C+CA"), Geocode::Google.url(ordered_hash(:sensor => true, :ssl => false, :address => "50 Castilian Drive, Goleta, CA"))
    assert_equal expected_url("sensor=false&address=50+Castilian+Drive%2C+Goleta%2C+CA", true), Geocode::Google.url(ordered_hash(:sensor => false, :ssl => true, :address => "50 Castilian Drive, Goleta, CA"))
  end

  private

  def expected_url(parameters, ssl = false)
    "http#{'s' if ssl}://#{Geocode::Google::GEOCODE_URI_BASE}?#{parameters}"
  end

  def ordered_hash(hash)
    oh = ActiveSupport::OrderedHash.new
    oh.merge!(hash)
    oh
  end
end