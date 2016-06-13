module Vend
  module Resource
    class Supplier < Vend::Base
      # Returns the endpoint name for a collection of this resource
      def self.collection_name
        endpoint_name
      end

      # Builds a collection of instances from a JSON response
      def self.build_from_json(client, json)
        json[collection_name.pluralize].map do |attrs|
          self.build(client, attrs)
        end
      end

      # Initializes a single object from a JSON response.
      # Assumes the response is a JSON array with a single item.
      def self.initialize_singular(client, json)
        self.build(client, json[collection_name.pluralize].first)
      end
    end
  end
end
