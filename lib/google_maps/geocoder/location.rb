module GoogleMaps
  module Geocoder
    class Location

      LOCATION_TYPES      = [ "ROOFTOP", "RANGE_INTERPOLATED", "GEOMETRIC_CENTER", "APPROXIMATE"]
      TYPES = [
        "street_address",               # indicates a precise street address.
        "route",                        # indicates a named route (such as "US 101").
        "intersection",                 # indicates a major intersection, usually of two major roads.
        "political",                    # indicates a political entity. Usually, this type indicates a polygon of some civil administration.
        "country",                      # indicates the national political entity, and is typically the highest order type returned by the Geocoder.
        "administrative_area_level_1",  # indicates a first-order civil entity below the country level. Within the United States, these administrative levels are states. Not all nations exhibit these administrative levels.
        "administrative_area_level_2",  # indicates a second-order civil entity below the country level. Within the United States, these administrative levels are counties. Not all nations exhibit these administrative levels.
        "administrative_area_level_3",  # indicates a third-order civil entity below the country level. This type indicates a minor civil division. Not all nations exhibit these administrative levels.
        "colloquial_area",              # indicates a commonly-used alternative name for the entity.
        "locality",                     # indicates an incorporated city or town political entity.
        "sublocality",                  # indicates an first-order civil entity below a locality
        "neighborhood",                 # indicates a named neighborhood
        "premise",                      # indicates a named location, usually a building or collection of buildings with a common name
        "subpremise",                   # indicates a first-order entity below a named location, usually a singular building within a collection of buildings with a common name
        "postal_code",                  # indicates a postal code as used to address postal mail within the country.
        "natural_feature",              # indicates a prominent natural feature.
        "airport",                      # indicates an airport.
        "park",                         # indicates a named park.
        "point_of_interest",            # indicates a named point of interest. Typically, these "POI"s are prominent local entities that don't easily fit in another category such as "Empire State Building" or "Statue of Liberty."
        "post_box",                     # indicates a specific postal box.
        "street_number",                # indicates the precise street number.
        "floor",                        # indicates the floor of a building address.
        "room",                         # indicates the room of a building address.
      ]

      ACCURATE_TYPES      = [ "street_address", "premise", "subpremise" ]

      attr_accessor :formatted_address, :location_type, :latitude, :longitude, :types, :address_components

      def initialize(json)
        self.address_components = json['address_components']
        self.formatted_address = json['formatted_address']
        if geometry_json = json['geometry']
          self.location_type = ActiveSupport::StringInquirer.new(geometry_json['location_type'].downcase)

          if geometry_json['location']
            self.latitude  = BigDecimal(geometry_json['location']['lat'].to_s)
            self.longitude = BigDecimal(geometry_json['location']['lng'].to_s)
          end
        end
        self.types = json['types']
      end

      def street_address?
        (ACCURATE_TYPES & self.types).present?
      end

      def method_missing(method_sym, *args, &block)
        if TYPES.include?(method_sym.to_s)
          define_address_component_accessor_for_type(method_sym)
          send(method_sym, args.first)
        else
          super
        end
      end

      def respond_to?(method_sym, include_private = false)
        TYPES.include?(method_sym.to_s) || super
      end

    private

      def define_address_component_accessor_for_type(type_symbol)
        class_eval %Q{
          def #{type_symbol}(arg=nil)
            component = address_components.select { |ac| ac['types'].include?('#{type_symbol.to_s}') }.first
            return nil if component.blank?
            (arg.to_s == 'short') ? component['short_name'] : component['long_name']
          end
        }
      end

    end
  end
end
