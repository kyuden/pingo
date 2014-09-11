require 'thor'

module Pingo
  class CLI < Thor
    desc "[MODEL_NAME]", "Sound apple device"
    long_desc <<-LONGDESC
      `pingo [MODEL_NAME]` will sound your apple device.

      ex) when iphone 5s
      \x5> $ pingo 5s
    LONGDESC

    def pingo(device_name)
      Pingo.run(device_name)
    end

    private

    def method_missing(device_name)
      pingo(device_name.to_s)
    end
  end
end
