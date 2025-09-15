# frozen_string_literal: true

require_relative "exp_backoff/version"

module ExpBackoff
  class Error < StandardError; end
  # Your code goes here...

  class Retry
    # the meaning of each parameter :
    # max_retries = the maximum number of retries the system will perform.
    # base_interval = this is the base value to start the exponential backoff calculation.
    # max_jitter_factor = a random factor added to the wait time to prevent multiple clients from retrying at the same time.
    def initialize(max_retries: nil, base_interval: nil, max_jitter_factor: nil)
      @max_retries = max_retries || 5
      @base_interval = base_interval || 0.5
      @max_jitter_factor = max_jitter_factor || 0.5
    end

    def run
      retries = 1

      # do a retry.
      while retries <= @max_retries
        begin
          # call the relevant service.
          result = yield

          return { status: 'success', data: result }
        rescue => e
          # if the number of failures < max failures then provide a waiting time with exponential backoff.
          if retries < @max_retries
            # Calculate the time lag with exponential backoff.
            backoff_time = @base_interval * (2 ** retries)

            # Add jitter (random factor) to prevent 'thundering herd problem'.
            jitter = backoff_time * (rand - 0.5) * @max_jitter_factor
            sleep_duration = backoff_time + jitter

            sleep(sleep_duration)
            retries += 1
          else
            return { status: 'fail', error_message: 'The number of retry failures has reached the maximum.' }
          end
        end
      end
    end
  end
end
