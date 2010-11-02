module Flamethrower
  class Dispatcher
    def handle_message(message)
      send(message.command.downcase, message)
    end

    protected

    def user(*args)
    end
  end
end

