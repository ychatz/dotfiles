if defined? Rails
  load File.dirname(__FILE__) + '/.railsrc'
end

class Integer
  def prime?
    '1' * self !~ /^1?$|^(11+?)\1+$/
  end
end
