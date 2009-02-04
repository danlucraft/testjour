require "testjour/commands/command"
require "cucumber"
require "daemons/daemonize"
require "testjour/cucumber_extensions/http_formatter"
require "stringio"

module Testjour
module Commands
    
  class LocalRun < Command
    
    def execute
      daemonize
      Testjour.logger.info "Starting local:run"
      initialize_cucumber
      require_files
      work
    end
    
    def daemonize
      original_working_directory = File.expand_path(".")
      logfile = File.expand_path("./testjour.log")
      Daemonize.daemonize(logfile)
      Dir.chdir(original_working_directory)
      Testjour.setup_logger
    end
    
    def initialize_cucumber
      require 'cucumber/cli/main'
      
      cucumber_configuration.load_language
      step_mother.options = cucumber_configuration.options
    end
    
    def work
      HttpQueue.with_queue do |queue|
        feature_file = true
        
        while feature_file
          begin
            feature_file = queue.pop(:feature_files)
          rescue Curl::Err::ConnectionFailedError
            feature_file = false
          end
          
          if feature_file
            Testjour.logger.info "Running: #{feature_file}"
            features = load_plain_text_features(feature_file)
            execute_features(features)
          end
        end
      end
    end
    
    def execute_features(features)
      visitor = Testjour::HttpFormatter.new(step_mother, StringIO.new, cucumber_configuration.options)
      visitor.visit_features(features)
    end
    
    def require_files
      cucumber_configuration.files_to_require.each do |lib|
        Testjour.logger.info "Requiring: #{lib}"
        require lib
      end
    end
    
  end
  
end
end