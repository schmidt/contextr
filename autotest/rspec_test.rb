require 'rubygems'
require 'autotest/rspec'

class Autotest
  class RspecTest
    def self.run
      Thread.new do
        Autotest::Rspec.run
      end
      Autotest.run
    end
  end
end
