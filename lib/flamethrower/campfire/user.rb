module Flamethrower
  module Campfire
    class User
      attr_reader :name

      def initialize(params = {})
        @name = params['name']
      end
    end
  end
end
