module Spotlight
  class BackupsController < Spotlight::ApplicationController
    # before_action :authenticate_user!
    # load_and_authorize_resource

    def show; end

    def create
      errors = Exhibit.export_all
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
