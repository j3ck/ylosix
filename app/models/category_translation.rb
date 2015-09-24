# == Schema Information
#
# Table name: category_translations
#
#  category_id       :integer          not null
#  created_at        :datetime         not null
#  description       :text
#  id                :integer          not null, primary key
#  locale            :string           not null
#  meta_tags         :hstore           default({}), not null
#  name              :string
#  short_description :text
#  slug              :string
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_category_translations_on_category_id  (category_id)
#  index_category_translations_on_locale       (locale)
#

class CategoryTranslation < ActiveRecord::Base
  include GenerateUniqueSlug
  belongs_to :category
  belongs_to :language, primary_key: :locale, foreign_key: :locale
  # validates_uniqueness_of locale: { scope: :category_id }
end
