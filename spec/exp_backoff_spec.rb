# frozen_string_literal: true

RSpec.describe ExpBackoff do
  it "has a version number" do
    expect(ExpBackoff::VERSION).not_to be nil
  end

  context "Strategy :default" do
    it "retry successful" do
      exp_back = ::ExpBackoff::Jitter.new(strategy: :default, maximum_retry: 3, base_delay: 0.3, max_delay: 0.3)

      result = exp_back.perform do
        1 + 1
      end

      expect(result).to be 2
    end

    it "retry failed" do
      exp_back = ::ExpBackoff::Jitter.new(strategy: :default, maximum_retry: 3, base_delay: 0.3, max_delay: 0.3)

      begin
        result = exp_back.perform do
          1 + 'a'
        end
      rescue => e
        expect(e.message).to eq('Retry has reached maximum attempts.')
      end 
    end
  end

  context "Strategy :rest_api" do
    it 'retry successful for method :GET' do
      exp_back = ::ExpBackoff::Jitter.new(strategy: :rest_api, maximum_retry: 3, base_delay: 0.3, max_delay: 0.3)
      
      result = exp_back.perform(url: "https://dummyjson.com/products/1", http_method: :GET, headers: { 'Content-Type': 'application/json' }, timeout: 5 )

      expect(result.code).to be 200
    end

    it 'retry successful for method :POST' do
      exp_back = ::ExpBackoff::Jitter.new(strategy: :rest_api, maximum_retry: 3, base_delay: 0.3, max_delay: 0.3)
      
      result = exp_back.perform(url: "https://dummyjson.com/products/add", http_method: :POST, headers: { 'Content-Type': 'application/json' }, body: { title: "Produk Dummy Title 1", description: "Produk Dummy Description 1" }, timeout: 5 )

      expect(result.code).to be 201
    end

    it 'retry successful for method :PUT' do
      exp_back = ::ExpBackoff::Jitter.new(strategy: :rest_api, maximum_retry: 3, base_delay: 0.3, max_delay: 0.3)
      
      result = exp_back.perform(url: "https://dummyjson.com/products/1", http_method: :PUT, headers: { 'Content-Type': 'application/json' }, body: { title: "Produk Dummy Title 1 - PUT", description: "Produk Dummy Description 1 - PUT" }, timeout: 5 )

      expect(result.code).to be 200
    end

    it 'retry successful for method :PATCH' do
      exp_back = ::ExpBackoff::Jitter.new(strategy: :rest_api, maximum_retry: 3, base_delay: 0.3, max_delay: 0.3)
      
      result = exp_back.perform(url: "https://dummyjson.com/products/1", http_method: :PATCH, headers: { 'Content-Type': 'application/json' }, body: { title: "Produk Dummy Title 1 - PATCH" }, timeout: 5 )

      expect(result.code).to be 200
    end

    it 'retry successful for method :DELETE' do
      exp_back = ::ExpBackoff::Jitter.new(strategy: :rest_api, maximum_retry: 3, base_delay: 0.3, max_delay: 0.3)
      
      result = exp_back.perform(url: "https://dummyjson.com/products/1", http_method: :DELETE, headers: { 'Content-Type': 'application/json' }, timeout: 5 )

      expect(result.code).to be 200
    end

    it 'retry failed' do
      exp_back = ::ExpBackoff::Jitter.new(strategy: :rest_api, maximum_retry: 3, base_delay: 0.3, max_delay: 0.3)

      begin
        result = exp_back.perform(url: "https://dummyjson.com/products/1?delay=3000", http_method: :GET, headers: { 'Content-Type': 'application/json' }, timeout: 2 )
      rescue => e
        expect(e.message).to eq('Retry has reached maximum attempts.')
      end 
    end
  end
end
