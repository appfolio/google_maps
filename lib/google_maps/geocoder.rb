require 'google_maps/geocoder/result'
require 'google_maps/geocoder/location'

module GoogleMaps
  module Geocoder

    URI_BASE = "maps.googleapis.com/maps/api/geocode/json"

    def self.locate!(address, options = { })
      options = {
        :ssl    => false,
        :address => address,
        :sensor => false
      }.merge(options)

      json = ActiveSupport::JSON.decode RestClient.get(url(options))

      Geocoder::Result.new(json)
    end

    def self.url(options)
      ssl = options.delete(:ssl)

      if !options[:clientId] && ::GoogleMaps.enterprise_account
        options.merge!(::GoogleMaps.geocoder_key_name => ::GoogleMaps.key)
      end

      parameters = []
      options.each do |key, value|
        parameters << "#{key}=#{CGI.escape(value.to_s)}"
      end
      "#{uri_base_path(:ssl => ssl)}?#{parameters.join('&')}"
    end

    def self.uri_base_path(options = { })
      protocol = options[:ssl] ? "https" : "http"
      "#{protocol}://#{URI_BASE}"
    end

  end
end