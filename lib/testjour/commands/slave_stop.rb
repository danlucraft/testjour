require "testjour/commands/base_command"
require "testjour/pid_file"

module Testjour
  module CLI
    
    class SlaveStop < BaseCommand
      def self.command
        "slave:stop"
      end
      
      def run
        Testjour.logger.debug "Runner command #{self.class}..."
        pid_file = PidFile.new("./testjour_slave.pid")
        pid_file.send_signal("TERM")
      end
    end
    
    Parser.register_command SlaveStop
  end
end