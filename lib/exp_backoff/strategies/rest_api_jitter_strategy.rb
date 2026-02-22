require 'httparty'
require 'json'

require_relative '../utils/logging'
require_relative '../utils/url_validator'

module ExpBackoff
  module RestApi
    class JitterStrategy
      include ::ExpBackoff::Logging
      include ::Cutter::UrlValidator

      HTTP_METHODS = [:GET, :POST, :PUT, :PATCH, :DELETE].freeze

      # method description : retry initialization with exponential backoff jitter.
      # parameters :
      # - maximum_retry : maximum limit for retry, for example : 5.
      # - base_delay : initial value for calculating the exponential backoff time, for example : 0.5.
      # - max_delay : initial value for calculating exponential backoff time with jitter, for example : 0.5.
      def initialize(maximum_retry: 5, base_delay: 0.5, max_delay: 0.5)
        @maximum_retry = maximum_retry
        @base_delay = base_delay
        @max_delay = max_delay
      end

      # method description : the process of performing a retry with exponential with a special jitter to call the rest api.
      # parameters :
      # - options : additional parameters (for the purpose of calling API needs), for example : { url: "https://dummyjson.com/products/1", http_method: :GET, headers: { 'Content-Type': 'application/json' }, body: { title: "Produk Dummy Title 1", description: "Produk Dummy Description 1" }, timeout: 5 }.
      def perform(options: {})
        url, http_method, timeout, headers, body = fetch_request(options: options)

        total_retry = 1

        begin
          result = execute(url: url, http_method: http_method, headers: headers, body: body, timeout: timeout)

          raise "Failure occurred while calling the target api." unless result.success?

          logger.info("Retry #{total_retry} successful.")
          
          result
        rescue => e
          if total_retry < @maximum_retry
            logger.warn("Retry #{total_retry} failed, the process will be retried again.")

            # calculate the time lag with exponential backoff.
            backoff_time = @base_delay * (2 ** total_retry)

            # add jitter (random factor) to prevent 'thundering herd problem'.
            sleep_duration = rand(0..[@max_delay, backoff_time].min)

            sleep(sleep_duration)
            total_retry += 1

            retry
          else
            logger.error("Retries failed, maximum retry limit reached.")
            # retry stopped.
            raise 'Retry has reached maximum attempts.'
          end
        end
      end

      private
        # method description : take data from options parameter.
        # parameters :
        # - http_method : the type of http method used to call the target api, for example : :GET / :POST / :PUT / :PATCH / :DELETE.
        # - options : additional parameters (for the purpose of calling API needs), for example : { url: "https://dummyjson.com/products/1", http_method: :GET, headers: { 'Content-Type': 'application/json' }, body: { title: "Produk Dummy Title 1", description: "Produk Dummy Description 1" }, timeout: 5 }.
        def fetch_request(options:)
          url = options[:url] || ''
          http_method = options[:http_method]

          raise ArgumentError, "Url #{url} is not valid." unless valid_url?(url)
          raise ArgumentError, "Http method #{http_method} is not recognized." unless HTTP_METHODS.include?(http_method)

          body = options[:body] || {}

          raise ArgumentError, "Key parameter with 'body' name is mandatory." if [:POST, :PUT, :PATCH].include?(http_method) && body.empty?

          headers = options[:headers] || {}
          timeout = (options[:timeout] || 10).to_i

          [ url, http_method, timeout, headers, body ]
        end

        # method description : call the destination api based on the selected http method.
        # parameters :
        # - url : destination api url, for example : 'https://dummyjson.com/products/1'.
        # - http_method : the type of http method used to call the target api, for example : :GET / :POST / :PUT / :PATCH / :DELETE.
        # - headers : request headers, for example : { 'Content-Type': 'application/json' }.
        # - body : request body, for example : { title: "Produk Dummy Title 1", description: "Produk Dummy Description 1" }.
        # - timeout : maximum timeout limit in seconds when calling the target api, for example : 10.
        def execute(url:, http_method:, headers: {}, body: {}, timeout: 10)
          options = { timeout: timeout }
          options[:headers] = headers if !headers.empty?
          options[:body] = body.to_json if [:POST, :PUT, :PATCH].include?(http_method)
          
          case http_method
          when :GET
            HTTParty.get(url, options)
          when :POST
            HTTParty.post(url, options)
          when :PUT
            HTTParty.put(url, options)
          when :PATCH
            HTTParty.patch(url, options)
          when :DELETE
            HTTParty.delete(url, options)
          else
            raise "Failed to execute."
          end
        end
    end
  end
end