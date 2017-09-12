function [wbttslope,wbtqslope,wbtarray] = calcWBTslopes(inputT,inputq)
%Calculates deltaWBT/deltaT and deltaWBT/deltaq for the given T (C) and q (g/kg)
%   T (C) and q (kg/kg) must be given because WBT is nonlinear in both (but particularly in q)
%   For a spreadsheet version of this, see wbtlinearity.xlsx
%   Usage: [wbttslope,wbtqslope,wbtarray]=calcWBTslopes(30.2,13.7);

makeplots=0;


%For a wide range of T and q, calculate WBT
%It doesn't matter if some of these values are outside the range
%of plausible conditions since in that case they won't be needed anyway
startT=-15;stopT=50;
wbtarray=NaN.*ones(stopT-startT+1,36);accompRHarray=NaN.*ones(stopT-startT+1,36);
for T=startT:stopT
    for q=0:0.001:0.035
        eta=1-((T+273.15)/647.1);
        satvp=6.11*10^(7.5*T/(237.3+T)); %hPa
        satmr=0.622*satvp/1000; %kg/kg
        mr=q/(1-q); %kg/kg
        RH=mr*100/satmr; %percent
        
        %disp(T);disp(q);disp(class(T-(startT-1)));disp(class(q*1000+1));disp(T-(startT-1));disp(q*1000+1);
        if RH<=175 %a relatively physically reasonable combination of T and q
                %need to have entries in this matrix that cross the 100% line so that slopes can be calculated even
                %for observed RH's near 100%
            wbtarray(T-(startT-1),single(q*1000+1))=calcwbtfromTandshum(T,q,1);
            accompRHarray(T-(startT-1),single(q*1000+1))=RH;
        else
            wbtarray(T-(startT-1),single(q*1000+1))=NaN;
            accompRHarray(T-(startT-1),single(q*1000+1))=NaN;
        end
        %disp(T);disp(q);disp(size(wbt));
    end
end
%disp(accompRHarray(2,:));
%Find discretized slope of WBT curves at inputT and inputq
%This is found with a center-differencing approach
roundedinputT=round2(inputT,1);
roundedinputq=round2(inputq/1000,0.001); %divide by 1000 since input was in g/kg not kg/kg
curWBT=wbtarray(roundedinputT-startT,single(roundedinputq*1000)+1);

nexthigherWBTforT=wbtarray(roundedinputT+1-startT,single(roundedinputq*1000+1));

%disp(roundedinputT-1);disp(single(roundedinputq+0.001));
[~,rhnextlowerWBTforT]=calcwbtfromTandshum(roundedinputT-1,single(roundedinputq),1);
%disp(rhnextlowerWBTforT);
if rhnextlowerWBTforT>100
    nextlowerWBTforT=curWBT-(nexthigherWBTforT-curWBT); %parameterized to avoid calculating WBTs with unrealistic T/q combinations
else
    nextlowerWBTforT=wbtarray(roundedinputT-1-startT,single(roundedinputq*1000+1));
end

if roundedinputq>0
    nextlowerWBTforq=wbtarray(roundedinputT-startT,single((roundedinputq-0.001)*1000+1));
else
    nextlowerWBTforq=wbtarray(roundedinputT-startT,single(roundedinputq)*1000+1)-1;
end

[~,rhnexthigherWBTforq]=calcwbtfromTandshum(roundedinputT,single(roundedinputq+0.001),1);
if rhnexthigherWBTforq>100
    nexthigherWBTforq=curWBT+(curWBT-nextlowerWBTforq); %parameterized to avoid calculating WBTs with unrealistic T/q combinations
else
    nexthigherWBTforq=wbtarray(roundedinputT-startT,single((roundedinputq+0.001)*1000+1));
end


%disp(nexthigherWBTforT);disp(nextlowerWBTforT);
%disp(nexthigherWBTforq);disp(nextlowerWBTforq);

wbttslope=(nexthigherWBTforT-nextlowerWBTforT)/2; %K/K
wbtqslope=(nexthigherWBTforq-nextlowerWBTforq)/2; %K/(g/kg)




if makeplots==1
    figc=1;figure(figc);clf;figc=figc+1;hold on;
    colorstouse=varycolor(8);
    tvec={};wbtvec={};
    %varying T, fixed q (on each curve)
    for q=0:0.005:0.035
        validtc=0;
        for T=5:5:45
            if accompRHarray(T-4,q*1000+1)<=100 %i.e. a physically meaningful combination of T and q
                validtc=validtc+1;
                %disp(T);disp(q);disp(accompRHarray(T/5,q*200+1));
                tvec{q*200+1}(validtc)=T;
                wbtvec{q*200+1}(validtc)=wbtarray(T-4,q*1000+1);
            end
        end
        disp(squeeze(tvec{q*200+1}));disp(squeeze(wbtvec{q*200+1}));
        plot(tvec{q*200+1},wbtvec{q*200+1}(:),'color',colorstouse(q*200+1,:),'LineWidth',2);
    end
    title('WBT-T Relationship for Various q','FontSize',20,'FontName','Arial','FontWeight','bold');
    legend('q=0','q=0.005','q=0.01','q=0.015','q=0.02','q=0.025','q=0.03','q=0.035','Location','northwest',...
        'FontName','Arial');
    xlabel('Temperature (C)','FontName','Arial','FontSize',14,'FontWeight','bold');
    ylabel('Wet-Bulb Temperature (C)','FontName','Arial','FontSize',14,'FontWeight','bold');
    set(gca,'FontName','Arial','FontSize',14,'FontWeight','bold');
    
    figure(figc);clf;figc=figc+1;hold on;
    colorstouse=varycolor(9);
    qvec={};wbtvec={};
    %varying T, fixed q (on each curve)
    for T=5:5:45
        validqc=0;
        for q=0:0.005:0.035
            if accompRHarray(T-4,q*1000+1)<=100 %i.e. a physically meaningful combination of T and q
                validqc=validqc+1;
                %disp(T);disp(q);disp(accompRHarray(T/5,q*200+1));
                qvec{T/5}(validqc)=q;
                wbtvec{T/5}(validqc)=wbtarray(T-4,q*1000+1);
            end
        end
        disp(squeeze(qvec{T/5}));disp(squeeze(wbtvec{T/5}));
        plot(qvec{T/5},wbtvec{T/5}(:),'color',colorstouse(T/5,:),'LineWidth',2);
    end
    title('WBT-q Relationship for Various T','FontSize',20,'FontName','Arial','FontWeight','bold');
    legend('T=5','T=10','T=15','T=20','T=25','T=30','T=35','T=40','T=45','Location','northwest','FontName','Arial');
    xlabel('Specific Humidity (kg/kg)','FontName','Arial','FontSize',14,'FontWeight','bold');
    ylabel('Wet-Bulb Temperature (C)','FontName','Arial','FontSize',14,'FontWeight','bold');
    set(gca,'FontName','Arial','FontSize',14,'FontWeight','bold');
end

end

