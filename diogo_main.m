% Diogo Martins, 2011

function diogo_main(tifs_path)

% Just to check 
if nargin ~= 1 
    error('Please pass image directory as the only argument');
end

if exist(tifs_path, 'dir') ~= 7
    error('Image directory does not exist');
end

% Detect all files in tif_path
tifs = dir(tifs_path);

% Check all are .tif type
remover = [];
for i = 1 : size(tifs,1)
	if strcmp(tifs(i).name(1), '.'), remover = [remover 1];
	elseif size(tifs(i).name,2) < 4, remover = [remober 1];
	elseif ~strcmp(tifs(i).name(end-3:end),'.tif'), remover = [remover 1];
	else, remover = [remover 0];
	end
end
tifs(remover==1)=[];

N_tifs = size(tifs,1);
disp(['Found ' num2str(N_tifs) ' .tif files.']);
% Overwrite output.txt ??????????????????????????????????????????
if exist('output.txt')
	error('File output.txt already exists. Please delete it before running'); 
end

% Open output file
fid = fopen(['output.txt'], 'w');

% Run MrPixel for every image
total_time = 0;

for j = 1 : N_tifs
	tic
	fprintf([tifs(j).name '... ']);
	result = diogo_common( [tifs_path tifs(j).name], tifs(j).name );
	result = ['!,' tifs_path result];
	fprintf(fid,result);
	elapsed_time = toc;
	total_time = total_time + elapsed_time;
	disp([num2str(elapsed_time,'%.2f') ' seconds']);
end

fclose(fid);
disp(['Done with ' num2str(N_tifs) ' images in ' num2str(total_time, '%.2f') ' seconds.']);

