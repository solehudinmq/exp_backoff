# app.rb
require 'sinatra'
require 'json'
require 'byebug'

require_relative 'order'

before do
  content_type :json
end

# create data order success
post '/orders' do
  begin
    request_body = JSON.parse(request.body.read)

    # save request data to redis queue
    order = Order.new(request_body)
    
    if order.save
      { order_id: order.id, message: 'success' }.to_json
    else
      status 400
      return { error: order.errors.message }.to_json
    end
  rescue => e
    status 500
    return { error: e.message }.to_json
  end
end

# server errors simulations
post '/simulation_server_problems' do
  status 503
  return { error: 'The server is having problems.' }.to_json
end

# unauthorized simulations
post '/simulation_unauthorized' do
  status 401
  return { error: 'Unauthorized' }.to_json
end

# get data orders
get '/orders' do
  begin
    orders = Order.all

    { count: orders.size, orders: orders }.to_json
  rescue => e
    status 500
    return { error: e.message }.to_json
  end
end

# ====== run producer ======
# 1. open terminal
# 2. cd your_project
# 3. bundle install
# 4. bundle exec ruby app.rb
# 5. create data order
# curl --location 'http://localhost:4567/orders' \
# --header 'Content-Type: application/json' \
# --data '{
#     "user_id": 1,
#     "total_amount": 30000
# }'
# 6. get data order
# curl --location 'http://localhost:4567/orders'
