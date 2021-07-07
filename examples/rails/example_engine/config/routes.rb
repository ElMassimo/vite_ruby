# frozen_string_literal: true

Administrator::Engine.routes.draw do
  get '/', to: 'timer#index'
end
