# frozen_string_literal: true

module Administrator
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
