module Spotlight
  class BackupsController < Spotlight::ApplicationController
    # before_action :authenticate_user!
    # load_and_authorize_resource

    def show; end

    def create
      errors = []
      timestamp = Time.now.strftime('%Y-%m-%d_%H-%M-%S')
      Spotlight::Exhibit.all.each do |exhibit|
        puts exhibit
        begin
          backup = Spotlight::FileIO.new(exhibit.export, "#{exhibit.friendly_id}-export-#{timestamp}.json")
          backups = exhibit.backups
          backups += [backup]
          exhibit.backups = backups
          exhibit.save
        rescue NoMethodError
          errors << "Could not export exhibit: #{exhibit}"
        end
      end
      redirect_to spotlight.site_backup_path, alert: errors
    end
  end

  class FileIO < StringIO
    def initialize(stream, filename)
      super(stream)
      @original_filename = filename
    end

    attr_reader :original_filename
  end
end
