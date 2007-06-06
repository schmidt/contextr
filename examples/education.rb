require "rubygems"
require "contextr" 

class Person
  attr_accessor :name, :address, :university

  def initialize name, address, university
    self.name = name
    self.address = address
    self.university = university
  end

  def to_s
    "Name: #{name}"
  end
end

class University
  attr_accessor :name, :address

  def initialize name, address
    self.name = name
    self.address = address
  end

  def to_s
    "Name: #{name}"
  end
end

class Person
  layer :address, :education

  address.after :to_s do | n |
    n.return_value += "; Address: #{address}"
  end

  education.after :to_s do | n |
    n.return_value += ";\n[Education] #{university}"
  end
end

class University
  layer :address

  address.after :to_s do | n |
    n.return_value += "; Address: #{address}"
  end
end

class Example
  def initialize
    hpi = University.new( "Hasso-Plattner-Institut", "Potsdam" )
    somePerson = Person.new( "Gregor Schmidt", "Berlin", hpi )

    puts 
    somePerson.to_s
    ContextR::with_layers :education do
      puts 
      puts somePerson

      ContextR::with_layers :address do
        puts 
        puts somePerson

        ContextR::without_layers :education do
          puts 
          puts somePerson
        end
      end
    end
    puts 
  end
end
Example.new
