function [heartRate,heartGraph]= pulse(filename)
frames=read(VideoReader(filename));
frameRate=VideoReader(filename).FrameRate;
%calculate average brightness for each frame as y
[height,width,~,totalFrames]=size(frames);
heartGraph(1:totalFrames)=0;
for i=1:totalFrames
    averageBrightness=double(0);
    for peakNo=1:10
        for j=1:10
            averageBrightness=averageBrightness+double(frames(height/10*peakNo,width/10*j,1,i));
        end
    end    
    heartGraph(i)=averageBrightness/100;
end
%removes first 20 frames as they are usually broken
tempy(1:totalFrames-19)=heartGraph(20:totalFrames);
heartGraph=0;
heartGraph=tempy;
totalFrames=totalFrames-19;

%calculates difference between each frame and the last, to stabalise the data
for i=2:totalFrames
    tempHeartGraph(i-1)=-heartGraph(i)+heartGraph(i-1);
end
heartGraph=tempHeartGraph;
totalFrames=totalFrames-1;

%Detecting heart rate adapted from http://www.fruct.org/publications/fruct13/files/Lau.pdf

localMax(1:totalFrames)=0;
for i=2:totalFrames-1
   if (heartGraph(i)>heartGraph(i-1))&&(heartGraph(i)>heartGraph(i+1)&&(heartGraph(i)>0))
       localMax(i)=heartGraph(i);
   end
end

%To determine the heart rate we need to find all the light peaks that are caused
%by the heart rate, these peaks are usually the tallest and have an almost constant
%distance (in time) from each other. 

%The following code finds the average difference from the mean 
%of several sets of peaks and chooses the set with the lowest difference.
%The first set is chosen by the 5 highest peaks, every next set is chosen
%by allowing another highest peak. The maximum number of peaks is however
%many peaks in the timeframe give a heart rate of 200 bpm.

maxPeaks=min(nnz(localMax),ceil(((totalFrames-4)/frameRate)*(10/3)));
variance(1:maxPeaks)=inf;
%find the difference of the mean assuming different number of peaks.
for peakNo=5:maxPeaks;
    tempx=localMax;
    for i=1:peakNo
        %Get highest peak's frame number
        [~,peakIndx(i)]=max(tempx);
        tempx(peakIndx(i))=0;
    end
    peakIndx=sort(peakIndx);
    for i=2:peakNo
        distances(i-1)=abs(peakIndx(i-1)-peakIndx(i));
    end
    variance(peakNo)=sum(abs(distances(:)-(sum(distances)/(peakNo-1))))/(peakNo-1);
end
    [~,correctPeaks]=min(variance);
    heartRate=60*(correctPeaks/(totalFrames/frameRate));
end


