module Spotlight
  module ExhibitHelpers
    def default_exhibit
      Exhibit.find_by_slug('default')
    end

    def default_exhibit?
      default_exhibit == @exhibit || default_exhibit == exhibit
    end
  end
end
