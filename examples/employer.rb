require File.dirname(__FILE__) + "/../lib/contextr"

module EasyInitializerMixin
  def initialize(options = {})
    options.each do |key, value| 
      self.send("#{key}=", value)
    end
  end
end

class Employer  
  attr_accessor :name
  include EasyInitializerMixin
end
class Person  
  attr_accessor :name, :employer
  include EasyInitializerMixin
end


class Employer  
  def to_s    
    "Employer\n" +    
    "Name: %s" % self.name  
  end
end
class Person  
  def to_s    
    "Person\n" +    
    "Name: %s" % self.name  
  end
end

class Person  
  in_layer :employment do
    def to_s      
      super + "\n%s" % yield(:receiver).employer
    end  
  end
end

class Employer  
  attr_accessor :address  
  in_layer :detailed_info do   
    def to_s      
      super + "\n" + 
      "Address: %s" % yield(:receiver).address     
    end  
  end
end
class Person  
  attr_accessor :address  
  in_layer :detailed_info do   
    def to_s      
      super + "\n" + 
      "Address: %s" % yield(:receiver).address     
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

puts vub
puts
puts pascal
puts " - - - - - - - - "

ContextR::with_layer :employment do
  puts vub
  puts
  puts pascal
  puts " - - - - - - - - "
end

ContextR::with_layer :detailed_info do
  puts vub
  puts
  puts pascal
  puts " - - - - - - - - "

  ContextR::with_layer :employment do
    puts vub
    puts
    puts pascal
    puts " - - - - - - - - "
  end
end

describe ContextR do
  it "should show all currently active layers" do
    ContextR::with_layer :employment do
      ContextR::active_layers.should == [:employment]

      ContextR::with_layer :detailed_info do
        ContextR::active_layers.should == 
                        [:detailed_info, :employment]
      end
  
      ContextR::active_layers.should == [:employment]
    end
  end

  it "should show all layers ever used" do
    ContextR::layers.should == [:employment, :detailed_info]
  end
end

describe ContextR do
  it "should list all extended methods" do
    Person.in_layer(:employment).instance_methods.should == ["to_s"]
    Employer.in_layer(:employment).instance_methods.should be_empty
  end
end


describe ContextR do
  it "should execute later layers first, earlier layers later" do
    ContextR::with_layer :detailed_info do
      ContextR::with_layer :employment do

        ContextR::active_layers.should ==
                                    [:employment, :detailed_info]
      end
    end

    ContextR::with_layer :detailed_info, :employment do

      ContextR::active_layers.should ==
                                    [:employment, :detailed_info]
    end
  end
end

describe ContextR do          
  it "should hide deactivated layers" do
    ContextR::with_layer :detailed_info, :employment do
                              
      ContextR::active_layers.should ==
                                    [:employment, :detailed_info]
                              
      ContextR::without_layer :employment do
        ContextR::active_layers.should == [:detailed_info]
      end                     
                              
      ContextR::without_layer :detailed_info do
        ContextR::active_layers.should == [:employment]
      end
    end
  end
end

describe ContextR do
  it "should update order at repetitive activation" do
    ContextR::with_layer :detailed_info, :employment do
                           
      ContextR::active_layers.should == [:employment, :detailed_info]
                           
      ContextR::with_layer :detailed_info do
        ContextR::active_layers.should == [:detailed_info, :employment]
      end                  
                           
      ContextR::with_layer :employment do
        ContextR::active_layers.should == [:employment, :detailed_info]
      end
    end                               
  end 
end 

describe ContextR do
  it "should activate layer, even when they were explicitly deactivated" do
    ContextR::with_layer :detailed_info, :employment do
      ContextR::without_layer :employment do
        ContextR::with_layer :employment do
          ContextR::active_layers.should == [:employment, :detailed_info]
        end
      end
    end
  end
end 

describe ContextR do
  def step(index, *layers)
    @step += 1
    @step.should == index
    ContextR::active_layers.should == layers
  end

  def task_one
    @mutex.lock
    ContextR::with_layer :employment do
      step(2, :employment, :detailed_info)
      @mutex.unlock
      sleep(0.1)
      @mutex.lock
      step(4, :employment, :detailed_info)
    end
    @mutex.unlock
  end
  
  def task_two
    @mutex.lock
    step(3, :detailed_info)
    @mutex.unlock
  end

  before do
    @mutex = Mutex.new
    @step = 0
  end
  
  it "should consider dynamic scope" do
    ContextR::with_layer :detailed_info do
      step(1, :detailed_info)
    
      one = Thread.new { task_one }
      two = Thread.new { task_two }
      
      one.join
      two.join
      step(5, :detailed_info)
    end
  end
end
