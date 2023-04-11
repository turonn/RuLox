# frozen_string_literal: true

class RuLoxCallable
  def arity
    raise NotImplementedError
  end

  def call(interpreter, arguments)
    raise NotImplementedError
  end
end
