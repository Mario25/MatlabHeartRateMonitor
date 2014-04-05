function [heartRate,heartGraph]= pulse(filename)
frames=read(VideoReader(filename));
frameRate=VideoReader(filename).FrameRate;
%calculate average brightness for each frame as y
[h,w,~,f]=size(frames);
heartGraph(1:f)=0;
for i=1:f
    q=double(0);
    for k=1:10
        for j=1:10
            q=q+double(frames(h/10*k,w/10*j,1,i));
        end
    end    
    heartGraph(i)=q/100;
end
%removes first 20 frames as they are usually broken
tempy(1:f-19)=heartGraph(20:f);
heartGraph=0;
heartGraph=tempy;
f=f-19;

%calculates difference between each frame and the last, to stabalise the data
for i=2:f
    a(i-1)=-heartGraph(i)+heartGraph(i-1);
end
heartGraph=a;
f=f-1;

%Detecting heart rate adapted from http://www.fruct.org/publications/fruct13/files/Lau.pdf
%Not yet finished, but the graphs look cool

%x is array of max values
x(1:f)=0;
for i=2:f-1
   if (heartGraph(i)>heartGraph(i-1))&&(heartGraph(i)>heartGraph(i+1)&&(heartGraph(i)>0))
       x(i)=heartGraph(i);
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

maxPeaks=min(nnz(x),ceil(((f-4)/frameRate)*(10/3)));
variance(1:maxPeaks)=inf;
for k=5:maxPeaks;
    tempx=x;
    for i=1:k
        [~,peakIndx(i)]=max(tempx);
        tempx(peakIndx(i))=0;
    end
    peakIndx=sort(peakIndx);
    for i=2:k
        distances(i-1)=abs(peakIndx(i-1)-peakIndx(i));
    end
    variance(k)=sum(abs(distances(:)-(sum(distances)/(k-1))))/(k-1);
end
    [~,correctPeaks]=min(variance);
    heartRate=60*(correctPeaks/(f/frameRate));
end


