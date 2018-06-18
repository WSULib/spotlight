module Spotlight
  module ExhibitBackups
    extend ActiveSupport::Concern

    included do
      mount_uploaders :backups, BackupUploader
    end

    class_methods do
      def export_all
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
        errors
      end
    end

    def export
      JSON.pretty_generate(ExhibitExportSerializer.new(self).as_json)
    end
  end
end
