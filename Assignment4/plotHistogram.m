function r = plotHistogram(data)
    figure('units','normalized','outerposition',[0 0 1 1],'NumberTitle', 'off', 'Name', "PRODUCTS FREQUENCY")
    h = histogram(categorical([data{:}]'),'Orientation', 'vertical','facecolor', [1 0.301960784313725 0]);
    xtickangle(90)
    xlabel(['\fontsize{16}PRODUCTS'])
    ylabel(['\fontsize{16}FREQUENCY'])
    set(gca,'FontSize',8);
    set(gca, 'FontName', 'Times New Roman');
    h.DisplayOrder = 'descend';
    title(['\fontsize{16}PRODUCT TRANSACTION FREQUENCIES'])
    grid on;
end