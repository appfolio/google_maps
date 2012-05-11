module Geocode
  class Location
    LOCATION_TYPES      = [ "ROOFTOP", "RANGE_INTERPOLATED", "GEOMETRIC_CENTER", "APPROXIMATE"]
    ACCURATE_TYPES      = [ "street_address", "premise", "subpremise" ]

    attr_accessor :formatted_address, :location_type, :latitude, :longitude, :types

    def initialize(json)
      self.formatted_address = json['formatted_address']
      if geometry_json = json['geometry']
        self.location_type = ActiveSupport::StringInquirer.new(geometry_json['location_type'].downcase)

        if geometry_json['location']
          self.latitude  = BigDecimal(geometry_json['location']['lat'].to_s)
          self.longitude = BigDecimal(geometry_json['location']['lng'].to_s)
        end
      end

      self.types         = json['types']
    end


    def street_address?
      (ACCURATE_TYPES & self.types).present?
    end

  end
end