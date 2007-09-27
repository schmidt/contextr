require File.dirname(__FILE__) + "/test_helper.rb"

test(:TestIntroduction) do

p %q{Let's build a simple student's database.
     Each University has a name and address. Each student has a name, address 
     and an associated university.}

p %q{We are using a Struct to build our classes in an easy way. This provides 
     all getters, setters and an easy constructor setting all the instance 
     variables.}

p %q{In order to get a nice output in our program we override the #to_s method
     which is used in many cases by ruby, e.g. in Kernel#puts or in String 
     interpolation.}

p %q{In most of the cases, the name is sufficient to represent each entity, i.e.
     a student or a university.}

output do
  class University < Struct.new(:name, :address)
    def to_s
      name
    end
  end

  class Student < Struct.new(:name, :address, :university)
    def to_s
      name
    end
  end
end

p %q{Under certain circumstances we would like to have a more verbose output.
     This could mean print the university a student belongs to or attach the
     address to the output.}

h2 "Additonal methods"

p %q{In a plain old Ruby project, this would result in additional methods, 
     propably encapsulated in modules, that will be included into our classes. 
     This allows reuse and better encapsulation.}

output do
  module AddressOutput
    def to_s_with_address
      "#{self} (#{self.address})"
    end
  end

  class University
    include AddressOutput
  end
end

p %q{Now each university got a to_s_with_address method that could be called 
     instead of to_s if you would like to have additional information.}

output do
  class Student
    include AddressOutput

    def to_s_with_university
      "#{self}; #{self.unversity}"
    end
    def to_s_with_university_and_address
      "#{self.to_s_with_address}; #{self.unversity.to_s_with_address}"
    end
  end
end

