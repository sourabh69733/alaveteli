# -*- encoding : utf-8 -*-
class AddDeliveryStatusToMailServerLogs < !rails5? ? ActiveRecord::Migration : ActiveRecord::Migration[4.2] # 3.2
  def up
    add_column :mail_server_logs, :delivery_status, :string
  end

  def down
    remove_column :mail_server_logs, :delivery_status
  end
end
