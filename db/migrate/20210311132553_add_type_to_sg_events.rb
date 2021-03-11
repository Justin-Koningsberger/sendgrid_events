class AddTypeToSgEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :sg_events, :event, :string
  end
end
