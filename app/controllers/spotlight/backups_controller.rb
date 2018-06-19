module Spotlight
  class BackupsController < Spotlight::ApplicationController
    # before_action :authenticate_user!
    # load_and_authorize_resource

    def show
      @backups = Backup.all.order(created_at: :desc)
    end

    def create
      backup = Exhibit.export_all
      if backup.save
        if backup.messages.empty?
          redirect_to spotlight.site_backup_path, notice: 'Backup successfully created'
        else
          redirect_to spotlight.site_backup_path, alert: backup.messages
        end
      else
        redirect_to spotlight.site_backup_path, alert: 'Backup failed to create'
      end
    end

    def restore
      messages = Exhibit.restore_all(Backup.find(params[:id]))
      redirect_to spotlight.site_backup_path, notice: messages
    end

    def restore_last
      messages = Exhibit.restore_all(Backup.last)
      redirect_to spotlight.site_backup_path, notice: messages
    end
  end
end
