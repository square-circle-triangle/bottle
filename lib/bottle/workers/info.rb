module Bottle
  module Workers
    class Info < Foreman

      def process(payload={})
        { :registered_workers => Foreman.registered_workers.inject({}) { |m, (k,v)| m[k] = v.description; m } }
      end

      def description
        "This worker provides information about the available workers."
      end

    end
  end  
end