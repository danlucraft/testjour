require 'cucumber/ast/visitor'

module Testjour
  
    class StepCounter < Cucumber::Ast::Visitor
      attr_reader :backtrace_lines
      
      def initialize(step_mother)
        super
        @backtrace_lines = []
      end
      
      # def visit_step(step)
      #   # Testjour.logger.info("visit_step")
      #   unless @last_status == :outline
      #     @count += 1
      #   end
      # end
      # 
      # def visit_step_name(keyword, step_name, status, step_definition, source_indent)
      #   # Testjour.logger.info "visit_step_name(#{keyword.inspect}, #{step_name.instance_variable_get(:@step_name).inspect}, #{status.inspect}"
      #   @last_status = status
      # end
      # 
      # def visit_table_cell_value(value, width, status)
      #   if (status != :thead) && !@multiline_arg
      #     @count += 1
      #   end
      # end
      # 
      # def visit_table_row(table_row)
      #   super
      #   @count += 1
      def visit_step(step_invocation)
        if step_invocation.respond_to?(:status) #&& step_invocation.status != :outline
          @backtrace_lines << step_invocation.backtrace_line
        end
      end
      
      def visit_table_cell_value(value, width, status)
        # Testjour.logger.info "#{value.inspect}, #{status.inspect}"
        super
        @backtrace_lines << "Table cell value: #{value}" unless status == :skipped_param
      end
      
      def count
        @backtrace_lines.size
      end
      
    end

end
