namespace :docker do
  task :deploy do
    invoke 'docker:prepare_environment'

    if fetch(:docker_compose) == true
      invoke 'docker:deploy:compose'
    else
      invoke 'docker:deploy:default'
    end
  end

  task :prepare_environment do
    env = {}

    fetch(:docker_pass_env).each do |env_key|
      env[env_key] = ENV[env_key]
    end

    SSHKit.config.default_env.merge! env
  end

  task :current_revision do
    invoke "#{scm}:set_current_revision"
  end

  def build_command
    cmd = ["build"]
    cmd << "-t #{fetch(:docker_image_full)}"
    cmd << "-f `pwd -P`/#{fetch(:docker_dockerfile)}"
    cmd << "--pull" if fetch(:docker_pull) == true
    cmd << fetch(:docker_buildpath)

    cmd.join(" ")
  end
end

namespace :load do
  task :defaults do
    set :docker_current_container,    -> { "#{fetch(:application)}_#{fetch(:current_revision)}" }
    set :docker_previous_container,   -> { "#{fetch(:application)}_#{fetch(:previous_revision)}" }
    set :docker_role,                 -> { :web }
    set :docker_pull,                 -> { false }
    set :docker_dockerfile,           -> { "Dockerfile" }
    set :docker_buildpath,            -> { "." }
    set :docker_detach,               -> { true }
    set :docker_volumes,              -> { [] }
    set :docker_restart_policy,       -> { "always" }
    set :docker_links,                -> { [] }
    set :docker_labels,               -> { [] }
    set :docker_image,                -> { "#{fetch(:application)}_#{fetch(:stage)}" }
    set :docker_image_full,           -> { [fetch(:docker_image), fetch(:current_revision)].join(":") }
    set :docker_additional_options,   -> { "" }
    set :docker_copy_data,            -> { [] }
    set :docker_pass_env,             -> { [] }

    set :docker_compose,                    -> { false }
    set :docker_compose_project_name,       -> { nil }
    set :docker_compose_remove_after_stop,  -> { true }
  end
end
