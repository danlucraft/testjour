require "testjour/commands/command"
require "cucumber"
require "uri"
require "daemons/daemonize"
require "testjour/cucumber_extensions/http_formatter"
require "testjour/mysql"
require "testjour/rsync"
require "stringio"

module Testjour
module Commands
    
  class RunRemote < RunSlave
    
    def execute
      Signal.list.each do |name, code|
        next if name == "VTALRM"

        Signal.trap(code) do
          Testjour.logger.info "Received signal: #{code}"
        end
      end
      
      configuration.parse!
      configuration.parse_uri!
      
      # raise configuration.rsync_uri.inspect
      
      Dir.chdir(configuration.in) do
        Testjour.setup_logger(configuration.in)
        Testjour.logger.info "Starting run:slave"
        
        rsync
        Testjour.logger.info "Setup"
        configuration.setup
        configuration.setup_mysql
        Testjour.logger.info "Requiring"
        require_files
        Testjour.logger.info "Working"
        work
      end
    end
    
    def rsync
      Rsync.copy_to_current_directory_from(configuration.rsync_uri)
    end
    
  end
  
end
end