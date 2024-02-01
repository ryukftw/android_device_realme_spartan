/**
 * Copyright (C) 2020 DerpFest ROM
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.realmeparts;

import android.service.quicksettings.Tile;
import android.service.quicksettings.TileService;

public class FPSTileService extends TileService {

    private boolean isShowing = false;

    @Override
    public void onStartListening() {
        super.onStartListening();
        isShowing = Utils.isFpsInfoShowing(getApplicationContext());
        updateTile();
    }

    @Override
    public void onClick() {
        super.onClick();
        if (isShowing) {
            Utils.stopService(getApplicationContext(), FPSInfoService.class);
        } else {
            Utils.startService(getApplicationContext(), FPSInfoService.class);
        }
        isShowing = !isShowing;
        updateTile();
    }

    private void updateTile() {
        final Tile tile = getQsTile();
        tile.setState(isShowing ? Tile.STATE_ACTIVE : Tile.STATE_INACTIVE);
        tile.updateTile();
    }

}
