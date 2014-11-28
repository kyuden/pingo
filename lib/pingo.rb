require "pingo/version"
require "pingo/cli"
require "json"
require "typhoeus"

module Pingo
  class Pingo
    INIT_CLIENT = 'initClient'
    PLAY_SOUND  = 'playSound'

    class << self
      def run(model_name)
        new(model_name).instance_eval do
          @partition = get_partition
          device_ids = get_device_ids
          device_ids.each { |device_id| play_sound(device_id) } unless device_ids.empty?
        end
      end
    end

    def initialize(model_name)
      @model_name = model_name
      @username = ENV['APPLE_ID']
      @password = ENV['APPLE_PASSWORD']
    end

    private
      def get_partition
        post(INIT_CLIENT).headers['X-Apple-MMe-Host']
      end

      def get_device_ids
        parse_device_ids(post(INIT_CLIENT))
      end

      def parse_device_ids(data)
        target_contents(data).map { |content| content["id"] }
      end

      def target_contents(data)
        contents(data).find_all { |content| match_device?(content) }
      end

      def contents(data)
        JSON.parse(data.body)['content']
      end

      def match_device?(params)
        params['deviceDisplayName'] =~ /#{@model_name}$/i
      end

      def play_sound(device_id)
        post(PLAY_SOUND, generate_body(device_id))
      end

      def generate_body(device_id)
        JSON.generate(play_sound_body(device_id))
      end

      def play_sound_body(device_id)
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

      def post(mode, body=nil)
        Typhoeus::Request.post(uri(mode), userpwd: "#{@username}:#{@password}", headers: post_headers, followlocation: true, verbose: true, maxredirs: 1, body: body)
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

      def uri(mode)
        @partition ? "https://#{@partition}/#{base_uri}/#{mode}" : "https://fmipmobile.icloud.com/#{base_uri}/#{mode}"
      end

      def base_uri
        "fmipservice/device/#{@username}"
      end
  end
end
