# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index', as: :home

  mount Administrator::Engine => '/admin'
end
