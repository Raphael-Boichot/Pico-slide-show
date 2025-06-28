function [image_OK, DATA] = image_converter(currentfilename)
  try
    pkg load image
  end

  DATA = [];
  image_OK = 0;
  close all;

  %% --- Load Image ---
  [a, map] = imread(currentfilename);
  if ~isempty(map)
    a = ind2gray(a, map);
  end
  a = a(:,:,1);  % Only 1 channel

  %% --- Format Detection and Adjustment ---
  [height, width] = size(a);

  %% --- Attempt to Detect Pixel-Perfect Upscale ---
  % List of known valid base image sizes
  known_sizes = [
  112, 128;
  112, 160;
  144, 160;
  240, 160;
  352, 160
  ];

  [height, width] = size(a);
  was_scaled = false;
  is_known_original = false;

  for k = 1:size(known_sizes, 1)
    base_h = known_sizes(k, 1);
    base_w = known_sizes(k, 2);

    % Check for exact match (1x, no scaling)
    if height == base_h && width == base_w
      is_known_original = true;
      break;
    end

    % Check if this image is an integer multiple of a known size
    if mod(height, base_h) == 0 && mod(width, base_w) == 0
      scale_h = height / base_h;
      scale_w = width / base_w;

      if scale_h == scale_w && floor(scale_h) == scale_h
        scale = scale_h;
        disp([currentfilename, ' appears to be a ', num2str(scale), 'x upscaled image. Downscaling...']);
        a = imresize(a, 1/scale, 'nearest');
        [height, width] = size(a);
        was_scaled = true;
        break;
      end
    end
  end

  % Show warning only if it's neither a known original nor scaled version
  if ~was_scaled && ~is_known_original
    disp([currentfilename, ' is not a known upscale or known format. Proceeding without rescaling.']);
  end


  %% --- Format Detection and Adjustment ---
  image_OK = 0;  % Default to rejected

  if height == 112 && width == 128
    disp([currentfilename, ' is a legit image without borders, converting...']);
    image_OK = 1;

  elseif height == 112 && width == 160
    disp([currentfilename, ' is a legit image with Photo! short borders, extracting...']);
    a = a(1:1+111, 17:17+127);
    image_OK = 1;

  elseif height == 144 && width == 160
    disp([currentfilename, ' is a legit image with borders, extracting...']);
    a = a(17:17+111, 17:17+127);
    image_OK = 1;

  elseif height == 240 && width == 160
    disp([currentfilename, ' is a legit image with wild borders, extracting...']);
    a = a(49:49+111, 17:17+127);
    image_OK = 1;

  elseif height == 352 && width == 160
    disp([currentfilename, ' is a legit image with Photo! wild borders, extracting...']);
    a = a(113:113+111, 17:17+127);
    image_OK = 1;

  else
    disp([currentfilename, ' has unsupported dimensions and is rejected.']);
    [height, width] = size(a)
    return;
  end

  %% --- Validate Color Palette ---
  C = unique(a);
  if length(C) == 1 || length(C) > 4
    disp([currentfilename, ' rejected due to invalid color count.']);
    image_OK = 0;
    return;
  end

  %% --- Map Colors to Levels ---
  switch length(C)
    case 4
      Black = C(1); Dgray = C(2); Lgray = C(3); White = C(4);
    case 3
      Black = C(1); Dgray = C(2); Lgray = [];   White = C(3);
    case 2
      Black = C(1); Dgray = [];   Lgray = [];   White = C(2);
    end

    %% --- Tile Conversion ---
    [height, width] = size(a);
    hor_tile = width / 8;
    vert_tile = height / 8;
    total_tiles = hor_tile * vert_tile;

    DATA = zeros(1, total_tiles * 16, 'uint8');  % Preallocate
    data_index = 1;
    pow2 = uint8(2.^(7:-1:0));  % Reuse

    for y_tile = 1:vert_tile
      for x_tile = 1:hor_tile
        H = (y_tile - 1) * 8 + 1;
        L = (x_tile - 1) * 8 + 1;
        block = a(H:H+7, L:L+7);

        for i = 1:8
          row = block(i, :);

          V1 = uint8((~isempty(Lgray) & (row == Lgray)) | (row == Black));
          V2 = uint8((~isempty(Dgray) & (row == Dgray)) | (row == Black));

          DATA(data_index)     = sum(V1 .* pow2);
          DATA(data_index + 1) = sum(V2 .* pow2);
          data_index = data_index + 2;
        end
      end
    end
  end

