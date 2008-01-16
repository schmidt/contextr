require File.dirname(__FILE__) + "/../lib/contextr"

class Employer  
  attr_accessor :name
end
class Person  
  attr_accessor :name  
  attr_accessor :employer
end


class Employer  
  def display    
    puts "Employer"    
    puts "Name: %s" % self.name  
  end
end
class Person  
  def display    
    puts "Person"    
    puts "Name: %s" % self.name  
  end
end

class Person  
  in_layer :employment do
    def display      
      super      
      yield(:receiver).employer.display    
    end  
  end
end

class Employer  
  attr_accessor :address  
  in_layer :detailed_info do   
    def display      
      super      
      puts "Address: %s" % yield(:receiver).address     
    end  
  end
end
class Person  
  attr_accessor :address  
  in_layer :detailed_info do   
    def display      
      super      
      puts "Address: %s" % yield(:receiver).address     
    end  
  end
end

vub = Employer.new
vub.name = "Vrije Universiteit Brussel"
vub.address = "Brussels"
pascal = Person.new
pascal.name = "Pascal"
pascal.employer = vub
pascal.address = "Brussels"

vub.display
puts
pascal.display
puts " - - - - - - - - "

ContextR::with_layer :employment do
  vub.display
  puts
  pascal.display
  puts " - - - - - - - - "
end

ContextR::with_layer :detailed_info do
  vub.display
  puts
  pascal.display
  puts " - - - - - - - - "

  ContextR::with_layer :employment do
    vub.display
    puts
    pascal.display
    puts " - - - - - - - - "
  end
end
