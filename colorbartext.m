%Originally created just to save space in maptwbtorqscores loop of exploratorydataanalysis

exist flexibleupperbound;
if ans==0;flexibleupperbound=0;end

if numplotsinfig==1
    xpos=1.07;ypos8=[0.9375;0.8125;0.6875;0.5625;0.4375;0.3125;0.1875;0.0625];
    ypos6=[0.9166;0.75;0.5833;0.4166;0.25;0.0833];
elseif numplotsinfig==2
    xpos=1.18;a=0.19;ypos8=[1.65+a;6*1.65/7+a;5*1.65/7+a;4*1.65/7+a;3*1.65/7+a;2*1.65/7+a;1.65/7+a;0+a];
    ypos6=[0.9166;0.75;0.5833;0.4166;0.25;0.0833];
end

if numcolors==8
    text(xpos,ypos8(1),strcat(num2str(round2(bottomofrange,prec)),'-',num2str(round2(bottomofrange+interval,prec))),...
        'units','normalized','fontsize',14,'fontweight','bold','fontname','arial');
    text(xpos,ypos8(2),strcat(num2str(round2(bottomofrange+interval,prec)),'-',num2str(round2(bottomofrange+2*interval,prec))),...
        'units','normalized','fontsize',14,'fontweight','bold','fontname','arial');
    text(xpos,ypos8(3),strcat(num2str(round2(bottomofrange+2*interval,prec)),'-',num2str(round2(bottomofrange+3*interval,prec))),...
        'units','normalized','fontsize',14,'fontweight','bold','fontname','arial');
    text(xpos,ypos8(4),strcat(num2str(round2(bottomofrange+3*interval,prec)),'-',num2str(round2(bottomofrange+4*interval,prec))),...
        'units','normalized','fontsize',14,'fontweight','bold','fontname','arial');
    text(xpos,ypos8(5),strcat(num2str(round2(bottomofrange+4*interval,prec)),'-',num2str(round2(bottomofrange+5*interval,prec))),...
        'units','normalized','fontsize',14,'fontweight','bold','fontname','arial');
    text(xpos,ypos8(6),strcat(num2str(round2(bottomofrange+5*interval,prec)),'-',num2str(round2(bottomofrange+6*interval,prec))),...
        'units','normalized','fontsize',14,'fontweight','bold','fontname','arial');
    text(xpos,ypos8(7),strcat(num2str(round2(bottomofrange+6*interval,prec)),'-',num2str(round2(bottomofrange+7*interval,prec))),...
        'units','normalized','fontsize',14,'fontweight','bold','fontname','arial');
    if flexibleupperbound==1
        text(xpos,ypos8(8),strcat('>=',num2str(round2(bottomofrange+7*interval,prec))),...
        'units','normalized','fontsize',14,'fontweight','bold','fontname','arial');
    else
        text(xpos,ypos8(8),strcat(num2str(round2(bottomofrange+7*interval,prec)),'-',num2str(round2(bottomofrange+8*interval,prec))),...
        'units','normalized','fontsize',14,'fontweight','bold','fontname','arial');
    end
elseif numcolors==6
    text(xpos,ypos6(1),strcat(num2str(round2(bottomofrange,prec)),'-',num2str(round2(bottomofrange+interval,prec))),...
        'units','normalized','fontsize',14,'fontweight','bold','fontname','arial');
    text(xpos,ypos6(2),strcat(num2str(round2(bottomofrange+interval,prec)),'-',num2str(round2(bottomofrange+2*interval,prec))),...
        'units','normalized','fontsize',14,'fontweight','bold','fontname','arial');
    text(xpos,ypos6(3),strcat(num2str(round2(bottomofrange+2*interval,prec)),'-',num2str(round2(bottomofrange+3*interval,prec))),...
        'units','normalized','fontsize',14,'fontweight','bold','fontname','arial');
    text(xpos,ypos6(4),strcat(num2str(round2(bottomofrange+3*interval,prec)),'-',num2str(round2(bottomofrange+4*interval,prec))),...
        'units','normalized','fontsize',14,'fontweight','bold','fontname','arial');
    text(xpos,ypos6(5),strcat(num2str(round2(bottomofrange+4*interval,prec)),'-',num2str(round2(bottomofrange+5*interval,prec))),...
        'units','normalized','fontsize',14,'fontweight','bold','fontname','arial');
    if flexibleupperbound==1
        text(xpos,ypos6(6),strcat('>=',num2str(round2(bottomofrange+5*interval,prec))),...
        'units','normalized','fontsize',14,'fontweight','bold','fontname','arial');
    else
        text(xpos,ypos6(6),strcat(num2str(round2(bottomofrange+5*interval,prec)),'-',num2str(round2(bottomofrange+6*interval,prec))),...
        'units','normalized','fontsize',14,'fontweight','bold','fontname','arial');
    end
end