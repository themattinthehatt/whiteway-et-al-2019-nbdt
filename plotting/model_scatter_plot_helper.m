if plot_scatter
    plot(x, y, '.k');
    line([0, 1], [0, 1], 'color', 'k')    
    xlabel(sprintf('Quality Index\n%s', x_model))
    ylabel(sprintf('Quality Index\n%s', y_model))
    ylim([ymin, ymax])
else
    z = y - x;
    temp = histogram(z, linspace(xmin, xmax, 20));
    ybounds = get(gca, 'ylim');
    line([0, 0], [0, ybounds(2)], 'color', 'k')
    line([median(z), median(z)], [0, ybounds(2)], ...
        'color', 'k', 'linestyle', ':')
    xlabel(sprintf('QI: %s-\n%s', y_model, x_model))
    title(sprintf('\\DeltaQI = %3.2f', median(z)), ...
        'interpreter', 'tex')
end
xlim([xmin, xmax])
text(0.05, 0.95, sprintf('p = %1.2g\nN = %i', ...
    signtest(x, y), length(r2s{ds, 1})), ...
     'units', 'normalized', ...
     'horizontalalignment', 'left', ...
     'verticalalignment', 'top')   
clean_plot