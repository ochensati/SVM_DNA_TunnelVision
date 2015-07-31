function [peakDescript] = PeakParameters(peak, runParameters, minFFTSize)

  % minFFTSize = runParameters.minimum_FFT_Size;
   if ( isstruct (peak))
       trace = peak.Trace;
   else 
       trace=peak;
   end

   amplitude = max(trace);
   averageAmplitude = mean(trace(2:(length(trace)-2)));
   roughness = var( trace(3:(length(trace)-3))  );%/averageAmplitude;
   peakwidth = length(trace);

   %pad the fft to get a normalized behavior
   if length(trace)<minFFTSize
       nZeros =floor( (minFFTSize-length(trace))/2);
       trace= [zeros([nZeros 1]);trace;zeros([nZeros 1])];
   end

   %get the fft spectrum of the peak 
   spec=abs(fft(trace));
   spec(1)=0;
   spec(2)=0;

   TotalPower  = (sum(spec));
   spec=spec./TotalPower;
   powerspec =spec.*spec;

   nComponents =9;
   peakCoef = zeros([nComponents 1]);
   specLength =length(powerspec);

   %reduce the complexity to just a few parameters.  Since the spacing is
   %only dependant on 
   for k=1:(specLength)
       bin =floor( k/(specLength)*(nComponents-1))+1;
       peakCoef(bin) = peakCoef(bin)+powerspec(k);
   end

   peakDescript =struct('Amplitude', amplitude,'AverageAmplitude',averageAmplitude,'Roughness',roughness,'Peakwidth',peakwidth,'Totalpower', TotalPower,'PeakFFTCoef', { peakCoef(1:4)});

   if ( isstruct ( peak ) )
      s=fieldnames (peak);
      for k=1:length(s)
          name=s{k};
         % if (strcmp(name,'Trace')==false && strcmp(name,'StartIndex')==false && strcmp(name,'EndIndex' )==false)
              peakDescript.(name)=peak.(name);
         % end
      end
   end
  
end
