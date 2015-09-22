module InitializeSlug
  def generate_slug(field_translation, array_translations)
    array_translations.each do |translation|
      slug = translation.slug
      if slug.blank?
        slug = 'needs-to-be-changed'

        unless field_translation.blank?
          if !translation[field_translation].blank?
            slug = translation[field_translation]
          elsif array_translations.any? && !array_translations.first[field_translation].blank?
            slug = array_translations.first[field_translation]
          end
        end
      end

      if need_unique_slug?(translation.class)
        slug = generate_unique_slug(translation, slug)
      end

      translation.slug = parse_url_chars(slug)
    end
  end

  def generate_unique_slug(translation, slug)
    slug_count = translation.class.where("locale = '#{I18n.locale}' AND slug like '%#{slug}%'").size
    if slug_count > 0 && slug != 'needs-to-be-changed'
      "#{slug}_#{slug_count}"
    else
      slug
    end
  end

  def need_unique_slug?(klass)
    [ProductTranslation, CategoryTranslation].include? klass
  end

  def parse_url_chars(str)
    out = str.downcase
    out = out.tr(' ', '-')

    out = URI.encode(out)
    out.gsub('%23', '#') # Restore hashtags
  end

  def slug_to_href(object)
    href = object.slug

    if !href.nil? && !link?(object.slug)
      helpers = Rails.application.routes.url_helpers

      if object.class == Category
        href = helpers.category_path(object.slug)
      elsif object.class == Product
        href = helpers.product_path(object.slug)
        if object.categories.any?
          href = helpers.category_show_product_slug_path(object.categories.first.slug, object.slug)
        end
      end
    end

    href
  end

  def link?(href)
    href.start_with?('/') || href.start_with?('#') || href.start_with?('http')
  end
end
