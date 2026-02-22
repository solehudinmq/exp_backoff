# frozen_string_literal: true

require_relative "exp_backoff/version"
require_relative 'exp_backoff/strategy'

module ExpBackoff
  class Jitter
    include ::ExpBackoff::Strategy

    def initialize(strategy: :default, maximum_retry: 5, base_delay: 0.5, max_delay: 0.5)
      @strategy = init_strategy(strategy: strategy, maximum_retry: maximum_retry, base_delay: base_delay, max_delay: max_delay)
    end

    def perform(**options)
      @strategy.perform(options: options) do
        yield
      end
    end
  end
end
