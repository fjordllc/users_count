# frozen_string_literal: true

require 'functions_framework'
require 'net/http'
require 'json'

AUTH_API_URL = 'https://bootcamp.fjord.jp/api/session'
COUNT_API_URL = 'https://bootcamp.fjord.jp/api/admin/count.json'

$logger = nil

def fetch_token(login_name, password)
  response = Net::HTTP.post_form(
    URI.parse(AUTH_API_URL),
    login_name: login_name,
    password: password
  )
  JSON.parse(response.body)['token']
end

def post_to_discord(message, webhook_url)
  uri = URI.parse(webhook_url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  params = { 'content' => message }
  headers = { 'Content-Type' => 'application/json' }
  http.post(uri.path, params.to_json, headers)
end

def main
  logger.info "LOGIN_NAME: #{ENV['LOGIN_NAME']}, WEBHOOK_URL: #{ENV['WEBHOOK_URL']}"
  token = fetch_token(ENV['LOGIN_NAME'], ENV['PASSWORD'])
  body = Net::HTTP.get(
    COUNT_API_URL,
    'Content-Type' => 'application/json',
    'Authorization' => "Bearer #{token}"
  )
  logger.info "body: #{body}"
  message = "💬 今日の生徒数は#{JSON.parse(body)['users_count']}人です。"
  post_to_discord(message, ENV['WEBHOOK_URL'])
  'OK'
end

FunctionsFramework.http 'users_count' do |request|
  $logger = request.logger
  request.logger.info "I received #{request.request_method} from #{request.url}!"
  main
end
