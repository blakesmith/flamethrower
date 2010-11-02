module Flamethrower
  class Dispatcher
    def handle_message(message)
      method = message.command.downcase
      send(method, message) if protected_methods.include?(method)
    end

    protected

    def user(message)
    end
  end
end

