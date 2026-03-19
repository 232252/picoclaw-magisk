#!/system/bin/sh
# PicoClaw Magisk Module Service

MODDIR=${0%/*}
PICOCLAW_DIR=/data/adb/picoclaw
WEB_PORT=9088

# Set environment
export PICOCLAW_HOME=$PICOCLAW_DIR

# Create directory
mkdir -p $PICOCLAW_DIR

# Copy binaries if not exists
if [ ! -f "$PICOCLAW_DIR/picoclaw" ]; then
    cp $MODDIR/picoclaw $PICOCLAW_DIR/
    chmod 755 $PICOCLAW_DIR/picoclaw
fi

if [ ! -f "$PICOCLAW_DIR/picoclaw-web" ]; then
    cp $MODDIR/picoclaw-web $PICOCLAW_DIR/
    chmod 755 $PICOCLAW_DIR/picoclaw-web
fi

# Set permissions
chmod 755 $PICOCLAW_DIR/picoclaw
chmod 755 $PICOCLAW_DIR/picoclaw-web

# Kill existing processes
pkill picoclaw 2>/dev/null
pkill picoclaw-web 2>/dev/null
sleep 1

# Start picoclaw core in background
cd $PICOCLAW_DIR
nohup $PICOCLAW_DIR/picoclaw gateway --allow-empty > $PICOCLAW_DIR/picoclaw.log 2>&1 &

# Wait for core to start
sleep 3

# Start web dashboard
nohup $PICOCLAW_DIR/picoclaw-web -public -port $WEB_PORT > $PICOCLAW_DIR/web.log 2>&1 &

log -t PicoClaw "PicoClaw started on port $WEB_PORT"
