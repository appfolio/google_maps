require 'base64'
require 'openssl'
require 'google_maps/geocoder/result'
require 'google_maps/geocoder/location'

module GoogleMaps
  class GeocodeFailed < StandardError
    def initialize(location, original_error)
      super "Failed while geocoding '#{location}': #{original_error.class.name}: #{original_error.message}"
    end
  end
  
  module Geocoder

    URI_DOMAIN = "maps.googleapis.com"
    URI_BASE   = "/maps/api/geocode/json"

    def self.locate!(address, options = { })
      options = {
        :ssl     => false,
        :address => address,
        :sensor  => false
      }.merge(options)

      json = ActiveSupport::JSON.decode RestClient.get(url(options))
      Geocoder::Result.new(json)
    rescue => e
      raise GeocodeFailed.new(address, e)
    end

    def self.url(options)
      ssl      = options.delete(:ssl)
      # for enterprise account
      client   = options.delete(:client) || ::GoogleMaps.client
      key = options.delete(:key) || ::GoogleMaps.key  

      parameters = []
      options.each do |k, v|
        parameters << "#{k}=#{CGI.escape(v.to_s)}"
      end
      
      if ::GoogleMaps.enterprise_account? && client && key
        parameters << "client=#{CGI.escape(client)}"
        sign_str = "#{URI_BASE}?#{parameters.join('&')}"
        sha1 = OpenSSL::Digest::Digest.new('sha1')
        binary_key = Base64.decode64(key.tr('-_','+/'))
        binary_signature = OpenSSL::HMAC.digest(sha1, binary_key, sign_str)
        signature = Base64.encode64(binary_signature).tr('+/','-_').strip
        parameters << "signature=#{signature}"
      end
      
      "#{uri_base_path(:ssl => ssl)}?#{parameters.join('&')}"
    end

    def self.uri_base_path(options = { })
      protocol = options[:ssl] ? "https" : "http"
      "#{protocol}://#{URI_DOMAIN}#{URI_BASE}"
    end
  end
end
