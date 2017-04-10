# frozen_string_literal: true

require "pingo/version"
require "pingo/cli"
require "json"
require "typhoeus"

module Pingo
  class Client
    INIT_CLIENT = 'initClient'.freeze
    PLAY_SOUND  = 'playSound'.freeze

    class << self
      def run(model_name)
        new(model_name).sound!
      end
    end

    def initialize(model_name)
      @model_name = model_name
      @username = ENV['APPLE_ID']
      @password = ENV['APPLE_PASSWORD']
    end

    def sound!
      device_ids.each { |device_id| post(PLAY_SOUND, generate_body(device_id)) }
    end

    def device_ids
      response = post(INIT_CLIENT)
      raise "#{response.response_code}:#{response.status_message }" unless response.success?
      parse_device_ids(response.body)
    end

    private

      def parse_device_ids(body)
        target_contents(body).map { |content| content["id"] }
      end

      def target_contents(body)
        target = contents(body).find_all { |content| match_device?(content) }
        target.empty? ? raise("Not found your device(iPhone#{@model_name})") : target
      end

      def contents(body)
        JSON.parse(body)['content']
      end

      def match_device?(params)
        params['deviceDisplayName'] =~ /#{@model_name}$/i
      end

      def generate_body(device_id)
        JSON.generate(sound_body(device_id))
      end

      def sound_body(device_id)
        {
          clientContext: {
            appName: 'FindMyiPhone',
            appVersion:  '2.0.2',
            shouldLocate: false,
          },
          device: device_id,
          subject: "Pingo"
        }
      end

      def post(type, body=nil)
        Typhoeus::Request.post(uri(type),
                               userpwd: "#{@username}:#{@password}",
                               headers: post_headers,
                               followlocation: true,
                               verbose: true,
                               maxredirs: 1,
                               body: body)
      end

      def post_headers
          {
            'Content-Type'          => 'application/json; charset=utf-8',
            'X-Apple-Find-Api-Ver'  => '2.0',
            'X-Apple-Authscheme'    => 'UserIdGuest',
            'X-Apple-Realm-Support' => '1.0',
            'Accept-Language'       => 'en-us',
            'userAgent'             => 'Pingo',
            'Connection'            => 'keep-alive'
          }
      end

      def uri(type)
        "https://fmipmobile.icloud.com/fmipservice/device/#{@username}/#{type}"
      end
  end
end
