function signalFiltered = notchFilter(frequency,fs,signal)
w0 = frequency/(fs/2);
bw = w0/40;
[b,a] = iirnotch(w0,bw);
signalFiltered = filtfilt(b,a,signal);
end