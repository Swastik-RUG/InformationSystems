function r = plotHistogram(data, items)
    figure('units','normalized','outerposition',[0 0 1 1],'NumberTitle', 'off', 'Name', "PRODUCTS FREQUENCY")
    histogram(categorical([data{:}]'),'Orientation', 'vertical')
    xtickangle(90)
    xlabel("products")
    ylabel("frequency")
    set(gca,'FontSize',8);
    set(gca, 'FontName', 'Times New Roman');
end