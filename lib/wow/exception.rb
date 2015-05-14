module Wow
  class Error < StandardError
    def error_message
      message
    end
  end
  UnknownCommand = Class.new(Wow::Error)

  class UnprocessableEntity < Wow::Error
    def initialize(entity, error)
      @entity = entity
      @error = error
      super("Unprocessable entity: #{entity}")
    end

    def error_message
      msg = "#{message}\n"
      @error.each do |attr, errors|
        msg << "\t#{attr}"
        if errors.size == 1
          msg << ' ' << errors.first
        else
          msg << ":\n"
          errors.each do |error|
            msg << "\t - #{error}\n"
          end
        end
      end
      msg
    end
  end
end