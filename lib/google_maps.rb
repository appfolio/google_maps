require 'rubygems'
require 'rest_client'
require 'active_support/all'
require 'google_maps/geocoder'

module GoogleMaps
  mattr_accessor :key, :enterprise_account

  def self.key_name
    enterprise_account ? "client" : "key"
  end

  def self.geocoder_key_name
    "clientId" if enterprise_account
  end
end
