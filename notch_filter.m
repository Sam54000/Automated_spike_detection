
function [x, FiltSpec, Messages] = notch_filter(x, sfreq, FreqList, Method, bandWidth)
    % Check list of freq to remove
    if isempty(FreqList) || isequal(FreqList, 0)
        return;
    end
    if (nargin < 5) || isempty(bandWidth)
        bandWidth = 1 ;  % Default bandwidth in Hz
    end
    if (nargin < 4) || isempty(Method)
        Method = 'hnotch' ;
    end
    % Define a default width
    % Remove the mean of the data before filtering
    %no need, high passs filter before
    % Remove all the frequencies sequencially
    for ifreq = 1:length(FreqList)
        % Define coefficients of an IIR notch filter
        w0 = 2 * pi * FreqList(ifreq) / sfreq;      %Normalized notch frequncy
        % Pole radius
        switch Method
            case 'hnotch' % (Default after 2019)  radius by a user defined bandwidth (-3dB)
                beta  = cos(w0) ; 
                Bw    = (2 * pi * bandWidth) / sfreq ;   % bandwidth in radians
                alpha = -((-(cos(Bw) - 1)*(cos(Bw) + 1))^(1/2) - 1)/cos(Bw) ; 
                % Gain factor
                B0    = (1+alpha)/2 ; 
                % Numerator coefficients
                B     = B0 * [1 -2*beta 1] ; 
                % Denominator coefficients
                A     = [1 -beta*(1+alpha) alpha] ;
                
            case 'fixed-width'    % radius using a fixed bandwidth (before 2019)
                FreqWidth = 1;
                delta     = FreqWidth/2;
                r         = 1 - (delta * pi / sfreq);
                % Gain factor
                B0 = abs(1 - 2*r*cos(w0) + r^2) / (2*abs(1-cos(w0)));
                % Numerator coefficients
                B = B0 * [1, -2*cos(w0), 1];
                % Denominator coefficients
                A = [1, -2*r*cos(w0), r^2];
        end

        % Output structure
        FiltSpec.b(ifreq,:) = B;
        FiltSpec.a(ifreq,:) = A;
        
        % Filter signal
        if ~isempty(x)
                x = filtfilt(B,A,x')';
        end
    end
    % Restore the mean of the signal

    
    % Find the general transfer function
    Num1 = FiltSpec.b';
    Den1 = FiltSpec.a';
    tmpn = (size(Num1,1)-1)*size(Num1,2)+1;
    FiltSpec.NumT  = ifft(prod(fft(Num1,tmpn),2),'symmetric');
    FiltSpec.DenT  = ifft(prod(fft(Den1,tmpn),2),'symmetric');
    FiltSpec.order = length(FiltSpec.DenT)-1;
    if bst_get('UseSigProcToolbox')
        [h,t] = impz(FiltSpec.NumT,FiltSpec.DenT,[],sfreq);
    else
        [h,t] = oc_impz(FiltSpec.NumT,FiltSpec.DenT,[],sfreq);
    end
    % Compute the cumulative energy of the impulse response
    E = h(1:end) .^ 2 ;
    E = cumsum(E) ;
    E = E ./ max(E) ;
    % Compute the effective transient: Number of samples necessary for having 99% of the impulse response energy
    [tmp, iE99] = min(abs(E - 0.99)) ;
    FiltSpec.transient      = iE99 / sfreq ;
    Messages = [] ; 
end