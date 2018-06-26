module Spotlight
  module ExhibitBackups
    extend ActiveSupport::Concern
    include Rails.application.routes.url_helpers

    included do
      mount_uploaders :backups, BackupUploader
    end

    class_methods do
      def export_all
        backups = []
        messages = []
        timestamp = Time.now.strftime('%Y-%m-%d_%H-%M-%S')
        Spotlight::Exhibit.all.each do |exhibit|
          puts exhibit
          begin
            backups << FileIO.new(exhibit.export, "#{exhibit.friendly_id}-export-#{timestamp}.json")
          rescue NoMethodError
            messages << "Could not export exhibit: #{exhibit}"
          end
        end
        Backup.new(files: backups, messages: messages)
      end

      def restore_all(backup)
        messages = []
        backup.files.each do |file|
          update = true
          slug = file.file.filename.gsub(/-export-.+/, '')
          exhibit = Spotlight::Exhibit.find_by_slug(slug)
          # Create new exhibit if exhibit doesn't exist
          if exhibit.present?
            # Clear out exhibit uploaded files and database entries
            exhibit.purge_resources
          else
            exhibit = Spotlight::Exhibit.new(slug: slug) unless exhibit.present?
            update = false
          end
          exhibit.import(JSON.parse(file.read))
          if exhibit.save! && exhibit.reindex_later
            message = update ? "Updated exhibit #{slug}" : "Created exhibit #{slug}"
          else
            message = update ? "Failed to update exhibit #{slug}" : "Failed to create exhibit #{slug}"
          end
          exhibit.cleanup_solr_document_sidecars
          puts message
          messages << message
        end
        messages
      end
    end

    def export
      JSON.pretty_generate(ExhibitExportSerializer.new(self).as_json)
    end

    def purge_resources
      self.resources.each(&:purge)
      self.masthead.destroy if self.masthead.present?
      self.thumbnail.destroy if self.thumbnail.present?
      self.cleanup_solr_document_sidecars
    end

    def cleanup_solr_document_sidecars
      self.solr_document_sidecars.each do |s|
        s.destroy if s.resource.nil?
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
end
