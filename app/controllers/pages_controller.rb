class PagesController < ApplicationController
  include HighVoltage::StaticPage

  layout :layout_for_page

  private

  def layout_for_page
    # case params[:id]
    # when 'home' # if we want a different layout, here's how
    #    'home'
    # else
      'application'
    # end
  end
end
