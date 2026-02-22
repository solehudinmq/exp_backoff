require 'json'

require_relative '../utils/logging'

module ExpBackoff
  class JitterStrategy
    include ::ExpBackoff::Logging

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

    # method description : the process of performing a retry with exponential backoff with jitter.
    # parameters :
    # - options : additional parameters (unused for this class), for example : {}.
    def perform(options: {})
      total_retry = 1

      begin
        yield

        logger.info("Retry #{total_retry} successful.")
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
  end
end