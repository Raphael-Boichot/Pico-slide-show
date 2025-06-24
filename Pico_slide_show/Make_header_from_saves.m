% By Raphael BOICHOT, June 2025
% Compatible with MATLAB and GNU Octave

clc;
clear;

% Parameters
slide_show_delay_ms = 10000;
chunk_size = 3584;          % 3584 bytes per image
chunks_per_file = 30;       % 30 images per .sav file
start_offset = 8193;        % Starting byte for first chunk
block_spacing = 4096;       % Bytes between chunks
maximum_file_number = 540;  % limits data to about 2MB

% Collect save files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
listing = dir('./Saves/*.sav*');
num_files = length(listing);
total_chunks = chunks_per_file * num_files;
images = total_chunks;

% Preallocate data array
binary_data = zeros(images * chunk_size, 1, 'uint8');

% === Extract Image Data ===
disp('Extracting image data from saves');
idx = 1;

for i = 1:num_files
  filename = ['./saves/', listing(i).name];
  fid = fopen(filename, 'r');
  if fid == -1
    warning('Could not open file: %s', filename);
    continue;
  end
  binary = fread(fid, inf, 'uint8');
  fclose(fid);

  for j = 0:(chunks_per_file - 1)
    start_byte = start_offset + block_spacing * j;
    end_byte = start_byte + chunk_size - 1;
    if end_byte <= length(binary)
      binary_data(idx:idx+chunk_size-1) = binary(start_byte:end_byte);
      idx = idx + chunk_size;
    else
      warning('Skipped incomplete chunk in %s at block %d', filename, j+1);
    end
  end
end

% Trim to actual size in case some files/chunks were incomplete
binary_data = binary_data(1:idx-1);
% Collect save files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Collect image files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imagefiles = [dir('Images/*.png'); dir('Images/*.jpg'); dir('Images/*.jpeg'); dir('Images/*.bmp'); dir('Images/*.gif')];
num_files = length(imagefiles);

% === Extract Image Data ===
disp('Extracting image data from images');
for i = 1:num_files
  filename = ['./Images/', imagefiles(i).name];
  [image_OK,DATA]=image_converter(filename);
  if image_OK==1
    binary_data = [binary_data;DATA'];
    images=images+1;
  end
end
% Collect image files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% === Store Raw Binary Data ===
disp('Storing binary data');
fid = fopen('binary.dat', 'w');
fwrite(fid, binary_data, 'uint8');
fclose(fid);

% === Generate Preview Image ===
if not(length(binary_data)==0);
disp('Generating an image file for checking');
data_viewer(binary_data, 'preview.png');
end

% === Limit maximum images to 540 ===
if images>maximum_file_number
  images=maximum_file_number;
  binary_data=binary_data(1:maximum_file_number*chunk_size);
  disp('Image are limited to 540, cutting file !');
end

% === Generate Arduino Header File ===
disp('Generating header file for Arduino IDE');
fid = fopen('graphical_data.h', 'w');
fprintf(fid, 'const unsigned int images = %d;\n', images);
fprintf(fid, 'const unsigned int slide_show_delay = %d;\n\n', slide_show_delay_ms);
fprintf(fid, 'const uint8_t graphical_DATA[] = {\n');

% Format as hex table, 16 bytes per line
for i = 1:length(binary_data)
  if mod(i - 1, 16) == 0
    fprintf(fid, '  ');
  end
  fprintf(fid, '0x%02X', binary_data(i));
  if i < length(binary_data)
    fprintf(fid, ',');
  end
  if mod(i, 16) == 0
    fprintf(fid, '\n');
  else
    fprintf(fid, ' ');
  end
end

if mod(length(binary_data), 16) ~= 0
  fprintf(fid, '\n');
end

fprintf(fid, '};\n');
fclose(fid);
msgbox('Done !');
disp('Done, you can compile the code !');
