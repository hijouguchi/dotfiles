# vim: ft=ruby

include Math

class Object
  class Numeric
    def to_b; format("%#b", self); end
    def to_o; format("%#o", self); end
    def to_x; format("%#x", self); end
  end
end


Pry.config.history.file = ENV['HOME'] + "/.history/pry_history"
