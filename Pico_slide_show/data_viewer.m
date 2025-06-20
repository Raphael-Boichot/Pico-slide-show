function data_viewer(binary_data,name)
  PACKET_image_width = 128;
  tiles = floor(length(binary_data) / 16);
  PACKET_image_height = round(8 * tiles / (PACKET_image_width / 8));

  GB_tile = binary_data(1:16*tiles);
  frame = ram_decode(GB_tile, PACKET_image_width, PACKET_image_height);

  frame_png = (frame==3)*255 + (frame==2)*125 + (frame==1)*80 + (frame==0)*0;
  imwrite(uint8(frame_png), name);

  disp('Ram extracted to png file');
  disp('Done !');
end
