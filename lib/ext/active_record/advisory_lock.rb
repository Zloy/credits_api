module ActiveRecord
  module AdvisoryLock

    def self.included base
      base.extend ClassMethods
    end

    def obtain_advisory_lock(*params, &block)
      self.class.obtain_advisory_lock(*params, &block)
    end

    module ClassMethods
      def obtain_advisory_lock(*params, &block)
        key, type = params.map { |param| param.to_i }

        raise ArgumentError, "Method expects a block" unless block_given?

        obtain_lock(key, type)

        begin
          yield block
        ensure
          release_lock(key, type)
        end
      end

      protected

      def obtain_lock(key1, key2)
        if key2.nil?
          connection.execute("SELECT pg_advisory_lock(#{key1})")
        else
         connection.execute("SELECT pg_advisory_lock(#{key1}, #{key2})")
       end
      end

      def release_lock(key1, key2)
        if key2.nil?
          connection.execute("SELECT pg_advisory_unlock(#{key1})")
        else
          connection.execute("SELECT pg_advisory_unlock(#{key1}, #{key2})")
        end
      end
    end
  end
end
