require "forwardable"

module Jam
  module DSL
    class Remote
      extend Forwardable
      def_delegators :ssh, :host

      include Jam::DSL

      def initialize(ssh, helpers: [])
        @ssh = ssh
        @prefixes = []
        helpers.each { |mod| extend(mod) }
        freeze
      end

      def prepend(*args)
        prefixes.push(*args)
        yield
      ensure
        prefixes.pop(args.count)
      end

      def attach(command, *args, echo: true)
        full_command = build_full_command(command, args)
        log(full_command, echo) if echo
        ssh.attach(full_command)
      end

      # rubocop:disable Metrics/ParameterLists
      def run(command, *args,
              echo: true,
              silent: false,
              pty: false,
              raise_on_error: true)
        full_command = build_full_command(command, args)
        log(full_command, echo) if echo
        ssh.run(
          full_command,
          silent: silent,
          pty: pty,
          raise_on_error: raise_on_error
        )
      end
      # rubocop:enable Metrics/ParameterLists

      private

      attr_reader :ssh, :prefixes

      def log(command, echo)
        command_string = command.join(" ")
        puts(echo == true ? "\e[0;90;49m#{host}$ #{command_string}\e[0m" : echo)
      end

      def build_full_command(command, args)
        [prefixes, command, args].flatten
      end
    end
  end
end