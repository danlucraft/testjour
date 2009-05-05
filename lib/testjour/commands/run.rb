require "optparse"
require "socket"

require "testjour/commands/command"
require "testjour/http_queue"
require "testjour/configuration"
require "testjour/cucumber_extensions/step_counter"
require "testjour/cucumber_extensions/feature_file_finder"
require "testjour/results_formatter"
require "testjour/result"

module Testjour
module Commands
    
  class Run < Command
    
    def execute
      configuration.unshift_args(testjour_yml_args)
      configuration.parse!
      
      HttpQueue.with_queue_server do
        configuration.setup
        
        if configuration.feature_files.any?
          queue_features
          
          @started_slaves = 0
          start_slaves
          
          puts "Requested build from #{@started_slaves} slaves... (Waiting for #{step_counter.count} results)"
          puts
          
          print_results
        else
          Testjour.logger.info("No feature files. Quitting.")
        end
      end
    end
    
    def queue_features
      Testjour.logger.info("Queuing #{configuration.feature_files.length} features...")
      
      HttpQueue.with_queue(queue_uri) do |queue|
        configuration.feature_files.each do |feature_file|
          queue.push(:feature_files, feature_file)
          Testjour.logger.info "Queued: #{feature_file}"
        end
      end
    end
    
    def start_slaves
      start_local_slaves
      start_remote_slaves
    end
    
    def start_local_slaves
      configuration.local_slave_count.times do
        @started_slaves += 1
        start_slave
      end
    end
    
    def start_remote_slaves
      configuration.remote_slaves.each do |remote_slave|
        @started_slaves += 1
        start_remote_slave(remote_slave)
      end
    end
    
    def start_remote_slave(remote_slave)
      uri = URI.parse(remote_slave)
      cmd = remote_slave_run_command(uri.user, uri.host, uri.path)
      Testjour.logger.info "Starting remote slave: #{cmd}"
      detached_exec(cmd)
    end
    
    def remote_slave_run_command(user, host, path)
      "ssh #{user}@#{host} /opt/songkick/bin/testjour run:remote --in=#{path} #{configuration.run_slave_args.join(' ')} #{testjour_uri}".squeeze(" ")
    end
    
    def start_slave
      Testjour.logger.info "Starting slave: #{local_run_command}"
      detached_exec(local_run_command)
    end
    
    def testjour_yml_args
      @testjour_yml_args ||= begin
        if File.exist?("testjour.yml")
          File.read("testjour.yml").strip.split
        else
          []
        end
      end
    end
    
    def print_results
      results_formatter = ResultsFormatter.new(step_counter)
      
      HttpQueue.with_queue(queue_uri) do |queue|
        step_counter.count.times do
          results_formatter.result(queue.pop(:results))
        end
      end
      
      results_formatter.finish
      
      return results_formatter.failed? ? 1 : 0
    rescue => ex
      if ex.message =~ /result overdue/
        $stderr.puts
        $stderr.puts "Missing steps:"
        $stderr.puts
        results_formatter.missing_backtrace_lines.each do |line|
          $stderr.puts "    #{line}"
        end
        $stderr.puts
      end
      
      raise
    end
    
    def step_counter
      return @step_counter if @step_counter
      
      features = load_plain_text_features(configuration.feature_files)
      @step_counter = Testjour::StepCounter.new(step_mother)
      @step_counter.options = configuration.cucumber_configuration.options
      @step_counter.visit_features(features)
      return @step_counter
    end
    
    def local_run_command
      "testjour run:slave #{configuration.run_slave_args.join(' ')} #{testjour_uri}".squeeze(" ")
    end
    
    def queue_uri
      "http://localhost:#{Testjour::HttpQueue.port}/"
    end
    
    def testjour_uri
      user = `whoami`.strip
      host = Socket.gethostname
      "http://#{user}@#{host}:#{Testjour::HttpQueue.port}" + File.expand_path(".")
    end
    
    def testjour_path
      File.expand_path(File.dirname(__FILE__) + "/../../../bin/testjour")
    end
    
  end
  
end
end
