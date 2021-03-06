# frozen_string_literal: true
# Kudos to https://gist.github.com/hopsoft/56ba6f55fe48ad7f8b90

namespace :db do
  desc 'Dumps the database to db/APP_NAME.dump'
  task :dump => :environment do
    cmd = nil
    with_config do |app, host, port, db|
      cmd = "pg_dump --host #{host} --port #{port} --verbose --clean --no-owner --no-acl --format=c #{db} > #{Rails.root}/db/#{app}.dump"
    end
    puts cmd
    exec cmd
  end

  desc 'Restores the database dump at db/APP_NAME.dump.'
  task :restore => :environment do
    cmd = nil
    with_config do |app, host, port, db|
      cmd = "pg_restore --verbose --host #{host} --port #{port} --clean --no-owner --no-acl --dbname #{db} '#{Rails.root}/db/#{app}.dump'"
    end
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    puts cmd
    exec cmd
    Rake::Task['db:environment:set'].invoke
  end

  desc "Heroku release phase"
  task :release_phase  => :environment do
    # If no tables, skip this. Otherwise, run migrations
    puts 'Running release phase script'
    if ActiveRecord::Base.connection.tables.any?
      puts 'Release phase - Migrating DB'
      Rake::Task["db:migrate"].invoke
    end
  end

  private

  def with_config
    yield Rails.application.class.parent_name.underscore,
      ActiveRecord::Base.connection_config[:host],
      ActiveRecord::Base.connection_config[:port],
      ActiveRecord::Base.connection_config[:database]
  end
end
