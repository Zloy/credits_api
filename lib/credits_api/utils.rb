module CreditsApi
  module Utils
    def self.cast_float str
      val = Float(str) rescue false
    end
    def self.cast_int str
      val = Integer(str) rescue false
    end
  end
end
