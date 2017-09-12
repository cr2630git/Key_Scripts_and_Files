%Some stuff that took up too much space in exploratorydataanalysis
%This is called in the course of that script; it obviously cannot stand alone

dosectionold=0;
if dosectionold==1
    annotation('rectangle',[0.88 0.7 0.015 0.02],'Color','r','FaceColor','r');
    text(1,0.77,'May 1-Jun 15','units','normalized','FontSize',14,...
        'FontName','Arial','FontWeight','bold');
    annotation('rectangle',[0.88 0.68 0.015 0.02],'Color',colors('orange'),'FaceColor',colors('orange'));
    text(1,0.74,'Jun 16-Jun 30','units','normalized','FontSize',14,...
        'FontName','Arial','FontWeight','bold');
    annotation('rectangle',[0.88 0.66 0.015 0.02],'Color',colors('green'),'FaceColor',colors('green'));
    text(1,0.71,'Jul 1-Jul 15','units','normalized','FontSize',14,...
        'FontName','Arial','FontWeight','bold');
    annotation('rectangle',[0.88 0.64 0.015 0.02],'Color',colors('sky blue'),...
        'FaceColor',colors('sky blue'));
    text(1,0.68,'Jul 16-Jul 31','units','normalized','FontSize',14,...
        'FontName','Arial','FontWeight','bold');
    annotation('rectangle',[0.88 0.62 0.015 0.02],'Color',colors('blue'),'FaceColor',colors('blue'));
    text(1,0.65,'Aug 1-Aug 16','units','normalized','FontSize',14,...
        'FontName','Arial','FontWeight','bold');
    annotation('rectangle',[0.88 0.6 0.015 0.02],'Color',colors('purple'),'FaceColor',colors('purple'));
    text(1,0.62,'Aug 16-Aug 31','units','normalized','FontSize',14,...
        'FontName','Arial','FontWeight','bold');
    annotation('rectangle',[0.88 0.58 0.015 0.02],'Color',colors('brown'),'FaceColor',colors('brown'));
    text(1,0.59,'Sep 1-Sep 15','units','normalized','FontSize',14,...
        'FontName','Arial','FontWeight','bold');
    annotation('rectangle',[0.88 0.56 0.015 0.02],'Color','k','FaceColor','k');
    text(1,0.56,'Sep 16-Oct 31','units','normalized','FontSize',14,...
        'FontName','Arial','FontWeight','bold');
    
    title('Bllah','FontSize',20,'FontName','Arial','FontWeight','bold');
end

%Add custom colormap/colorbar
if colorbar1==1
    mycolormap=[colors('red');colors('orange');colors('green');colors('sky blue');...
        colors('blue');colors('purple');colors('brown');colors('black')];
    colormap(flipud(mycolormap));
    h=colorbar;
    colorbar('YTick',[0.0625 0.1875 0.3125 0.4375 0.5625 0.6875 0.8125 0.9375],...
        'YTickLabel',{'Sep 16-Oct 31','Sep 1-Sep 15','Aug 16-Aug 31','Aug 1-Aug 15',...
        'Jul 16-Jul 31','Jul 1-Jul 15','Jun 16-Jun 30','May 1-Jun 15'});
        %the first y tick labels, for whatever reason, appear at the bottom and go upwards from there
elseif colorbar2==1
    mycolormap=[colors('red');colors('orange');colors('green');colors('sky blue');...
        colors('blue');colors('purple')];
    colormap(flipud(mycolormap));
    h=colorbar;
    colorbar('YTick',[0.083 0.25 0.417 0.583 0.75 0.917],...
        'YTickLabel',{'x>=p90','p90>x>=p75','p75>x>=p50','p50>x>=p25',...
        'p25>x>=p10','x<p10'});
end

%Add title
if title1==1
    title(sprintf('Average Date of Occurrence of the %d Highest %s',numdates,varname),...
        'FontSize',20,'FontName','Arial','FontWeight','bold');
elseif title2==1
    title(sprintf('St. Dev. of Date of Occurrence of the %d Highest %s',numdates,varname),...
        'FontSize',20,'FontName','Arial','FontWeight','bold');
end


