module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, :as => :resource
  end
end