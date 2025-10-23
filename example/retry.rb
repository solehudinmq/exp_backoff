require 'exp_backoff'
require 'byebug'
require 'httparty'

def call_retry(url, request_body, headers)
  exponential_backoff = ExpBackoff::Retry.new(max_retries: 3, base_interval: 0.5, max_jitter_factor: 0.5)

  # httparty
  result = exponential_backoff.run do
    response = HTTParty.post(url, 
      body: request_body,
      headers: headers,
      timeout: 3
    )

    status_code = response.code

    if [503, 504, 429].include?(status_code)
      raise ExpBackoff::HttpError.new(response.parsed_response["error"], status_code)
    elsif status_code.to_s.start_with?('2')
      response
    end
  end
  
  result
end