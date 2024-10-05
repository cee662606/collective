x=0:1/1000:4;
y1=exp(1)*(1-exp(x));
y2=exp(2)*(1-exp(x));
y3=exp(5)*(1-exp(x));
plot(x,y1,x,y2,x,y3);
ylabel('Ids(a)');
xlabel('Vds(kT/q)')