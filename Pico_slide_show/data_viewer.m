function data_viewer(binary_data, name)
  PACKET_image_width = 128;
  PACKET_image_height = 112;
  tile_size = 16;
  tiles_per_image = PACKET_image_width * PACKET_image_height / 64;  % each tile = 8x8 = 64 pixels

  total_tiles = floor(length(binary_data) / tile_size);
  total_images = floor(total_tiles / tiles_per_image);

  % Process only complete images
  usable_tiles = total_images * tiles_per_image;
  GB_tile = binary_data(1:usable_tiles * tile_size);

  % Reconstruct the full frame
  full_frame = ram_decode(GB_tile, PACKET_image_width, PACKET_image_height * total_images);

  % Convert to grayscale values
  gray_frame = (full_frame == 3) * 255 + (full_frame == 2) * 125 + (full_frame == 1) * 80;

  % Split into sub-images
  images = cell(1, total_images);
  for i = 1:total_images
    start_row = (i - 1) * PACKET_image_height + 1;
    end_row = i * PACKET_image_height;
    images{i} = gray_frame(start_row:end_row, :);
  end

  % Grid layout: 15 images per column
  images_per_column = 15;
  num_columns = ceil(total_images / images_per_column);
  total_slots = num_columns * images_per_column;

  % Fill empty slots with magenta (use RGB image)
  image_height = PACKET_image_height;
  image_width = PACKET_image_width;

  canvas_height = images_per_column * image_height;
  canvas_width = num_columns * image_width;
  canvas = uint8(zeros(canvas_height, canvas_width, 3));  % RGB

  % Fill canvas with magenta
  canvas(:, :, 1) = 255; % R
  canvas(:, :, 2) = 0;   % G
  canvas(:, :, 3) = 255; % B

  % Paste each image into the canvas
  for idx = 1:total_images
    col = floor((idx - 1) / images_per_column);
    row = mod((idx - 1), images_per_column);

    y_start = row * image_height + 1;
    y_end = y_start + image_height - 1;

    x_start = col * image_width + 1;
    x_end = x_start + image_width - 1;

    gray_img = images{idx};

    canvas(y_start:y_end, x_start:x_end, 1) = gray_img;
    canvas(y_start:y_end, x_start:x_end, 2) = gray_img;
    canvas(y_start:y_end, x_start:x_end, 3) = gray_img;
  end

  imwrite(canvas, name);

  disp('Images arranged and written to PNG file');
  disp('Done!');
end

