module Wow
  Error = Class.new(StandardError)
  UnknownCommand = Class.new(Wow::Error)

end