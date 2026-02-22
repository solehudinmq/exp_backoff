require_relative 'strategies/jitter_strategy'

module ExpBackoff
  module Strategy
    def init_strategy(strategy: :default, maximum_retry: 5, base_delay: 0.5, max_delay: 0.5)
      case strategy
      when :default
        ::ExpBackoff::JitterStrategy.new(maximum_retry: maximum_retry, base_delay: base_delay, max_delay: max_delay)
      else
        raise ArgumentError, "Strategy #{strategy} unknown."
      end
    end
  end
end