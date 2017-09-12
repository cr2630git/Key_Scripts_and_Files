%Makes autocorrelation, or distribution and autocorrelation preserving 
%surrogates. Index is the index to be tested, nsurr is the number of
%surrogates. Put 1 for mtmyes if you want to use multitaper method (0 is
%using an fft). Put 1 for distyes for a distribution and autocorrelation 
%preserving bootstrapping, 0 is just autocorrelation preserving.

%Detailed description:
%Written by Sloan Coats, now at UC-Boulder
%Produces surrogate timeseries for significance testing. 
%The inputs are the timeseries you want to make surrogates of, the number of surrogates,
%a 1 if you want to estimate the spectra that defines the surrogates using a multi-taper method
%or a zero if you want to do a straight up fft, and  then a 1 if you want to also do a
%distribution preservation step or a zero if not. The multi-taper versus straight up fft 
%doesn?t make a big difference?I messed around with this a lot to try and understand it
%but some of the behavior is still a mystery to me. As far as I can tell it is safe to just put a 
%0 down and use the straight up fft. Although tested pretty thoroughly there may be some things that are off. 
%Let me know if you end up running into anything that doesn?t make sense.

%You should be able to use the fft option and you will want to use the distribution preservation option.  
%1. Model 1000 time series.
%2. Calculate the correlations between each timeseries at all locations in the spatial field.
%3. Estimate the 95% confidence interval as the mean + 2SD of the correlations at each point.
%Given the above steps, the true correlations will be significant if they are larger than 
%the mean+2SD estimates from the bootstrapping experiment.

function [Indices]=Surrogates(Index,nsurr,mtmyes,distyes)

%
%
%
%%Setting up the output
Indices=zeros(length(Index),nsurr);

%
%
%
%%Getting the index ready:

if iscolumn(Index)==0; %making sure it is a column vector
   Index=Index';
end
        
if mod(length(Index),2)==0; %checking if it is even, if so pad with zero:
   Index=[Index;0];
end

%
%
%
%%Distribution preservation

if distyes==1; %have to fit a gaussian to the data and replace with this, there will be a second replacement step with the same heading for the surrogates
   OldIndex=Index; %saving the original index
   pd=fitdist(Index,'Normal'); %fitting the distribution
   xvals=pd.sigma*randn(length(Index),1)+pd.mu; %creating the gaussian distributed values
   [GKeep,~]=sort(xvals); %sorting gaussian
   [OrigKeep,OrigIX]=sort(Index); %sorting original
   for i=1:length(Index);
   Index(OrigIX(i))=GKeep(i); %replacing the index with the gaussian values  
   end
else
end

%
%
%
%%Surrogates

len_ser = (length(Index)-1)/2; %length and the two symmetric interval set ups
interv1 = 1:len_ser+1; 
interv2 = len_ser+2:length(Index); 

surrTS=zeros(length(Index),nsurr); %intermediate output

if mtmyes==1; %based on multi-taper method for estimating spectrum
   
   Spec=pmtm(Index,[],[0:1/length(Index):1/2],1,'adapt')'; %multi-taper spectrum set at standard ft frequencies
   Spec=[Spec;flipud(Spec(2:length(Spec)))]; %making the symmetric aplitudes
   r=sqrt(length(Index)*Spec); %scaling so that it can go into ifft, this is the amplitude
   for i=1:nsurr;
       ph_rnd = rand([len_ser+1 1]); %randomization
       ph_interv1=exp( 2*pi*1i*ph_rnd); %random phases for first half + 1
       ph_interv2=conj( flipud( ph_interv1(2:len_ser+1))); %random phases for back half
       surrSpec=r; %putting in the amplitudess
       surrSpec(interv1)=surrSpec(interv1).*ph_interv1; %multiplying the phases by the random amplitudes
       surrSpec(interv2)=surrSpec(interv2).*ph_interv2;
       surrTS(:,i)=real(ifft(surrSpec));%inverting into the time domain:
   end
   
end
   
if mtmyes==0%based on a straight up fft, can add detrend and a tapering filter later
    
   Spec=fft(Index); %standard fft estimate
   r=abs(Spec); %scaling so that it can go into ifft, this is the amplitude
   for i=1:nsurr;   
       ph_rnd = rand([len_ser+1 1]); %randomization
       ph_interv1=exp( 2*pi*1i*ph_rnd); %random phases for first half + 1
       ph_interv2=conj( flipud( ph_interv1(2:len_ser+1))); %random phases for back half
       surrSpec=r; %putting in the amplitudess
       surrSpec(interv1)=surrSpec(interv1).*ph_interv1; %multiplying the phases by the random amplitudes
       surrSpec(interv2)=surrSpec(interv2).*ph_interv2;
       surrTS(:,i)=real(ifft(surrSpec));%inverting into the time domain:
   end
end

%
%
%
%%Distribution preservation

if distyes==1; %here the values are replaced in the surrogate timeseries:
   
   for i=1:nsurr;
       [~,SIX]=sort(surrTS(:,i)); %sorting the surrogate TS
       for j=1:length(Index);
       surrTS(SIX(j),i)=OrigKeep(j); %replacing the surrogate TS with the original values
       end
   end
   
end

%
%
%
%%Saving the output
[m,n]=size(Indices);
Indices(:,:)=surrTS(1:m,:);
end