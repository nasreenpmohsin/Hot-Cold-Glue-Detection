%Author: Nasreen Mohsin
%Date: 09-19-2019
close all; clear all;
imNo={'000367','002598','001496'}; % set of images
i=3; % either 1 or 2 image set
I1=im2double(imread([imNo{i},'_Channel1.jpg']));
I2=im2double(imread([imNo{i},'_Channel2.jpg']));
% I1=im2double(imread('002598_Channel1.jpg'));
% I2=im2double(imread('002598_Channel2.jpg'));
figure('Name','Image with two channels');
subplot(2,1,1);imshow(I1,[]);
title('Image with Two Types of Lighting','FontSize',14);
subplot(2,1,2);imshow(I2,[]);

I33=imadd(I1,I2);
I3=imdivide(I33,2);% average over two channels of image
figure ('Name','Averaged Image');imshow(I3);
title('Averaged Image over Two Channels','FontSize',14);
windowWidth = 7;
I3f = adapthisteq(I3, 'NumTiles', [windowWidth, windowWidth],...
    'Distribution', 'Rayleigh'); % for better contrast
figure ('Name','Adaptive Histogram Equalization');
imshow(I3f, []);  % Display image.
title('Image with better Contrast','FontSize',14);

%% Detection of white glue 
 I4=imbinarize(I3f,0.5 ); % binarize with intensity thresholding
 %figure();imshow(I4);
 %morphological open operation on image which
 %Removes small white dots having a radius less than 4 pixels 
 %by opening it with the disk-shaped structuring element.
 ser=strel('disk',5);
I5= imopen(I4,ser); %
 figure;imshow(I5)
I5=imfill(I5,'holes'); % fill holes in the image
I5f = bwareafilt(I5, [500, inf]); % filtering objects by size 
%  figure();imshow(I5f);
sed=strel('disk',6);
Fin_mask1=imdilate(I5f,sed); % Resulting mask for white glue lines
figure; imshow(Fin_mask1);
figure;imshow(I3f);
green = cat(3, zeros(size(Fin_mask1)),ones(size(Fin_mask1)), zeros(size(Fin_mask1))); 
hold on 
h = imshow(green); hold off;
set(h, 'AlphaData', Fin_mask1.*0.5);

%% Detection of hot melt glue 
I3c=I3f;
I3c(Fin_mask1)=NaN; % remove the deteced white glue lines from equalized image
% figure;imshow(I3c,[]);%colormap('hot');
I4c=imbinarize(I3c,0.4 );%binarize with intensity thresholding
% figure();imshow(I4c);
 %Removes small white dots having a radius less than 1 pixel 
 %by opening it with the disk-shaped structuring element.
sed1=strel('disk',1,0);
I5c=imopen(I4c,sed1); 
% figure();imshow(I5c);
I5c=imdilate(I5c,sed1); 
% figure();imshow(I5c);
bIm = bwareafilt(I5c, [1500, 10000]);% filtering objects by size 
% figure(); imshow(bIm);
sed1=strel('disk',5,0); % dilate the image
Fin_mask2=imdilate(bIm,sed1);% Resulting mask for hot melt glue lines
% figure; imshow(Fin_mask2);
% figure;imshow(I3f);
% red = cat(3, ones(size(Fin_mask2)),zeros(size(Fin_mask2)), zeros(size(Fin_mask2))); 
% hold on 
% h = imshow(red); hold off;
% set(h, 'AlphaData', Fin_mask2.*0.5);

%% Final Results
Fin_mask3=Fin_mask1 | Fin_mask2; % Final mask for all glue lines
CC_1=bwconncomp(Fin_mask1);% distinguishing glue lines for white glue with 8 neighbourhood connected components
CC_2=bwconncomp(Fin_mask2);% distinguishing glue lines for hot glue
extracted_glue_lines = labeloverlay(I3f,Fin_mask3);
figure('Name','Extraction of Glue Lines'); 
imshow(extracted_glue_lines);
title('Extracted Glue Lines','FontSize',14);
CC_fin=bwconncomp(Fin_mask3);
L = labelmatrix(CC_fin);
Distinct_glue_lines = labeloverlay(I3f,L,'Colormap','lines');
figure('Name','Detection of Glue Lines');  
imshow(Distinct_glue_lines);
title([num2str(CC_fin.NumObjects),' Distinct Glue Lines'],'FontSize',14);
% Labeling glues into white and hot glue lines
 L1=L;
L1(Fin_mask1)=uint8(1);
L1(Fin_mask2)=uint8(2);
Whit_hot_glue= labeloverlay(I3f,L1,'Colormap',[ 0, 0.8, 0;0.8, 0, 0]);
figure('Name','Classification of Glue Lines');  
imshow(Whit_hot_glue);
title(['Classification of Image into ',num2str(CC_1.NumObjects),' Cold White and ',num2str(CC_2.NumObjects),' Hot Melt Glue lines'],'FontSize',14);
hh(1) = line(nan, nan, 'color', 'g');
hh(2) = line(nan, nan, 'color', 'r');
lg=legend(hh,{'white','hot melt'});
title(lg,'Type of glues');
  