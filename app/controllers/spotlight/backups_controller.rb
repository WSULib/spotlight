module Spotlight
  class BackupsController < Spotlight::ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource

    require 'zipline'
    # enable streaming responses
    include ActionController::Streaming
    # enable zipline
    include Zipline

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
      if Backup.last.present?
        app_core = ENV['SOLR_URL'].split('/').last
        imported_core = restore_params[:core]
        if app_core == imported_core
          messages = Exhibit.restore_all(Backup.last)
        else
          messages = ["Imported core \"#{imported_core}\" does not match app core \"#{app_core}\""]
        end
      else
        messages = ['No backups exist']
      end
      redirect_to spotlight.site_backup_path, notice: messages
    end

    def download
      backup = Backup.find(params[:id])
      timestamp = Backup.find(params[:id]).created_at.strftime('%Y-%m-%d_%H-%M-%S')
      files = backup.files.map {|file| [file, file.file.filename]}
      zipline(files, "exhibits-backup-#{timestamp}.zip")
    end

    private

    def restore_params
      params.permit(:core)
    end
  end
end
