# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  mount Administrator::Engine => '/admin'
end
