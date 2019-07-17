module Tomo
  module Testing
    class PluginTester
      def initialize(*plugin_names, settings: {}, host:)
        @host = host
        config = Configuration.new
        config.hosts << @host
        config.plugins.push(*plugin_names, "testing")
        config.settings[:application] = "testing"
        config.settings.merge!(settings)
        @runtime = config.build_runtime
      end

      def call_helper(helper, *args, **kwargs)
        run_task("testing:call_helper", helper, args, kwargs)
        host.helper_values.pop
      end

      def run_task(task, *args)
        capturing_logger_output do
          runtime.run!(task, *args, privileged: false)
          nil
        end
      end

      def stdout
        @stdout_io&.string
      end

      def stderr
        @stderr_io&.string
      end

      private

      attr_reader :host, :runtime

      def capturing_logger_output
        orig_logger = Tomo.logger
        @stdout_io = StringIO.new
        @stderr_io = StringIO.new
        Tomo.logger = Tomo::Logger.new(stdout: @stdout_io, stderr: @stderr_io)
        yield
      ensure
        Tomo.logger = orig_logger
      end
    end
  end
end