# frozen_string_literal: true

RSpec.describe ExpBackoff do
  def success_simulation
    { message: "Data received successfully!" }
  end

  def timeout_simulation
    raise("Timeout!")
  end

  it "has a version number" do
    expect(ExpBackoff::VERSION).not_to be nil
  end

  it "retry successful on first try, with default parameters" do
    eb = ExpBackoff::Retry.new
    result = eb.run do 
      success_simulation
    end

    expect(result[:status]).to be('success')
    expect(result[:data][:message]).to be('Data received successfully!')
  end

  it "retry successful on first try, with external parameters" do
    eb = ExpBackoff::Retry.new(max_retries: 3, base_interval: 0.5, max_jitter_factor: 0.5)
    result = eb.run do 
      success_simulation
    end

    expect(result[:status]).to be('success')
    expect(result[:data][:message]).to be('Data received successfully!')
  end

  it 'retry failed on first try, with default parameters' do
    eb = ExpBackoff::Retry.new
    result = eb.run do 
      timeout_simulation
    end

    expect(result[:status]).to be('fail')
    expect(result[:error_message]).to be('The number of retry failures has reached the maximum.')
  end

  it 'retry failed on first try, with external parameters' do
    eb = ExpBackoff::Retry.new(max_retries: 3, base_interval: 0.5, max_jitter_factor: 0.5)
    result = eb.run do 
      timeout_simulation
    end

    expect(result[:status]).to be('fail')
    expect(result[:error_message]).to be('The number of retry failures has reached the maximum.')
  end
end
