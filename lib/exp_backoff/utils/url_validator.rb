require 'uri'

module Cutter
  module UrlValidator
    def valid_url?(string)
      uri = URI.parse(string)
      uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    rescue URI::InvalidURIError
      false
    end
  end
end