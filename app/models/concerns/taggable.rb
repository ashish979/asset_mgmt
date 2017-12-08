module Taggable
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :tags
    before_save :add_tags
    attr_accessor :tags_field  
  end

  #Used to add tags, and make enteries in assets_tags table, will also check if the tag exists or not
  def add_tags
    unless tags_field.blank?
      tag_names = tags_field.split(",")
      tag_names.each do |tag|
        tags << company.tags.where(name: tag.strip).first_or_initialize
      end
    end   
  end

  def remove_tags(id)
    tags.delete(id)
  end

end