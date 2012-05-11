module Geocode
  class Result
    include Enumerable

    attr_accessor :status

    STATUS_CODES        = [ "OK", "ZERO_RESULTS", "OVER_QUERY_LIMIT", "REQUEST_DENIED", "INVALID_REQUEST" ]

    def initialize(json = {})
      self.status = ActiveSupport::StringInquirer.new(json['status'].downcase)
      @locations = (json['results'] || []).map { |result| Location.new(result) }
    end

    def all
      @locations
    end

    def each(&block)
      all.each &block
    end

    def [](index)
      all[index]
    end

    def last
      all.last
    end
  end
end
