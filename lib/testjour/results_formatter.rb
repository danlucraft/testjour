require "testjour/progressbar"
require "testjour/colorer"
require "testjour/result_set"

module Testjour
  class ResultsFormatter
    
    def initialize(step_counter)
      @progress_bar = ProgressBar.new("0 failures", step_counter.count)
      @result_set   = ResultSet.new(step_counter)
    end
  
    def missing_backtrace_lines
      @result_set.missing_backtrace_lines
    end
    
    def result(result)
      @result_set.record(result)
      log_result(result)
      update_progress_bar
    end
    
    def update_progress_bar
      @progress_bar.colorer = colorer
      @progress_bar.title   = title
      @progress_bar.inc
      STDOUT.flush
    end
    
    def log_result(result)
      return unless result.char == "F"
      
      erase_current_line
      print Testjour::Colorer.failed("#{@result_set.errors.size}) ")
      puts Testjour::Colorer.failed(result.message)
      puts result.backtrace
      puts "from: " + result.server_id
      puts "at: #{Time.now}"
      puts
    end

    def colorer
      if failed?
        Testjour::Colorer.method(:failed).to_proc
      else
        Testjour::Colorer.method(:passed).to_proc
      end
    end
  
    def title
      "#{@result_set.slaves} slaves, #{@result_set.errors.size} failures"
    end
  
    def erase_current_line
      print "\e[K"
    end

    def print_summary
      print_summary_line(:passed)
      puts Colorer.failed("#{@result_set.errors.size} steps failed") unless @result_set.errors.empty?
      print_summary_line(:skipped)
      print_summary_line(:pending)
      print_summary_line(:undefined)
    end
    
    def print_stats
      @result_set.each_server_stat do |server_id, steps, total_time, steps_per_second|
        puts "#{server_id} ran #{steps} steps in %.2fs (%.2f steps/s)" % [total_time, steps_per_second]
      end
    end
    
    def print_summary_line(step_type)
      count = @result_set.count(step_type)
      return if count.zero?
      puts Colorer.send(step_type, "#{count} steps #{step_type}")
    end
  
    def finish
      @progress_bar.finish
      puts
      puts
      print_summary
      puts
      print_stats
      puts
    end
    
    def failed?
      @result_set.errors.any?
    end
  end
end
