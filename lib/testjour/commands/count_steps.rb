require "testjour/commands/command"

module Testjour
module Commands
    
  class CountSteps < Command
    
    def execute
      configuration.parse!
      configuration.parse_uri!
      
      Dir.chdir(configuration.path) do
        puts "Starting to count"
      
        configuration.setup
        p configuration.feature_files
        p step_counter.count
      end
    end
    
    def step_counter
      return @step_counter if @step_counter
      
      features = load_plain_text_features(configuration.feature_files)
      @step_counter = Testjour::StepCounter.new(step_mother)
      @step_counter.options = configuration.cucumber_configuration.options
      @step_counter.visit_features(features)
      return @step_counter
    end
  end
  
end
end