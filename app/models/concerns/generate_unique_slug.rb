module GenerateUniqueSlug
  def self.included(base)
    base.class_eval do
      before_save :generate_unique_slug
    end
  end

  def generate_unique_slug
    count = self.class.maximum('id')
    return unless !count.nil? && slug != 'needs-to-be-changed' &&
      self.class.where("slug like '%#{slug}%'").size > 0
    self.slug = "#{slug}_#{count}"
  end
end
