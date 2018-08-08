module Spotlight
  module ExhibitHelpers
    def default_exhibit
      Exhibit.find_by_slug('default')
    end

    def default_exhibit?
      default_exhibit == @exhibit || default_exhibit == (defined?(exhibit) ? exhibit : nil)
    end

    def home_page?
      default_exhibit? && @page.instance_of?(Spotlight::HomePage)
    end

    ##
    # Render classes for the <body> element
    # @return [String]
    def render_exhibit_class
      extra_exhibit_classes.join " "
    end

    ##
    # List of classes to be applied to the <body> element
    # @see render_body_class
    # @return [Array<String>]
    def extra_exhibit_classes
      @extra_exhibit_classes ||= @exhibit.present? && @page.present? ? ['blacklight-page-' + [@exhibit.slug, @page.slug].join('-')] : []
    end
  end
end
