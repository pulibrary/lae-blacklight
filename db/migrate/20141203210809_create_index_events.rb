class CreateIndexEvents < ActiveRecord::Migration
  def change
    create_table :index_events do |t|
      t.datetime :start
      t.datetime :finish
      t.boolean :success
      t.text :error_text
      t.string :task
    end
  end
end
