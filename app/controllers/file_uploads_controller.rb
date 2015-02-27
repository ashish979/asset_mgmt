class FileUploadsController < ApplicationController
  load_resource only: :destroy
  authorize_resource

  def destroy
    @asset = @file_upload.asset
    @asset.file_uploads.build
    name = @file_upload.file_file_name
    if @file_upload.destroy
      flash.now[:notice] = "#{name} has been removed successfully"
    else
      flash.now[:alert] = "#{name} could not removed, please try again."      
    end
  end

end