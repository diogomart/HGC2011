% Diogo Martins, 2011

function result = diogo_common(img, img_id)

result = img_id;

xy = zeros(9,2); % i,j coordinates (will be converted later)

props = struct(); % properties of image elements
props = setfield(props, 'init', []);
props = setfield(props, 'palm', []);
props = setfield(props, 'fingers', []);
props = setfield(props, 'blue', []);

% binarize
img = imread(img); % read
red = img(:,:,1);
blue = img(:,:,3); % agressive binarization!
bF = 1;
 
[red_bw red_palm red_fingers red_D] = basic(red, bF);
[blue_bw blue_palm blue_fingers blue_D] = basic(blue, bF);
props.palm = bw2props(red_palm);
props.fingers = bw2props(red_fingers);
[img_out tips bots] = diogo_final(red_fingers, red_D, props);
img_fingers = red_fingers;
if size(tips,1) < 5
[tips, bots, img_out, img_fingers] = advanced(tips, blue, red_fingers, props, img_id, red_D);
end
if size(tips,1) < 5, bF = 0.7;
	[red_bw red_palm img_fingers red_D] = basic(red, bF);
	props.palm = bw2props(red_palm);
	props.fingers = bw2props(img_fingers);
	[img_out tips bots] = diogo_final(img_fingers, red_D, props);
	if size(tips,1) < 5
		[tips, bots, img_out, img_fingers] = advanced(tips, blue, img_fingers, props, img_id, red_D);
	end
end

if size(tips,1) > 4
	correct_order = diogo_spin(bots); % arm is last here
	tips = tips(correct_order,:); tips = tips(1:5,:);
	bots = bots(correct_order,:); bots = bots(1:5,:);
	[Yv4 Xv4 img_thumb] = diogo_thumb(red_bw, tips, bots);
	xy(1:5,:) = tips;
	botsout = zeros(4,2);
	for i = 1 : 4
		botsout(i,:) = 0.5*bots(i,:)+0.5*bots(i+1,:);
	end
	botsout(4,:) = [Yv4 Xv4];
	xy(6:9,:) = botsout;
else % only tips
	if size(tips,2)
		xy(1:size(tips,1),:) = tips;
	end
end
props.fingers = bw2props(img_fingers);
props.palm = bw2props(red_palm);
napalm = props.palm(1,1);
result = [result xy2result(xy) ',?\n'];

% *-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%
% INTERNAL FUNCTION - determine properties
function [tips, bots, img_out, img_fingers] = advanced(tips, blue, img_fingers, props, img_id, red_D)
N_preds = size(tips,1);
give_up = 0;
unclust = img_fingers;
while N_preds < 5
	give_up = give_up + 1; if give_up > 3, break;end 
	unclust = diogo_blue(unclust, blue, props, img_id);
	props.fingers = bw2props(unclust);
	[img_out tips bots] = diogo_final(unclust, red_D, props);
	N_preds = size(tips,1); 
end
if give_up == 4
	dil = imclose(unclust, strel('disk', 6));
	dil = dil-unclust;
	dil = imclose(dil, strel('disk',4));
	props.blue = bw2props2(dil,red_D);
	[img_2blue closed_holes] = diogo_2blue(unclust, dil, red_D, props);
	img_2blue = im2bw(img_2blue, graythresh(img_2blue));
	unclust = img_2blue; % to appear in props.fingers
	if size(closed_holes,1)>0
		props.fingers = bw2props(img_2blue); %disp(props.fingers)
		[img_out tips bots] = diogo_final(img_2blue, red_D, props);
	end 
end
img_fingers = unclust; % to appear in props.fingers


function [bw img_palm img_fingers img_D] = basic(img, F) 

level = graythresh(img); % Otsu's method
bw = im2bw(img, F * level); % binary!
bw = imopen(bw, strel('disk', round((sqrt(sum(sum(bw)))/3.14)/20))); % kill tiny objects
areaInit = sum(sum(bw));

% find hand palm
finger_width = round(sqrt(areaInit/3.14)/(4*F)); %estimate finger size before erosion %%% 4 before, now 7
se = strel('disk',finger_width);
img_palm = imopen(bw,se);
props.palm = bw2props(img_palm);


% Find palm
lbl_palm = bwlabel(img_palm);
if size(props.palm,1) > 1
	% Check biggest object ( at least 2 times bigger than all other)
	c = 1;
	bigst = find(props.palm(:,1) == max(props.palm(:,1)));
	for k = 1 : size(props.palm,1)
		if k ~= bigst
			if props.palm(bigst,1) <= 2 * props.palm(k,1), c = 0; end
		end
	end
	if c % We found a palm 2 times bigger than all the other
		d = zeros(size(props.palm(:,1)));
		d(bigst) = 1;
		props.palm(d==0,:)=[];
	else % find the less eccentric one...
		bigst = find(props.palm(:,5) == min(props.palm(:,5)));
		d = zeros(size(props.palm(:,1)));
		d(bigst) = 1;
		props.palm(d==0,:)=[];

	end
	% get number of object
	obj = find(d(:,1)==1);
	img_palm(lbl_palm ~= obj) = 0;	 
end
img_D = bwdist(img_palm);

% gravity center
img_fingers = bw - img_palm;
img_fingers = imopen(img_fingers,strel('disk',11)); % cleans stupid objects

function props = bw2props(bw)
props = [];
lbl = bwlabel(bw,4); 
n = max(max(lbl)); % number of objects
s = regionprops(lbl, 'Area', 'Perimeter', 'ConvexArea', 'EulerNumber', 'Eccentricity', 'MajorAxisLength', 'MinorAxisLength');
for i = 1 : n
	props(i, :) = [s(i).Area, s(i).Perimeter, s(i).ConvexArea, s(i).EulerNumber, s(i).Eccentricity, s(i).MajorAxisLength, s(i).MinorAxisLength];
end
function props = bw2props2(bw,D)
props = [];
lbl = bwlabel(bw,8); % USE 8 CONNECTIVITY 
n = max(max(lbl)); % number of objects
s = regionprops(lbl, 'Area', 'MajorAxisLength', 'MinorAxisLength', 'Orientation');
for i = 1 : n
	temp = D; temp(lbl ~= i)=0;
	[x1 y1] = find(temp == max(max(temp)),1,'first');
	temp(lbl ~= i) = 9999;
	[x2 y2] = find(temp == min(min(temp)),1,'first');
	ori2 = sqrt( (x1-x2)^2 + (y1-y2)^2 );
	props(i, :) = [s(i).Area, s(i).MajorAxisLength, s(i).MinorAxisLength, s(i).Orientation, ori2];
end


% INTERNAL FUNCTION - write output
function result_body = xy2result(xy)

result_body='';
xy = [xy(:,2) xy(:,1)]; % for X Y coordinates from top left corner
xy = round(xy); % almost for sure
for i = 1 : 9
	if i <= 5
		if sum(xy(i,:)) > 0
			result_body = [result_body ',T ' num2str(xy(i,1)) ' ' num2str(xy(i,2))];
		end
	else
		if sum(xy(i,:)) > 0
			result_body = [result_body ',V ' num2str(xy(i,1)) ' ' num2str(xy(i,2))];
		end
	end
end

% area_fingers > 0.1667*A_palm-3335
% area_fingers < 0.14*A_palm+2000
