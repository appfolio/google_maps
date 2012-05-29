require 'rubygems'
require 'rest_client'
require 'active_support/all'
require 'google_maps/geocoder'

module GoogleMaps
  @@enterprise_account = false
  @@key = nil
  
  def self.configure(&block)
    block.call(self)
  end
  
  def self.client(*args)
    if args.present?
      @@client = args.first
    else
      @@client
    end
  end
  
  def self.sign_key(*args)
    if args.present?
      @@sign_key = args.first
    else
      @@sign_key
    end
  end
    
  def self.use_enterprise_account(*args)
    if args.first.present? && args.first == false
      @@enterprise_account = false
    else
      @@enterprise_account = true
    end
  end
  
  def self.enterprise_account?
    @@enterprise_account || false
  end

end
