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
          partition  = request_partition
          device_ids = request_device_ids(partition)
          request_sound(partition, device_ids)
        end
      end
    end

    def initialize(model_name)
      @model_name = model_name
      @username = ENV['APPLE_ID']
      @password = ENV['APPLE_PASSWORD']
    end

    private
      def request_partition
        post(INIT_CLIENT).headers['X-Apple-MMe-Host']
      end

      def request_device_ids(partition)
        raise "partition is nil" unless partition
        parse_device_ids(post(INIT_CLIENT, partition))
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

      def request_sound(partition, device_ids)
        raise "partition is nil" unless partition
        raise "device id is nil" if Array(device_ids).empty?
        Array(device_ids).map { |device_id| post(PLAY_SOUND, partition, generate_body(device_id)) }
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

      def post(mode, partition="fmipmobile.icloud.com", body=nil)
        Typhoeus::Request.post(uri(mode, partition),
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

      def uri(mode, partition)
        "https://#{partition}/fmipservice/device/#{@username}/#{mode}"
      end
  end
end
