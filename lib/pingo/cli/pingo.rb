# frozen_string_literal: true

module Pingo
  class CLI < Thor
    desc "[MODEL_NAME]", "Sound apple device"
    long_desc <<-LONGDESC
      `pingo [MODEL_NAME]` will sound your apple device.

      ex) when iphone 5s
      \x5> $ pingo 5s
    LONGDESC

    def pingo(model_name)
      Client.run(model_name)
    end
  end
end