p %q{The same for each student. #to_s_with_unversity and 
     #to_s_with_university_and_address give as well additional output.}

p %q{So how can you use it. Let's create some instances first.}

output do
  $hpi = University.new("HPI", "Potsdam")
  $gregor = Student.new("Gregor", "Berlin", $hpi)
end

p %q{An now some output. This could live inside an erb template, a graphical 
     ui or printed to the command line. In all these cases to_s is called 
     automatically by the standard libary to receive a good representation of 
     the object.}

p %q{The output method defined in test_helper.rb simulates this behaviour. All
     examples are converted to test class automatically, so we can be sure, that
     this document stays in sync with the libary.}

code %q{
 puts gregor   # => prints "Gregor"
 "#{gregor}"   # => evaluates to "Gregor"
 <%= gregor %>   => as well as this
}

example do
  output_of($gregor) == "Gregor"
  output_of($hpi) == "HPI"
end

p %q{Assume, we would like to print an address list now.}

example do
  output_of($gregor.to_s_with_address) == "Gregor (Berlin)"
end

p %q{If you want a list with university and addresses, you would use 
     #to_s_with_university_and_address. No automatic call to to_s anymore. If 
     you have your layout in an erb template, you have to change each and every 
     occurrence of your variables.}


h2 "Redefining to_s"

p %q{To solve this problem you could redefine to_s on demand. I will demonstrate
     this with some meta programming in a fresh class.}

output do
  module GenericToS
    def to_s
      self.class.included_vars.collect do |var|
        self.send(var)
      end.join("; ")
    end


    module ClassMethods
      attr_accessor :included_vars
      def set_to_s(*included_vars)
        self.included_vars = included_vars
      end
    end

    def self.included(base_class)
      base_class.send(:extend, ClassMethods)
    end
  end

  class Company < Struct.new(:name, :address)
    include GenericToS
  end

  class Employee < Struct.new(:name, :address, :company)
    include GenericToS
  end
end

p %q{I will not go into detail how this code works, but I will show you how to 
     use it. Let's get some instances first.}

output do
  $ms = Company.new("Microsoft", "Redmond")
  $bill = Employee.new("Bill", "Redmond", $ms)
end

p "And now use these instances."

example do
  Company.set_to_s(:name)
  Employee.set_to_s(:name)

  output_of($ms) == "Microsoft"
  output_of($bill) == "Bill"
end

p "Let's get the output including the addresses"

example do
  Employee.set_to_s(:name, :address)

  output_of($bill) == "Bill; Redmond"
end

p "And including the employer"

example do
  Employee.set_to_s(:name, :address, :company)

  output_of($bill) == "Bill; Redmond; Microsoft"
end

p %q{But hey. I wanted to have a list with all addresses, not just to 
     employee's. This should be an address list, right? But we did not tell 
     the Company class to print the address, but just the Employee class.}

p %q{So in our first approach, we had to change each place, where we use the
     object. In the second approach we have to know all places where an address
     is stored and apply the changes in there.}

p %q{By the way, what happens, if I was using a multi-threaded application and
     one user request a simple name list, and the other switches to an address 
     list in the meantime. Then the output will be mixed - with and without 
     addresses. This is not exactly what we want. So there has to be an easier, 
     thread safe solution.}


h2 "ContextR"

p %q{This is were context-oriented programming comes into play. I will again 
     start from the scratch. It is not much and we all know the problem space 
     now.}

p %q{The same setup, just another setting. First the basic implementation, just 
     like we did it in our first approach}

output do
  class Religion < Struct.new(:name, :origin)
    def to_s
      name
    end
  end
  class Believer < Struct.new(:name, :origin, :religion)
    def to_s
      name
    end
  end
end

p %q{Now define the additional behaviour in separate modules. Please don't be 
     scared because of the strange syntax and method calls.
     yield(:receiver) refers to the "normal" self when these modules are 
     included yield(:next) is much like a super call.}

p %q{Future versions of ContextR will hopefully provide a nicer syntax here.}

output do
  module OriginMethods
    def to_s
      "#{yield(:next)} (#{yield(:receiver).origin})"
    end
  end
  module ReligionMethods
    def to_s
      "#{yield(:next)}; #{yield(:receiver).religion}"
    end
  end
end

p %q{Finally we need to link our additional behaviour to our basic classes.
     We also need to tell the framework, when this behaviour should be applied.}

output do
  class Religion
    include OriginMethods => :location
  end
  class Believer
    include OriginMethods => :location
    include ReligionMethods => :believe
  end
end

p %q{The additional context dependent behaviour is organised within layers. A 
     single layer may span multiple classes - in this case the location layer 
     does. To enable the additional code, the programmes shall activate layers.
     A layer activation is only effective within a block scope and within the 
     current thread.}

p "Let's see, how it looks like when we use it."

output do
  $christianity = Religion.new("Christianity", "Israel")
  $the_pope = Believer.new("Benedikt XVI", "Bavaria", $christianity)
end

example do
  output_of($christianity) == "Christianity"
  output_of($the_pope) == "Benedikt XVI"
end

p %q{Would like to have an address? For this we have to activate the location 
     layer. Now the additional behaviour defined within the layer, will be 
     executed around the base method defined within the class.}

example do
  ContextR.with_layer :location do 
    output_of($christianity) == "Christianity (Israel)"
    output_of($the_pope) == "Benedikt XVI (Bavaria)"
  end
end


p %q{Of course the additional behaviour is deactivated automatically after the
     blocks execution.}

example do
  output_of($christianity) == "Christianity"
  output_of($the_pope) == "Benedikt XVI"
end

p "Everything back to normal."

p "Lets activate the believe layer"

example do
  ContextR.with_layer :believe do 
    output_of($the_pope) == "Benedikt XVI; Christianity"
  end
end

p %q{Now we need both, location and believe. How does it look like? You have to
     options. You may activate the two one after the other or all at once. It 
     is just a matter of taste, the result remains the same.}

example do
  ContextR.with_layer :believe, :location do 
    output_of($the_pope) == "Benedikt XVI (Bavaria); Christianity (Israel)"
  end
end

p %q{As you can see, the activation of the location layer is operative in the
     whole execution context of the block. Each religion prints its origin, 
     wheter to_s was called directly or indirectly.}

p %q{If you change your mind within your call stack, you may of course 
     deactivate layers again.}

example do
  ContextR.with_layer :believe do 
    ContextR::with_layer :location do
      output_of($the_pope) == "Benedikt XVI (Bavaria); Christianity (Israel)"

      ContextR.without_layer :believe do 
        output_of($the_pope) == "Benedikt XVI (Bavaria)"
      end

      output_of($the_pope) == "Benedikt XVI (Bavaria); Christianity (Israel)"
    end
  end
end

p %q{These encaspulations may be as complex as your application. ContextR will
     keep track of all activations and deactivations within the blocks and
     restore the settings after the block was executed.}

p %q{This was just a short introduction on a problem case, that can be solved
     with context-oriented programming. You have seen, the advantages and how
     to use it. In other files in this folder, you can learn more on the 
     dynamics and meta programming interfaces of ContextR.}
end
