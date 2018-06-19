module Spotlight
  class Backup < ApplicationRecord
    mount_uploaders :files, BackupUploader
  end
end
