# frozen_string_literal: true

BlogTutorial::App.controllers :posts do
  get :index do
    render 'posts/index'
  end
end
