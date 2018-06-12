require 'active_record'
require 'logger'

ActiveRecord::Base.logger = Logger.new($stderr) if ENV['USE_LOGGER']

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Schema.define do
  unless ActiveRecord::Base.connection.tables.include? 'masters'
    create_table :masters do |table|
      table.column :whatever,                     :string
    end
  end

  unless ActiveRecord::Base.connection.tables.include? 'slaves'
    create_table :slaves do |table|
      table.column :master_id,                    :integer
      table.column :whatever,                     :string
    end
  end

  unless ActiveRecord::Base.connection.tables.include? 'partials'
    create_table :partials do |table|
      table.column :whatever,                     :text
    end
  end
end
