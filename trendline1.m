%function to find the trendlines and equations
% for H2O, O2, and CO2
function [a,fun] = trendline1(x,y)
% Inputs:
% x: x data in the form x=[1 2 3 4 5...]
% y: y data in the form y=[1 2 3 4 5...]
% Outputs:
% a: Coefficients of the function in the order of y = c + bx + ax^2 where
%                                     Coeff(1)=c,Coeff(2)=b,Coeff(3)=a
% Sr: Sum of the squares of the residuals
% Syx: Standard Error
% r2: Coefficient of determination
% r: Coefficient of correlation
x=x';
y=y';
        Z=[ones(size(x)) x x.^2];
        Coefficients=(Z'*Z)\(Z'*y);
        a=Coefficients;
        Sr=sum((y-Z*a).^2);
        r2=1-Sr/sum((y-mean(y)).^2);
        Syx=sqrt(Sr/(length(x)-length(a)));
        r=sqrt(r2);
        fun=@(xp)a(1)+a(2)*xp+a(3)*xp^2;

end