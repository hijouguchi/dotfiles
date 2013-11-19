# vim: ft=ruby

include Math

class Object
  class Numeric
    %w[b o x].each do |n| # to_b, to_o, to_x
      define_method "to_#{n}", lambda {|arg=nil|
        f = arg ? "%#0#{arg}#{n}" : "%##{n}"
        format f, self
      }
    end
  end
end


Pry.config.history.file = ENV['HOME'] + "/.history/pry_history"
