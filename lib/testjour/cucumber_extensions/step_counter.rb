require 'cucumber/ast/visitor'

module Testjour
  
  class StepCounter < Cucumber::Ast::Visitor
    attr_reader :backtrace_lines
    
    def initialize(step_mother)
      super
      @backtrace_lines = []
    end
    
    def visit_step(step_invocation)
      super
      if step_invocation.respond_to?(:status)
        @backtrace_lines << step_invocation.backtrace_line
      end
    end
    
    def visit_table_row(table_row)
      @backtrace_lines << "Table row"
    end
    
    def count
      @backtrace_lines.size
    end
  end
end
