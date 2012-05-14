require 'rubygems'
require 'bundler'
require 'active_support/all'
require 'pp'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'google_maps'
require 'mocha'

class ActiveSupport::TestCase

  setup :clear_configuration

  def clear_configuration
    GoogleMaps.send :class_variable_set, :@@key, nil
    GoogleMaps.send :class_variable_set, :@@enterprise_account, false
  end

  def castilian_json
    "{\n   \"results\" : [\n      {\n         \"address_components\" : [\n            {\n               \"long_name\" : \"50\",\n               \"short_name\" : \"50\",\n               \"types\" : [ \"street_number\" ]\n            },\n            {\n               \"long_name\" : \"Castilian Dr\",\n               \"short_name\" : \"Castilian Dr\",\n               \"types\" : [ \"route\" ]\n            },\n            {\n               \"long_name\" : \"Goleta\",\n               \"short_name\" : \"Goleta\",\n               \"types\" : [ \"locality\", \"political\" ]\n            },\n            {\n               \"long_name\" : \"Santa Barbara\",\n               \"short_name\" : \"Santa Barbara\",\n               \"types\" : [ \"administrative_area_level_2\", \"political\" ]\n            },\n            {\n               \"long_name\" : \"California\",\n               \"short_name\" : \"CA\",\n               \"types\" : [ \"administrative_area_level_1\", \"political\" ]\n            },\n            {\n               \"long_name\" : \"United States\",\n               \"short_name\" : \"US\",\n               \"types\" : [ \"country\", \"political\" ]\n            },\n            {\n               \"long_name\" : \"93117\",\n               \"short_name\" : \"93117\",\n               \"types\" : [ \"postal_code\" ]\n            }\n         ],\n         \"formatted_address\" : \"50 Castilian Dr, Goleta, CA 93117, USA\",\n         \"geometry\" : {\n            \"location\" : {\n               \"lat\" : 34.43447590,\n               \"lng\" : -119.8639080\n            },\n            \"location_type\" : \"ROOFTOP\",\n            \"viewport\" : {\n               \"northeast\" : {\n                  \"lat\" : 34.43582488029149,\n                  \"lng\" : -119.8625590197085\n               },\n               \"southwest\" : {\n                  \"lat\" : 34.43312691970849,\n                  \"lng\" : -119.8652569802915\n               }\n            }\n         },\n         \"types\" : [ \"street_address\" ]\n      }\n   ],\n   \"status\" : \"OK\"\n}\n"
  end

  def new_york_json
    "{\n   \"results\" : [\n      {\n         \"address_components\" : [\n            {\n               \"long_name\" : \"New York\",\n               \"short_name\" : \"New York\",\n               \"types\" : [ \"locality\", \"political\" ]\n            },\n            {\n               \"long_name\" : \"New York\",\n               \"short_name\" : \"New York\",\n               \"types\" : [ \"administrative_area_level_2\", \"political\" ]\n            },\n            {\n               \"long_name\" : \"New York\",\n               \"short_name\" : \"NY\",\n               \"types\" : [ \"administrative_area_level_1\", \"political\" ]\n            },\n            {\n               \"long_name\" : \"United States\",\n               \"short_name\" : \"US\",\n               \"types\" : [ \"country\", \"political\" ]\n            }\n         ],\n         \"formatted_address\" : \"New York, NY, USA\",\n         \"geometry\" : {\n            \"bounds\" : {\n               \"northeast\" : {\n                  \"lat\" : 40.91524130,\n                  \"lng\" : -73.7002720\n               },\n               \"southwest\" : {\n                  \"lat\" : 40.4959080,\n                  \"lng\" : -74.25908790\n               }\n            },\n            \"location\" : {\n               \"lat\" : 40.71435280,\n               \"lng\" : -74.00597309999999\n            },\n            \"location_type\" : \"APPROXIMATE\",\n            \"viewport\" : {\n               \"northeast\" : {\n                  \"lat\" : 40.84953420,\n                  \"lng\" : -73.74985430\n               },\n               \"southwest\" : {\n                  \"lat\" : 40.57889640,\n                  \"lng\" : -74.26209190\n               }\n            }\n         },\n         \"types\" : [ \"locality\", \"political\" ]\n      },\n      {\n         \"address_components\" : [\n            {\n               \"long_name\" : \"Manhattan\",\n               \"short_name\" : \"Manhattan\",\n               \"types\" : [ \"sublocality\", \"political\" ]\n            },\n            {\n               \"long_name\" : \"New York\",\n               \"short_name\" : \"New York\",\n               \"types\" : [ \"locality\", \"political\" ]\n            },\n            {\n               \"long_name\" : \"New York\",\n               \"short_name\" : \"New York\",\n               \"types\" : [ \"administrative_area_level_2\", \"political\" ]\n            },\n            {\n               \"long_name\" : \"New York\",\n               \"short_name\" : \"NY\",\n               \"types\" : [ \"administrative_area_level_1\", \"political\" ]\n            },\n            {\n               \"long_name\" : \"United States\",\n               \"short_name\" : \"US\",\n               \"types\" : [ \"country\", \"political\" ]\n            }\n         ],\n         \"formatted_address\" : \"Manhattan, New York, NY, USA\",\n         \"geometry\" : {\n            \"bounds\" : {\n               \"northeast\" : {\n                  \"lat\" : 40.8822140,\n                  \"lng\" : -73.9070\n               },\n               \"southwest\" : {\n                  \"lat\" : 40.67954790,\n                  \"lng\" : -74.0472850\n               }\n            },\n            \"location\" : {\n               \"lat\" : 40.78343450,\n               \"lng\" : -73.96624950\n            },\n            \"location_type\" : \"APPROXIMATE\",\n            \"viewport\" : {\n               \"northeast\" : {\n                  \"lat\" : 40.8200450,\n                  \"lng\" : -73.90331300000001\n               },\n               \"southwest\" : {\n                  \"lat\" : 40.6980780,\n                  \"lng\" : -74.03514899999999\n               }\n            }\n         },\n         \"types\" : [ \"sublocality\", \"political\" ]\n      }\n   ],\n   \"status\" : \"OK\"\n}\n"
  end

end
