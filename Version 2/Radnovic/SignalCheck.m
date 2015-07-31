figure(1)
plot(sig);
figure(2);

tF=  fft(sig);
tF =tF(1:end/2);
tF = real( tF .* conj(tF));

x=(1:length(tF))/length(tF)*50000;

semilogy(x,smooth(tF))