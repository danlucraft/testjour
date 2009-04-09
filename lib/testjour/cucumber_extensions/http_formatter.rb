require 'socket'
#require 'english'
require 'cucumber/formatter/console'

module Testjour
  
  class HttpFormatter < Cucumber::Ast::Visitor
    include Cucumber::Formatter::Console

    def initialize(step_mother, io, queue_uri)
      super(step_mother)
      @options = {}
      @io = io
      @queue_uri = queue_uri
    end
    
    def visit_multiline_arg(multiline_arg, status)
      @multiline_arg = true
      super
      @multiline_arg = false
    end
    
    def visit_step(step)
      @step_start = Time.now
      exception = super
      unless @last_status == :outline or @last_status == :failed
        progress(@last_time, @last_status)
      end
    end
    
    def visit_step_name(keyword, step_name, status, step_definition, source_indent)
      @last_status = status
      @last_time = Time.now - @step_start
    end
    
    def visit_exception(exception, status)
      return if @skip_step
      progress(@last_time, @last_status, exception.message.to_s, exception.backtrace.join("\n"))
    end
    
    def visit_table_cell_value(value, width, status)
      progress(Time.now, status) if (status != :thead) && !@multiline_arg
    end
    
    private

    CHARS = {
      :undefined => 'U',
      :passed    => '.',
      :failed    => 'F',
      :pending   => 'P',
      :skipped   => 'S'
    }

    def progress(time, status, message = nil, backtrace = nil)
      Testjour.logger.info "http push :results #{[time, hostname, $PID, CHARS[status], message, backtrace].inspect}"
      HttpQueue.with_queue(@queue_uri) do |queue|
        queue.push(:results, [time, hostname, $PID, CHARS[status], message, backtrace])
      end
    end
    
    def hostname
      @hostname ||= Socket.gethostname
    end
    
  end

end
