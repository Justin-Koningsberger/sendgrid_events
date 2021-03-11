class AddSgEventIdToSgEvents < ActiveRecord::Migration[5.1]
  def change
    add_index :sg_events, :sg_event_id, unique: true
  end
end
