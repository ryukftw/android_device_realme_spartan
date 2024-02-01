/*
 * Copyright (C) 2021 WaveOS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

package com.realmeparts;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.os.IBinder;
import android.util.Log;
import android.view.Surface;
import android.view.WindowManager;

public class GameModeRotationService extends Service {

    private static final boolean DEBUG = false;
    private static final String TAG = "GameModeRotationService";

    private void updateTpDirection() {
        WindowManager wm = (WindowManager) getApplicationContext().getSystemService(Context.WINDOW_SERVICE);
        int rotation = wm.getDefaultDisplay().getRotation();
        int tpDirection = 0;

        if (rotation == Surface.ROTATION_90)
            tpDirection = 1;
        else if (rotation == Surface.ROTATION_270)
            tpDirection = 2;

        if (DEBUG)
            Log.i(TAG, "updateTpDirection rotation=" + rotation + " tpDirection=" + tpDirection);

        Utils.writeValue(DeviceSettings.TP_DIRECTION, String.valueOf(tpDirection));
    }

    @Override
    public void onCreate() {
        if (DEBUG) Log.i(TAG, "onCreate");
        super.onCreate();
        updateTpDirection();
    }

    @Override
    public void onDestroy() {
        if (DEBUG) Log.i(TAG, "onDestroy");
        Utils.writeValue(DeviceSettings.TP_DIRECTION, "0");
        super.onDestroy();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        if (DEBUG) Log.i(TAG, "onConfigurationChanged");
        updateTpDirection();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

}
