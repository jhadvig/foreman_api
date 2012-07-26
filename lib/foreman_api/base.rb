require 'rest_client'
require 'oauth'
require 'json'
require 'foreman_api/rest_client_oauth'

module ForemanApi
  class Base
    attr_reader :client

    def initialize(config = ForemanApi.client_config)
      @client = RestClient::Resource.new(config[:base_url],
                                         :user     => config[:username],
                                         :password => config[:password],
                                         :oauth    => config[:oauth],
                                         :headers  => { :content_type => 'application/json',
                                                        :accept       => 'application/json' })
    end

    def call(method, path, payload = nil)
      a, *_ = [method, payload ? payload.to_json : nil].compact
      ret  = client[path].send(a)
      data = begin
        JSON.parse(ret.body)
      rescue JSON::ParserError
        ret.body
      end
      return data, ret
    end

    def validate_params!(options, valid_keys)
      return unless options.is_a?(Hash)
      invalid_keys = options.keys - (valid_keys.is_a?(Hash) ? valid_keys.keys : valid_keys)
      raise ArgumentError, "Invalid keys: #{invalid_keys.join(", ")}" unless invalid_keys.empty?

      if valid_keys.is_a? Hash
        valid_keys.each do |key, keys|
          if options[key]
            validate_params!(options[key], keys)
          end
        end
      end
    end

  end
end
