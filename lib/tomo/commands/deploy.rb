module Tomo
  module Commands
    class Deploy
      include Colors

      def parser
        Tomo::CLI::Parser.new do |parser|
          parser.banner = <<~BANNER
            Usage: tomo deploy [options]

            Run the "deploy" script specified in .tomo/project.json to deploy this project.
            For projects that have more than one environment (e.g. staging, production),
            specify the target environment using the `-e` option.
          BANNER
          parser.permit_empty_args = true
          parser.add(Tomo::CLI::DeployOptions)
        end
      end

      def call(options)
        Tomo.logger.info "tomo deploy v#{Tomo::VERSION}"

        release = Time.now.utc.strftime("%Y%m%d%H%M%S")
        project = load_project!(options, release)
        app = project.settings[:application]

        plan = project.build_deploy_plan
        plan.run

        log_completion(app, plan)
      end

      private

      def log_completion(app, plan)
        target = "#{app} to #{plan.applicable_hosts_sentence}"

        if Tomo.dry_run?
          Tomo.logger.info(green("* Simulated deploy of #{target} (dry run)"))
        else
          Tomo.logger.info(green("✔ Deployed #{target}"))
        end
      end

      def load_project!(options, release)
        Tomo.load_project!(
          environment: options[:environment],
          settings: options[:settings].merge(
            release_path: "%<releases_path>/#{release}"
          )
        )
      end
    end
  end
end