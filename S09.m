clear all
close all
clc

% Add all dependencies (Functions) to the Matlab Path
addpath(genpath('Dependencies\'));
% Add Example Data (Subject 01, chanlocs, Prodct Descriptions) to the Matlab Path
addpath(genpath('PreProcessedData_Sample\'));
load S01.mat


%% Constants
PAGE_ID = 4;
PRODUCT_ID = 21;
% load the page image
pageImage = imread(['ImagePage_' num2str(PAGE_ID) '.tif']);
% load the bounding boxes corresponding to that page.
% This adds to the workspace a cell array named ROI_list
load(['BoundingBoxPage_' num2str(PAGE_ID) '.mat']);
imshow(pageImage), hold on % show the page
productBox = ROI_list{PRODUCT_ID}; % (x, y, width, height)
% plot the bounding box of this particular product ID
rectangle('Position', productBox, 'EdgeColor', 'r', 'LineWidth', 3), hold off

%%
productEEG = {}; % Initialize a cell array for EEG
  myProduct = S01.(strcat('Page', int2str(PAGE_ID))).(strcat('Product', int2str(PRODUCT_ID)));
  for iSegment = 1 : size(myProduct.EEG_segments, 1)
      startSample = myProduct.EEG_segments(iSegment, 1);
      endSample = myProduct.EEG_segments(iSegment, 2);
      % Get the actual EEG signal
      productEEG{iSegment} = S01.EEG_clean.Data(:, startSample : endSample);
  end

  %Plot segments
  concatenatedEEG = [];
  segmentBreak = [];
  for iSegment = 1 : size(myProduct.EEG_segments, 1)
      % Concantenate EEG signals in a single variable
      concatenatedEEG = [concatenatedEEG productEEG{iSegment}];
      % Tracks where segments change so we can plot xlines
      segmentBreak(end+1) = size(concatenatedEEG, 2);
end
  plot (concatenatedEEG'), hold on, xlabel('Samples'), ylabel('uV')
  for i_break = 1 : length(segmentBreak)
      xline(segmentBreak(i_break), '-', {['End of Segment ' num2str(i_break)]});
  end, hold off

  %%
  productET = {}; % Initialize a cell array for ET
  myProduct = S01.(strcat('Page', int2str(PAGE_ID))).(strcat('Product', int2str(PRODUCT_ID)));
  for iSegment = 1 : size(myProduct.ET_segments, 1)
      startSample = myProduct.ET_segments(iSegment, 1);
      endSample = myProduct.ET_segments(iSegment, 2);
      % 3rd and 6th rows corresponds to pupil dilation of the left and right eye
      productET{iSegment} = S01.ET_clean.Data([3 6], startSample : endSample);
end
  
  %Plot segments
  concatenatedET = [];
  segmentBreak = [];
  for iSegment = 1 : size(myProduct.ET_segments, 1)
      % Concantenate dilation signals in a single variable
      concatenatedET = [concatenatedET productET{iSegment}];
      % Tracks where segments change, so we can plot xlines
      segmentBreak(end+1) = size(concatenatedET, 2);
  end

  plot (concatenatedET'), hold on, xlabel('Samples'), ylabel('Millimeters')
  for i_break = 1 : length(segmentBreak)
      xline(segmentBreak(i_break), '-', {['End of Segment ' num2str(i_break)]});
  end, hold off

  productET = {}; % Initialize a cell array for ET
  myProduct = S01.(strcat('Page', int2str(PAGE_ID))).(strcat('Product', int2str(PRODUCT_ID)));
  for iSegment = 1 : size(myProduct.ET_segments, 1)
      startSample = myProduct.ET_segments(iSegment, 1);
      endSample = myProduct.ET_segments(iSegment, 2);
      % 3rd and 6th rows corresponds to pupil dilation of the left and right eye
      productET{iSegment} = S01.ET_clean.Data([3 6], startSample : endSample);
end
  %% Plot segments
  concatenatedET = [];
  segmentBreak = [];
  for iSegment = 1 : size(myProduct.ET_segments, 1)
      % Concantenate dilation signals in a single variable
      
    concatenatedET = [concatenatedET productET{iSegment}];
      % Tracks where segments change, so we can plot xlines
      segmentBreak(end+1) = size(concatenatedET, 2);
end
  plot (concatenatedET'), hold on, xlabel('Samples'), ylabel('Millimeters')
  for i_break = 1 : length(segmentBreak)
      xline(segmentBreak(i_break), '-', {['End of Segment ' num2str(i_break)]});
  end, hold off

  EEGFs = S01.EEG_clean.Fs;
[b, a] = butter(3, [8 12]/(EEGFs/2));
filteredEEG = filtfilt(b, a, S01.EEG_clean.Data')';

indicesBought = [];
  for iPage = 1 : 6 % iterate over pages
      for iProduct = 1 : 24 % iterate over products
          pageNo = int2str(iPage);
          productNo = int2str(iProduct);
          if S01.(strcat('Page',pageNo)).(strcat('Product',productNo)).ProductInfo.Bought == 1
              % Store Page_ID and Product_ID of the products that were bought
              indicesBought(end+1,:) = [iPage, iProduct];
          end 
      end
  end

  productEEG = {}; % Initialize a cell array for EEG
myProduct = ...
S01.(strcat('Page', int2str(indicesBought(1,1))))...
.(strcat('Product', int2str(indicesBought(1,2))));
for iSegment = 1 : size(myProduct.EEG_segments, 1)
    startSample = myProduct.EEG_segments(iSegment, 1);
    endSample = myProduct.EEG_segments(iSegment, 2);
    % Get the actual EEG signal
    productEEG{iSegment} = filteredEEG(:, startSample : endSample);
end
%% Plot segments
concatenatedEEG = [];
segmentBreak = [];
for iSegment = 1 : size(myProduct.EEG_segments, 1)
    % Do not plot segments with duration smaller than half a second
    if size(productEEG{iSegment},2)<EEGFs/2
continue 
    end
    % Concantenate EEG signals in a single variable
    concatenatedEEG = [concatenatedEEG productEEG{iSegment}];
    % Tracks where segments change so we can plot xlines
    segmentBreak(end+1) = size(concatenatedEEG, 2);
end
plot (concatenatedEEG'), hold on, xlabel('Samples'), ylabel('uV'), ylim([-20 20])
for i_break = 1 : length(segmentBreak)
    xline(segmentBreak(i_break), '-', {['End of Segment ' num2str(i_break)]});
end, hold off

allDescriptions = {};
for iPage = 1 : 6 % iterate over pages
    for iProduct = 1 : 24 % iterate
        pageNo = int2str(iPage);
        productNo = int2str(iProduct);
          allDescriptions{end+1} = ...
          S01.(strcat('Page',pageNo)).(strcat('Product',productNo)).ProductInfo.Description;
    end 
end
  uniqueDescriptions = unique(allDescriptions)

  milkIDs = [];
for iPage = 1 : 6 % iterate over pages
    for iProduct = 1 : 24 % iterate
        pageNo = int2str(iPage);
        productNo = int2str(iProduct);
        if strcmp(S01.(strcat('Page',pageNo))...
           .(strcat('Product',productNo)).ProductInfo.Description, 'Milk')
            % Store Page_ID and Product_ID of the products that were bought
            milkIDs(end+1,:) = [iPage, iProduct];
        end 
    end
end
milkIDs'
