# frozen_string_literal: true

require 'functions_framework'
require 'base64'
require 'net/http'
require 'json'

def users_count
  uri = URI.parse(ENV['REDASH_URL'])
  response = Net::HTTP.get_response(uri)
  json = JSON.parse(response.body)
  json['query_result']['data']['rows'][0]['users_count']
end

MESSAGES = {
  'users-count' => "💬 今日の生徒数は#{users_count}人です。"
}.freeze

WEBHOOK_URLS = {
  'users-count' => ENV['WEBHOOK_URL_MENTOR']
}.freeze

FunctionsFramework.cloud_event 'reminder_sub' do |event|
  payload = Base64.decode64 event.data['message']['data']
  message = MESSAGES[payload]
  uri = URI.parse(WEBHOOK_URLS[payload])
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  params = { 'content' => message }
  headers = { 'Content-Type' => 'application/json' }
  http.post(uri.path, params.to_json, headers)
end
