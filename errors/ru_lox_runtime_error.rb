class RuLoxRuntimeError < RuntimeError
  attr_reader :token
  def initialize(token = nil, msg = nil)
    @token = token
    super(msg)
  end
end