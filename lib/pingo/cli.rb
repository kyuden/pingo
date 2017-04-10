# frozen_string_literal: true

require 'thor'
require 'pingo/cli/pingo'

module Pingo
  class CLI < Thor
    map '--version' => :version, '-v' => :version
    desc :version, 'Show version'
    def version
      puts VERSION
    end

    private
      def method_missing(model_name)
        pingo(model_name.to_s)
      end
  end
end
