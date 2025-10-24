require 'exp_backoff'
require 'byebug'
require 'httparty'

def call_retry(url, request_body, headers)
  exponential_backoff = ExpBackoff::Retry.new(max_retries: 3, base_interval: 0.5, max_jitter_factor: 0.5)

  result = exponential_backoff.run do
    response = HTTParty.post(url, 
      body: request_body,
      headers: headers,
      timeout: 3
    )

    response
  end
  
  result
end