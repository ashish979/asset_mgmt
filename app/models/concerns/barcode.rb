module Barcode
  extend ActiveSupport::Concern

  included do
    after_save :create_barcode, :unless => :barcode?
  end

  def get_barcode
    bar_code = Barby::Code128B.new(self.barcode)
    outputter = Barby::SvgOutputter.new(bar_code)
    outputter.xdim,outputter.height = 1,35
    outputter.to_svg
  end

  def barcode_key
    "#{asset_type_id.to_s.rjust(4,'0')}#{id.to_s.rjust(6,'0')}"
  end

  protected 
    def create_barcode
      update_column(:barcode, barcode_key)
    end

end