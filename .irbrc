# coding: utf-8
require 'irb/completion'
require 'rubygems'
require 'pp'
require 'open-uri'
require 'yaml'
require 'wirble'
include Math

Wirble.init
Wirble.colorize

class Object
  class Fixnum
    def to_b; format("%#b", self); end
    def to_o; format("%#o", self); end
    def to_x; format("%#x", self); end
  end

  class String
    alias _orig_to_i to_i
    def to_i
      if self =~ /^(0x[\da-f]+|0b[01]+|0o[0-7]+)$/i
        return eval $&
      end
      _orig_to_i
    end
    def to_b; to_i.to_b; end
    def to_o; to_i.to_o; end
    def to_x; to_i.to_x; end
  end
end

IRB.conf[:AUTO_INDENT] = true
