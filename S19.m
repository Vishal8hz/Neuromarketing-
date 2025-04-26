%% Initialization
addpath(genpath('Dependencies\'));
addpath(genpath('PreProcessedData_Sample\'));
load S19.mat % Now loading S19

%% Product Visualization
PAGE_ID = 2;
PRODUCT_ID = 15;
pageImage = imread(['ImagePage_' num2str(PAGE_ID) '.tif']);
load(['BoundingBoxPage_' num2str(PAGE_ID) '.mat']); % Loads ROI_list
imshow(pageImage), hold on
productBox = ROI_list{PRODUCT_ID};
rectangle('Position', productBox, 'EdgeColor', 'r', 'LineWidth', 3), hold off

%% EEG Processing
productEEG = {};
myProduct = S19.(strcat('Page', int2str(PAGE_ID))).(strcat('Product', int2str(PRODUCT_ID)));
for iSegment = 1 : size(myProduct.EEG_segments, 1)
    startSample = myProduct.EEG_segments(iSegment, 1);
    endSample = myProduct.EEG_segments(iSegment, 2);
    productEEG{iSegment} = S19.EEG_clean.Data(:, startSample : endSample);
end

concatenatedEEG = [];
segmentBreak = [];
for iSegment = 1 : size(myProduct.EEG_segments, 1)
    concatenatedEEG = [concatenatedEEG productEEG{iSegment}];
    segmentBreak(end+1) = size(concatenatedEEG, 2);
end
plot(concatenatedEEG'), hold on, xlabel('Samples'), ylabel('uV')
for i_break = 1 : length(segmentBreak)
    xline(segmentBreak(i_break), '-', {['End of Segment ' num2str(i_break)]});
end, hold off

%% ET Processing
productET = {};
for iSegment = 1 : size(myProduct.ET_segments, 1)
    startSample = myProduct.ET_segments(iSegment, 1);
    endSample = myProduct.ET_segments(iSegment, 2);
    productET{iSegment} = S19.ET_clean.Data([3 6], startSample : endSample); % Pupil size
end

concatenatedET = [];
segmentBreak = [];
for iSegment = 1 : size(myProduct.ET_segments, 1)
    concatenatedET = [concatenatedET productET{iSegment}];
    segmentBreak(end+1) = size(concatenatedET, 2);
end
plot(concatenatedET'), hold on, xlabel('Samples'), ylabel('Millimeters')
for i_break = 1 : length(segmentBreak)
    xline(segmentBreak(i_break), '-', {['End of Segment ' num2str(i_break)]});
end, hold off

%% Alpha Filtering
EEGFs = S19.EEG_clean.Fs;
[b, a] = butter(3, [8 12]/(EEGFs/2));
filteredEEG = filtfilt(b, a, S19.EEG_clean.Data')';

%% Bought Products
indicesBought = [];
for iPage = 1 : 6
    for iProduct = 1 : 24
        pageNo = int2str(iPage);
        productNo = int2str(iProduct);
        if S19.(strcat('Page',pageNo)).(strcat('Product',productNo)).ProductInfo.Bought == 1
            indicesBought(end+1,:) = [iPage, iProduct];
        end
    end
end

%% Filtered EEG Plot for First Bought Product
productEEG = {};
myProduct = S19.(strcat('Page', int2str(indicesBought(1,1)))).(strcat('Product', int2str(indicesBought(1,2))));
for iSegment = 1 : size(myProduct.EEG_segments, 1)
    startSample = myProduct.EEG_segments(iSegment, 1);
    endSample = myProduct.EEG_segments(iSegment, 2);
    productEEG{iSegment} = filteredEEG(:, startSample : endSample);
end

concatenatedEEG = [];
segmentBreak = [];
for iSegment = 1 : size(myProduct.EEG_segments, 1)
    if size(productEEG{iSegment},2)<EEGFs/2
        continue
    end
    concatenatedEEG = [concatenatedEEG productEEG{iSegment}];
    segmentBreak(end+1) = size(concatenatedEEG, 2);
end
plot(concatenatedEEG'), hold on, xlabel('Samples'), ylabel('uV'), ylim([-20 20])
for i_break = 1 : length(segmentBreak)
    xline(segmentBreak(i_break), '-', {['End of Segment ' num2str(i_break)]});
end, hold off
