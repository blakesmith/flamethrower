module Flamethrower
  module Irc
    class Message
      def initialize(message)
        @message = message
      end

      def parse
        terms = @message.split("\s")
        params = terms - [terms.first]
        {:command => terms.first, :params => strip_prefixes(params)}
      end

      def command
        parse[:command]
      end

      def parameters
        parse[:params]
      end

      def to_s
        @message
      end

      protected

      def strip_prefixes(params)
        result = []
        params.each_with_index do |param, i|
          if param.match /^:(.*)/
            result << params[i..params.length].join("\s").sub(":", "")
            return result
          else
            result << param
          end
        end
      end
    end
  end
end
