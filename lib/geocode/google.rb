module Geocode
  class Google
    
    GEOCODE_URI_BASE = "maps.googleapis.com/maps/api/geocode/json"
    
    def self.locate!(address, options = {})
      options = {
        :ssl => false,
        :address => address,
        :sensor => false
      }.merge(options)

      json = ActiveSupport::JSON.decode RestClient.get(url(options))

      Result.new(json)
    end

    def self.url(options)
      ssl = options.delete(:ssl)
      parameters = []
      options.each do |key, value|
        parameters << "#{key}=#{CGI.escape(value.to_s)}"
      end
      "#{uri_base_path(:ssl => ssl)}?#{parameters.join('&')}"
    end

    def self.uri_base_path(options = {})
      protocol = options[:ssl] ? "https"  : "http"
      "#{protocol}://#{GEOCODE_URI_BASE}"
    end
    
  end
end
