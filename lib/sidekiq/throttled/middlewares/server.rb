# frozen_string_literal: true

# internal
require_relative "../message"
require_relative "../registry"

module Sidekiq
  module Throttled
    module Middlewares
      # Server middleware required for Sidekiq::Throttled functioning.
      class Server
        include Sidekiq::ServerMiddleware

        def call(_worker, msg, _queue)
          yield
        ensure
          message = Message.new(msg)

          if message.job_class && message.job_id
            Registry.get(message.job_class) do |strategy|
              strategy.finalize!(message.job_id, *message.job_args)
            end
          end
        end
      end
    end
  end
end
