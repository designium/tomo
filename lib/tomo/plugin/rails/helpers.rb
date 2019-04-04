module Tomo::Plugin::Rails
  module Helpers
    def rails(*args, **opts)
      prepend("exec", "rails") do
        bundle(*args, **opts)
      end
    end

    def rake(*args, **opts)
      prepend("exec", "rails") do
        bundle(*args, **opts)
      end
    end
  end
end
