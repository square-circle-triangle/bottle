module Bottle
  class Foreman

    class << self
       attr_accessor :registered_workers
       
       def registered_workers
         @@registered_workers ||= {}
       end
       
       def workers
         registered_workers.dup
       end
       
     end

    def self.inherited(sub)
      label = sub.to_s.split('::').last.downcase
      log.debug "Registering new worker: #{label}"
      registered_workers[label] = sub.new
    end
    
    protected ################################
    
    def failure(msg)
      {:state => 'error', :message => msg }
    end
    
    def success(data)
      { :state => 'success' }.merge(data)
    end
    
  end
  
end