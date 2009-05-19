module Demo
  class Calculator
    def initialize
      @stack = []
    end
    
    def push(val)
      @stack.push(val)
    end
    
    def add
      a = @stack.pop
      b = @stack.pop
      raise "bad" unless a and b
      @stack.push(a+b)
      @stack.last
    end
    
    def subtract
      a = @stack.pop
      b = @stack.pop
      raise "bad" unless a and b
      @stack.push(b-a)
      @stack.last
    end
    
    def screen
      @stack.last
    end
  end
end
