# frozen_string_literal: true

module BlogTutorial
  class App < Padrino::Application
    register Padrino::Helpers
    register VitePadrino
    enable :sessions

    layout :application

    get '/' do
      redirect '/posts'
    end
  end
end
