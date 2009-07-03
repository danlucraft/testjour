require 'socket'
require 'English'
require 'cucumber/formatter/console'
require 'testjour/result'

module Testjour

  class HttpFormatter < ::Cucumber::Ast::Visitor
    def initialize(step_mother, io, queue_uri)
      super(step_mother)
      @queue_uri = queue_uri
    end

    def visit_multiline_arg(multiline_arg)
      @multiline_arg = true
      super
      @multiline_arg = false
    end

    def visit_step(step)
      step_start = Time.now
      super

      if step.respond_to?(:status)
        progress(Time.now - step_start, step.status, step.exception)
      end
    end
    
    def visit_feature_element(feature_element)
      @step_exception = nil
      super
      if @step_exception
        @step_exception.backtrace << feature_element.file_colon_line
        progress(0, :failed, @step_exception)
      end
    end
    
    def visit_exception(exception, status) #:nodoc:
      Testjour.logger.warn  "#{exception.message}\n\n#{exception.backtrace.join("\n")}"
      @step_exception = exception
    end

    def visit_table_row(table_row)
      row_start = Time.now
      super
      if table_row.exception
        progress(Time.now - row_start, :failed, table_row.exception)
      else
        progress(Time.now - row_start, :passed)
      end
    end

  private

    def progress(time, status, exception = nil)
      result = Result.new(time, status, exception)
      array_to_log = [time, hostname, $PID, status]
      if exception
        array_to_log += [exception.message, exception.backtrace]
      end
      Testjour.logger.info "http push :results #{array_to_log.inspect}"
      HttpQueue.with_queue(@queue_uri) do |queue|
        queue.push(:results, result)
      end
    end
    
    def hostname
      @hostname ||= `hostname`
    end
  end
end
