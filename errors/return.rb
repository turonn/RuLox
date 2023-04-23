class Return < RuLoxRuntimeError
  attr_reader :value
  def initialize(keyword, value, msg="Cannot return outside of function call.")
    @value = value
    @token = keyword
    super(msg)
  end
end