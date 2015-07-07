require 'faraday'
require 'faraday_middleware'
require 'smtp_lw/client/messages'

module SmtpLw
  class Client
    attr_accessor :api_token, :api_endpoint, :per_page, :timeout
    include SmtpLw::Client::Messages

    def initialize(options={})
      SmtpLw::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", options[key] || SmtpLw.instance_variable_get(:"@#{key}"))
      end
    end

    # Make a HTTP GET request
    #
    # @param uri [String] The path, relative to {#api_endpoint}
    # @param options [Hash] Query and header params for request
    # @return [Faraday::Response]
    def get(uri, options={})
      options = paginate(options)
      response = connection.get uri, options
    end

    # Make a HTTP POST request
    #
    # @param uri [String] The path, relative to {#api_endpoint}
    # @param options [Hash] Body and header params for request
    # @return [Faraday::Response]
    def post(uri, options={})
      response = connection.post uri, options
    end

    # Make a HTTP PUT request
    #
    # @param uri [String] The path, relative to {#api_endpoint}
    # @param options [Hash] Body and header params for request
    # @return [Faraday::Response]
    def put(uri, options={})
      response = connection.put uri, options
    end

    def next_page(raw)
      next_uri = raw["links"]["next"]
      return nil unless next_uri
      response = connection.get next_uri
      return response.body
    end

    private

    def paginate(options)
      page = options[:page] || 1
      per = options[:per] || SmtpLw.per_page
      options.merge(page: page, per: per)
    end

    def connection
      conn = Faraday.new(url: SmtpLw.api_endpoint, ssl: {verify: false}) do |c|
        c.request :json
        c.response :json
        c.adapter Faraday.default_adapter

      end
      conn.headers['User-Agent'] = "SMTP LW Ruby API Client v#{VERSION}"
      conn.headers['x-auth-token'] = SmtpLw.api_token
      conn
    end

  end
end
