%By Raphaël BOICHOT, june 2025
%can be run with Matlab or GNU Octave
clc
clear
slide_show_delay_ms=1000;
listing = dir('./saves/*.sav*');
binary=[];
binary_data=[];
images=30*length(listing);
disp('Extracting image data from saves')
for i=1:1:length(listing)
  name=['./saves/',listing(i).name];
  fid = fopen(name,'r');
  binary=fread(fid);
  for i=1:1:30
    start=8193+4096*(i-1);
    ending=start+3583;
    binary_data=[binary_data;binary(start:ending)];
  end
  fclose(fid);
end

disp('Storing binary data')
fid = fopen('binary.dat','w');
fwrite(fid,binary_data);
fclose(fid);

disp('Generating header file for Arduino IDE')

fid = fopen('binary.dat','r');
binary_data=fread(fid);
fclose(fid);

fid=fopen('graphical_data.h','w');
counter=0;

fprintf(fid,'const unsigned int images = ');
fprintf(fid,'%d',images);
fprintf(fid,';');
fprintf(fid,'\n');
fprintf(fid,'const unsigned int slide_show_delay = ');
fprintf(fid,'%d',slide_show_delay_ms);
fprintf(fid,';');
fprintf(fid,'\n\r');


fprintf(fid,'const byte graphical_DATA[] = {');
for i=1:1:length(binary_data)
       counter=counter+1;
       fprintf(fid,'0x');
       if binary_data(i)<=0xF; fprintf(fid,'0');end;
      fprintf(fid,'%X',binary_data(i));
      fprintf(fid,',');
      if rem(counter,16)==0;fprintf(fid,'\n'); end;
end
fseek(fid,-2,'cof');
fprintf(fid,'};');
fclose(fid);
disp('Done, you can compile the code')
