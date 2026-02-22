# frozen_string_literal: true

require_relative "exp_backoff/version"
require_relative 'exp_backoff/strategy'

module ExpBackoff
  class Jitter
    include ::ExpBackoff::Strategy

    # method description : retry initialization with exponential backoff jitter.
    # parameters :
    # - strategy : retry strategy options, for example : :default / :rest_api.
    # - maximum_retry : maximum limit for retry, for example : 5.
    # - base_delay : initial value for calculating the exponential backoff time, for example : 0.5.
    # - max_delay : initial value for calculating exponential backoff time with jitter, for example : 0.5.
    def initialize(strategy: :default, maximum_retry: 5, base_delay: 0.5, max_delay: 0.5)
      @strategy = init_strategy(strategy: strategy, maximum_retry: maximum_retry, base_delay: base_delay, max_delay: max_delay)
    end

    # method description : the process of performing a retry with exponential backoff with jitter.
    # parameters :
    # - options : additional parameters (for the purpose of calling API needs), for example : {} / { url: "https://dummyjson.com/products/1", http_method: :GET, headers: { 'Content-Type': 'application/json' }, body: { title: "Produk Dummy Title 1", description: "Produk Dummy Description 1" }, timeout: 5 }.
    def perform(**options)
      @strategy.perform(options: options) do
        yield
      end
    end
  end
end
