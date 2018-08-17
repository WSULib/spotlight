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
      if @exhibit.present? && @page.present?
        @extra_exhibit_classes ||= @exhibit.present? && @page.present? ? ['blacklight-page-' + [@exhibit.slug, @page.slug].join('-')] : []
        @extra_exhibit_classes << ['site-home'] if home_page?
      else
        @extra_exhibit_classes ||= []
      end
      @extra_exhibit_classes
    end

    def background_image_url(exhibit)
      return unless exhibit.thumbnail.present?
      exhibit.thumbnail.source_image.image.url
    end
  end
end
