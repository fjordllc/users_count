# frozen_string_literal: true

require 'functions_framework'
require 'net/http'
require 'json'

AUTH_API_URL = 'https://bootcamp.fjord.jp/api/session'
COUNT_API_URL = 'https://bootcamp.fjord.jp/api/admin/count.json'

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

def users_count(token)
  uri = URI.parse(COUNT_API_URL)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  headers = {
    'Content-Type' => 'application/json',
    'Authorization' => "Bearer #{token}"
  }
  response = http.get(uri.path, headers)
  JSON.parse(response.body)['users_count']
end

def main
  token = fetch_token(ENV['LOGIN_NAME'], ENV['PASSWORD'])
  users_count = users_count(token)
  message = "💬 今日の生徒数は#{users_count}人です。"
  post_to_discord(message, ENV['WEBHOOK_URL'])
  'OK'
end

FunctionsFramework.http 'http_users_count' do |_|
  main
end

FunctionsFramework.cloud_event 'users_count' do |_|
  main
end
