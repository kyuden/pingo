require 'thor'

module Pingo
  class CLI < Thor
    desc "IPHONE_MODEL(ex 5, 5s)", "sound iphone"
    def pingo(device_name)
      Pingo.run(device_name)
    end

    private

    def method_missing(device_name)
      pingo(device_name.to_s)
    end
  end
end
