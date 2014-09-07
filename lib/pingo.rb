require "pingo/version"
require "pingo/cli/sound"
require "json"
require "typhoeus"

module Pingo
  class Pingo
    INIT_CLIENT = 'initClient'
    PLAY_SOUND  = 'playSound'

    def initialize(device_name)
      @device_name = device_name
      @username = ENV['APPLE_ID']
      @password = ENV['APPLE_PASSWORD']
    end

    def self.run(device_name)
      new(device_name).instance_eval do
        @partition = get_partition
        @device_id = get_device_id
        play_sound
      end
    end

    private

    def get_partition
      post(INIT_CLIENT).headers['X-Apple-MMe-Host']
    end

    def get_device_id
      parse_device_id(post(INIT_CLIENT))
    end

    def parse_device_id(data)
      JSON.parse(data.body)['content'].each { |params| return params["id"] if match_device?(params) }
    end

    def match_device?(params)
      params['location'] && params['deviceDisplayName'] =~ /#{@device_name}$/
    end

    def play_sound
      post(PLAY_SOUND, generate_body)
    end

    def generate_body
      JSON.generate(play_sound_body)
    end

    def play_sound_body
      {
        clientContext: {
          appName: 'FindMyiPhone',
          appVersion:  '2.0.2',
          shouldLocate: false,
        },
        device: @device_id,
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
