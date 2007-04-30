require File.dirname( __FILE__ ) + '/../contextr'

class Person
  layer :address, :education

  attr_accessor :name, :address, :university

  def initialize name, address, university
    self.name = name
    self.address = address
    self.university = university
  end

  def to_s
    "Name: #{name}"
  end

  address.post :to_s do | n |
    n.return_value += "; Address: #{address}"
  end

  education.post :to_s do | n |
    n.return_value += ";\n[Education] #{university}"
  end
end

class University
  layer :address

  attr_accessor :name, :address

  def initialize name, address
    self.name = name
    self.address = address
  end

  def to_s
    "Name: #{name}"
  end

  address.post :to_s do | n |
    n.return_value += "; Address: #{address}"
  end
end


hpi = University.new( "Hasso-Plattner-Institut", "Potsdam" )
somePerson = Person.new( "Gregor Schmidt", "Berlin", hpi )

puts 
puts somePerson
ContextR::with_layers :address do
  puts 
  puts somePerson

  ContextR::with_layers :education do
    puts 
    puts somePerson

    ContextR::without_layers :address do
      puts 
      puts somePerson
    end
  end
end
puts 
