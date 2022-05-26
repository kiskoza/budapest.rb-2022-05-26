require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

ActiveRecord::Schema.define do
  create_table :children, force: true do |t|
    t.string :first_name
    t.string :last_name
  end
end

class Child < ActiveRecord::Base
end
