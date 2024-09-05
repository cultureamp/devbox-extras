#!/usr/bin/env ruby
# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'
require 'fileutils'

CLIENT_ID = ENV['GITHUB_APP_CLIENT_ID']

def parse_response(response)
  case response
  when Net::HTTPOK, Net::HTTPCreated
    JSON.parse(response.body)
  when Net::HTTPUnauthorized
    puts 'You are not authorized. Run the `login` command.'
    exit 1
  else
    puts "An error occurred: #{response.code} #{response.message}"
    exit 1
  end
end

def request_device_code
  uri = URI('https://github.com/login/device/code')
  parameters = URI.encode_www_form('client_id' => CLIENT_ID)
  headers = { 'Accept' => 'application/json' }

  response = Net::HTTP.post(uri, parameters, headers)
  parse_response(response)
end

def request_token(device_code)
  uri = URI('https://github.com/login/oauth/access_token')
  parameters = URI.encode_www_form({
                                     'client_id' => CLIENT_ID,
                                     'device_code' => device_code,
                                     'grant_type' => 'urn:ietf:params:oauth:grant-type:device_code'
                                   })
  headers = { 'Accept' => 'application/json' }
  response = Net::HTTP.post(uri, parameters, headers)
  parse_response(response)
end
# rubocop:disable Metrics/MethodLength

def poll_for_token(device_code, interval)
  loop do
    response = request_token(device_code)
    error, access_token, refresh_token = response.values_at('error', 'access_token', 'refresh_token')

    if error
      case error
      when 'authorization_pending'
        # The user has not yet entered the code.
        # Wait, then poll again.
        sleep interval
        next
      when 'slow_down'
        # The app polled too fast.
        # Wait for the interval plus 5 seconds, then poll again.
        sleep interval + 5
        next
      when 'expired_token'
        # The `device_code` expired, and the process needs to restart.
        puts 'The device code has expired. Please run `login` again.'
        exit 1
      when 'access_denied'
        # The user cancelled the process. Stop polling.
        puts 'Login cancelled by user.'
        exit 1
      else
        puts response
        exit 1
      end
    else
      set_tokens(access_token, refresh_token)
    end
    break
  end
end
# rubocop:enable Metrics/MethodLength

APP_SERVICE_NAME = 'com.cultureamp.hotel'
APP_ACCOUNT_NAME = 'github.app'

def set_tokens(access_token, refresh_token)
  add_keychain_item(APP_SERVICE_NAME, APP_ACCOUNT_NAME, access_token)
  add_keychain_item("#{APP_SERVICE_NAME}.refresh", APP_ACCOUNT_NAME, refresh_token)
end

def add_keychain_item(service_name, account_name, password)
  `security add-generic-password -a #{account_name} -s #{service_name} -w #{password} -U`
rescue StandardError => e
  puts "An error occurred while setting a token in the keychain: #{e.message}"
  exit 1
end

# rubocop:disable Metrics/MethodLength
def main
  os_name = `uname -s`
  if os_name != "Darwin\n"
    puts 'currently this script only supports MacOS'
    exit 1
  end
  if CLIENT_ID.nil?
    puts 'Please set the GITHUB_APP_CLIENT_ID environment variable.'
    exit 1
  end
  verification_uri, user_code, device_code, interval = request_device_code.values_at('verification_uri', 'user_code',
                                                                                     'device_code', 'interval')

  puts "Please visit: #{verification_uri} and enter the following code: #{user_code}"

  poll_for_token(device_code, interval)

  puts 'Successfully authenticated!'
end
# rubocop:enable Metrics/MethodLength

main
