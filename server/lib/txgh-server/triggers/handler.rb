module TxghServer
  module Triggers
    class Handler

      # includes response helpers in both the class and the singleton class
      include ResponseHelpers

      class << self
        def handle_request(request, logger)
          handle_safely do
            config = Txgh::Config::KeyManager.config_from_project(
              request.params.fetch('project_slug')
            )

            handler_for(config, request, logger).execute
          end
        end

        private

        def handle_safely
          yield
        rescue => e
          respond_with_error(500, "Internal server error: #{e.message}", e)
        end

        def handler_for(config, request, logger)
          new(
            project: config.transifex_project,
            repo: config.github_repo,
            branch: request.params.fetch('branch'),
            resource_slug: request.params.fetch('resource_slug'),
            logger: logger
          )
        end
      end

      attr_reader :project, :repo, :branch, :resource_slug, :logger

      def initialize(options = {})
        @project = options[:project]
        @repo = options[:repo]
        @branch = Txgh::Utils.absolute_branch(options[:branch])
        @resource_slug = options[:resource_slug]
        @logger = options[:logger]
      end

    end
  end
end
