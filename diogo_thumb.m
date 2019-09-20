function [I J D] = diogo_thumb(red,tips,bots);

tips = tips(4:5,:);
bots = bots(4:5,:);
% polygon will be [ABCD]
A = tips(1,:); % tip of pointer finger (first point in polygon)
D = tips(2,:); % tip of thumb (last point of polygon)
B = ( bots(1,:)-tips(1,:) ) * 0.4 + bots(1,:); B = round(B);
C = ( bots(2,:)-tips(2,:) ) * 0.4 + bots(2,:); C = round(C);

cols = [A(2) B(2) C(2) D(2)];
rows = [A(1) B(1) C(1) D(1)];

%red = 1 - red_bw; 
%blue = 1 - blue;
%bw = red .* blue;
%bw = red;
mask = roipoly(red, cols, rows);
red = 1 - red;
bw = red .* mask;

temp = zeros(size(bw)); % temp2 = zeros(size(bw));
AD = round( 0.5*A + 0.5*D);
temp(AD(1), AD(2)) = 1; % temp2(A(1), A(2)) = 1; temp2(D(1), D(2))=1;
D = bwdist(temp); %D2 = bwdist(temp2); D = D + D2;
D (bw == 0) = 0;
%imwrite(D/max(max(D)), 'D.png', 'png');

[I,J] = find( D == max(max(D)), 1, 'first');

% NOW I J must go towards A 20 pixels. LOL

x = A(1)-I;
y = A(2)-J;
total_dist = sqrt(x^2+y^2);
ratio = total_dist/20;
x = x/ratio;
y = y/ratio;
I = round(I+x);
J = round(J+y); 

