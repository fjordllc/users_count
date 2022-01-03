# frozen_string_literal: true

require 'functions_framework'
require 'fjord_boot_camp'

def main
  client = FjordBootCamp::Client.new
  client.authenticate(ENV['LOGIN_NAME'], ENV['PASSWORD'])
  puts ENV['LOGIN_NAME']
  puts ENV['PASSWORD']
  message = "💬 今日の生徒数は#{client.users_count}人です。"

  discord = FjordBootCamp::Discord.new
  discord.post(message, ENV['WEBHOOK_URL'])
end

FunctionsFramework.http 'http_users_count' do |_|
  puts 'aaa'
  main
  'OK'
end

FunctionsFramework.cloud_event 'users_count' do |_|
  main
end
