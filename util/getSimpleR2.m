function R2 = getSimpleR2( meas, pred )

% assume signals are arranged as time x channel

% if a single channel
if isvector(meas) && isvector(pred)
    meas = meas(:);
    pred = pred(:);
end

R2 = 1-sum((meas-pred).^2,1)./sum((bsxfun(@minus,meas,mean(meas,1))).^2,1);

end 