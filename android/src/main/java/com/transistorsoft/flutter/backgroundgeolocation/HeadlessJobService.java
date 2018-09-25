package com.transistorsoft.flutter.backgroundgeolocation;

import android.annotation.TargetApi;
import android.app.job.JobParameters;
import android.app.job.JobService;
import android.os.Bundle;

import com.transistorsoft.locationmanager.logger.TSLog;

@TargetApi(21)
public class HeadlessJobService extends JobService {
    private HeadlessTask mHeadlessTask;

    @Override
    public boolean onStartJob(final JobParameters params) {
        Bundle event = new Bundle(params.getExtras());

        mHeadlessTask = new HeadlessTask(getApplicationContext(), event, new HeadlessTask.Callback() {
            @Override
            public void onComplete() {
                jobFinished(params, false);
            }
        });
        return true;
    }
    @Override
    public boolean onStopJob(JobParameters params) {
        TSLog.logger.debug(TSLog.ICON_WARN + " onStopJob: " + mHeadlessTask.hashCode());
        jobFinished(params, false);
        return true;
    }
}