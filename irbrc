def quiet_require(*args)
  begin
    require(*args)
  rescue LoadError
  end
end

quiet_require 'pp'
quiet_require 'nodepp'
quiet_require 'classtree'
quiet_require 'methodsig'
quiet_require 'as_expression'
quiet_require 'irb/completion'

