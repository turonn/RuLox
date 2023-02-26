class RuLoxRuntimeError < RuntimeError
  attr_reader :token
  def initialize(token, msg = nil)
    @token = token
    super(msg)
  end
end