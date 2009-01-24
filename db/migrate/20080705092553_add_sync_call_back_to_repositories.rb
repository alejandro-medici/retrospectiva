class AddSyncCallBackToRepositories < ActiveRecord::Migration
  def self.up
    add_column :repositories, :sync_callback, :string, :limit => 255
    repositories = select_all "SELECT id, path FROM repositories WHERE use_svnsync = #{quote(true)}"
    repositories.each do |record|
      execute "UPDATE repositories SET sync_callback = '/usr/bin/env svnsync sync file://#{repos['path']}' WHERE id = #{repos['id']}"
    end
  end

  def self.down
    remove_column :repositories, :sync_callback
  end
end
