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
      label = sub.to_s.sub('Bottle::','').downcase
      registered_workers[label] = sub.new
    end
    
  end
  
end