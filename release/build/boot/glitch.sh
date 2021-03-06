#!/sbin/busybox sh

KERNEL_CONF="/system/etc/glitch-settings.conf";
KERNEL_LOGFILE="/data/local/tmp/glitch-kernel.log";

if [ -f $KERNEL_LOGFILE ]; then
  mv $KERNEL_LOGFILE $KERNEL_LOGFILE.2;
fi

echo $(date) >> $KERNEL_LOGFILE;

#Permissive mode
if [ "`grep PERMISSIVE=1 $KERNEL_CONF`" ]; then
  echo "0"  > /sys/fs/selinux/enforce;
else
  echo "1"  > /sys/fs/selinux/enforce;
fi

#Touch Firmware
TFW="`cat /sys/devices/i2c-3/3-0010/vendor`"
echo TouchFW: $TFW >> $KERNEL_LOGFILE;

#Max CPU_FREQ
MAXF0=`grep "MAXF_CPU0" $KERNEL_CONF | cut -d '=' -f2`
MAXF1=`grep "MAXF_CPU1" $KERNEL_CONF | cut -d '=' -f2`
MAXF2=`grep "MAXF_CPU2" $KERNEL_CONF | cut -d '=' -f2`
MAXF3=`grep "MAXF_CPU3" $KERNEL_CONF | cut -d '=' -f2`
echo "0:$MAXF0 1:$MAXF1 2:$MAXF2 3:$MAXF3" > /sys/kernel/msm_limiter/live_max_freq;
echo Max CPU0 Frequency: $MAXF0 >> $KERNEL_LOGFILE;
echo Max CPU1 Frequency: $MAXF1 >> $KERNEL_LOGFILE;
echo Max CPU2 Frequency: $MAXF2 >> $KERNEL_LOGFILE;
echo Max CPU3 Frequency: $MAXF3 >> $KERNEL_LOGFILE;

#Min CPU_FREQ
MINF=`grep "MINF" $KERNEL_CONF | cut -d '=' -f2`
echo "0:$MINF 1:$MINF 2:$MINF 3:$MINF" > /sys/kernel/msm_limiter/live_min_freq;
echo Min CPU Frequency: $MINF >> $KERNEL_LOGFILE;

#Max suspend CPU_FREQ
if [ "`grep SCROFF=1 $KERNEL_CONF`" ]; then
  echo "0:594000 1:594000 2:594000 3:594000" > /sys/kernel/msm_limiter/suspend_max_freq;
  echo 594MHz max screen off >> $KERNEL_LOGFILE;
elif [ "`grep SCROFF=2 $KERNEL_CONF`" ]; then
  echo "0:702000 1:702000 2:702000 3:702000" > /sys/kernel/msm_limiter/suspend_max_freq;
  echo 702MHz max screen off >> $KERNEL_LOGFILE;
elif [ "`grep SCROFF=3 $KERNEL_CONF`" ]; then
  echo "0:810000 1:810000 2:810000 3:810000" > /sys/kernel/msm_limiter/suspend_max_freq;
  echo 810MHz max screen off >> $KERNEL_LOGFILE;
elif [ "`grep SCROFF=4 $KERNEL_CONF`" ]; then
  echo "0:1026000 1:1026000 2:1026000 3:1026000" > /sys/kernel/msm_limiter/suspend_max_freq;
  echo 1026MHz max screen off >> $KERNEL_LOGFILE;
elif [ "`grep SCROFF=5 $KERNEL_CONF`" ]; then
  echo "0:1242000 1:1242000 2:1242000 3:1242000" > /sys/kernel/msm_limiter/suspend_max_freq;
  echo 1242MHz max screen off >> $KERNEL_LOGFILE;
else
  echo "0:1512000 1:1512000 2:1512000 3:1512000" > /sys/kernel/msm_limiter/suspend_max_freq;
  echo max screen off freq set to stock CPU speed >> $KERNEL_LOGFILE;
fi

#I/O scheduler
if [ "`grep IOSCHED=1 $KERNEL_CONF`" ]; then
echo "cfq" > /sys/block/mmcblk0/queue/scheduler;
echo io scheduler: cfq >> $KERNEL_LOGFILE;
elif [ "`grep IOSCHED=2 $KERNEL_CONF`" ]; then
echo "row" > /sys/block/mmcblk0/queue/scheduler;
echo io scheduler: row >> $KERNEL_LOGFILE;
elif [ "`grep IOSCHED=3 $KERNEL_CONF`" ]; then
echo "deadline" > /sys/block/mmcblk0/queue/scheduler;
echo io scheduler: deadline >> $KERNEL_LOGFILE;
elif [ "`grep IOSCHED=4 $KERNEL_CONF`" ]; then
echo "fiops" > /sys/block/mmcblk0/queue/scheduler;
echo io scheduler: fiops >> $KERNEL_LOGFILE;
elif [ "`grep IOSCHED=5 $KERNEL_CONF`" ]; then
echo "sio" > /sys/block/mmcblk0/queue/scheduler;
echo io scheduler: sio >> $KERNEL_LOGFILE;
elif [ "`grep IOSCHED=6 $KERNEL_CONF`" ]; then
echo "noop" > /sys/block/mmcblk0/queue/scheduler;
echo io scheduler: noop >> $KERNEL_LOGFILE;
elif [ "`grep IOSCHED=7 $KERNEL_CONF`" ]; then
echo "bfq" > /sys/block/mmcblk0/queue/scheduler;
echo io scheduler: BFQ >> $KERNEL_LOGFILE;
fi

#Read-ahead
if [ "`grep READAHEAD=1 $KERNEL_CONF`" ]; then
echo 128 > /sys/block/mmcblk0/queue/read_ahead_kb;
echo Read-ahead: 128 >> $KERNEL_LOGFILE;
elif [ "`grep READAHEAD=2 $KERNEL_CONF`" ]; then
echo 256 > /sys/block/mmcblk0/queue/read_ahead_kb;
echo Read-ahead: 256 >> $KERNEL_LOGFILE;
elif [ "`grep READAHEAD=3 $KERNEL_CONF`" ]; then
echo 512 > /sys/block/mmcblk0/queue/read_ahead_kb;
echo Read-ahead: 512 >> $KERNEL_LOGFILE;
elif [ "`grep READAHEAD=4 $KERNEL_CONF`" ]; then
echo 1024 > /sys/block/mmcblk0/queue/read_ahead_kb;
echo Read-ahead: 1024 >> $KERNEL_LOGFILE;
elif [ "`grep READAHEAD=5 $KERNEL_CONF`" ]; then
echo 2048 > /sys/block/mmcblk0/queue/read_ahead_kb;
echo Read-ahead: 2048 >> $KERNEL_LOGFILE;
fi

#Backlight dimmer option
BLD=`grep "BLD" $KERNEL_CONF | cut -d '=' -f2`
echo $BLD > /sys/module/msm_fb/parameters/backlight_dimmer;
echo Backlight dimmer enabled\: $BLD >> $KERNEL_LOGFILE;

#FAST CHARGE
if [ "`grep FAST_CHARGE=1 $KERNEL_CONF`" ]; then
  echo 1 > /sys/kernel/fast_charge/force_fast_charge;
  echo fast charge enabled >> $KERNEL_LOGFILE;
else
  echo 0 > /sys/kernel/fast_charge/force_fast_charge;
  echo fast charge disabled >> $KERNEL_LOGFILE;
fi

#Set HOTPLUGDRV
if [ "`grep HOTPLUGDRV=1 $KERNEL_CONF`" ]; then
  echo 0 > /sys/module/msm_mpdecision/parameters/enabled;
  echo 1 > /sys/module/msm_hotplug/msm_enabled;
  echo 0 > /sys/module/intelli_plug/parameters/intelli_plug_active;
  echo 0 > /sys/module/intelli_plug/parameters/touch_boost_active;
  echo 0 > /sys/module/lazyplug/parameters/lazyplug_active;
  echo MSM-hotplug enabled >> $KERNEL_LOGFILE;
elif [ "`grep HOTPLUGDRV=2 $KERNEL_CONF`" ]; then
  echo 0 > /sys/module/msm_mpdecision/parameters/enabled;
  echo 0 > /sys/module/msm_hotplug/msm_enabled;
  echo 1 > /sys/module/intelli_plug/parameters/intelli_plug_active;
  echo 1 > /sys/module/intelli_plug/parameters/touch_boost_active;
  echo 0 > /sys/module/lazyplug/parameters/lazyplug_active;
  echo Intelli-Plug enabled >> $KERNEL_LOGFILE;
elif [ "`grep HOTPLUGDRV=3 $KERNEL_CONF`" ]; then
  echo 0 > /sys/module/msm_mpdecision/parameters/enabled;
  echo 0 > /sys/module/msm_hotplug/msm_enabled;
  echo 0 > /sys/module/intelli_plug/parameters/intelli_plug_active;
  echo 0 > /sys/module/intelli_plug/parameters/touch_boost_active;
  echo 1 > /sys/module/lazyplug/parameters/lazyplug_active;
  echo LazyPlug enabled >> $KERNEL_LOGFILE;
else
  echo 1 > /sys/module/msm_mpdecision/parameters/enabled;
  echo 0 > /sys/module/msm_hotplug/msm_enabled;
  echo 0 > /sys/module/intelli_plug/parameters/intelli_plug_active;
  echo 0 > /sys/module/intelli_plug/parameters/touch_boost_active;
  echo 0 > /sys/module/lazyplug/parameters/lazyplug_active;
  echo Qualcomm MPdecision enabled >> $KERNEL_LOGFILE;
fi

#Set DOUBLETAP2WAKE
if [ "`grep DT2W=1 $KERNEL_CONF`" ]; then
  echo 1 > /sys/android_touch/doubletap2wake;
  echo DoubleTap2Wake enabled >> $KERNEL_LOGFILE;
else
  echo 0 > /sys/android_touch/doubletap2wake;
  echo DoubleTap2Wake disabled >> $KERNEL_LOGFILE;
fi

#Set Magnetic on/off
if [ "`grep LID=0 $KERNEL_CONF`" ]; then
  echo 0 > /sys/module/lid/parameters/enable_lid;
  echo Magnetic on/off disabled >> $KERNEL_LOGFILE;
else
  echo 1 > /sys/module/lid/parameters/enable_lid;
  echo Magnetic on/off enabled >> $KERNEL_LOGFILE;
fi

#USB Host mode charging
if [ "`grep OTGCM=1 $KERNEL_CONF`" ]; then
  echo Y > /sys/module/msm_otg/parameters/usbhost_charge_mode;
  echo USB OTG+Charge mode enabled >> $KERNEL_LOGFILE;
fi

#MC Power savings
if [ "`grep MC_POWERSAVE=1 $KERNEL_CONF`" ]; then
  echo 2 > /sys/devices/system/cpu/sched_mc_power_savings;
  echo Maximum MC power savings >> $KERNEL_LOGFILE;
else
  echo MC power savings disabled >> $KERNEL_LOGFILE;
fi

#fstrim
fstrim -v /cache | tee -a $KERNEL_LOGFILE;
fstrim -v /data | tee -a $KERNEL_LOGFILE;

#thermal settings
if [ "`grep THERM=1 $KERNEL_CONF`" ]; then
  echo 65 > /sys/module/msm_thermal/parameters/limit_temp_degC;
  echo 75 > /sys/module/msm_thermal/parameters/core_limit_temp_degC;
  echo 15 > /sys/module/msm_thermal/parameters/freq_control_mask;
  echo 14 > /sys/module/msm_thermal/parameters/core_control_mask;
  echo run cool >> $KERNEL_LOGFILE;
elif [ "`grep THERM=2 $KERNEL_CONF`" ]; then
  echo 80 > /sys/module/msm_thermal/parameters/limit_temp_degC;
  echo 90 > /sys/module/msm_thermal/parameters/core_limit_temp_degC;
  echo 15 > /sys/module/msm_thermal/parameters/freq_control_mask;
  echo 14 > /sys/module/msm_thermal/parameters/core_control_mask;
  echo run hot >> $KERNEL_LOGFILE;
else
  echo 70 > /sys/module/msm_thermal/parameters/limit_temp_degC;
  echo 80 > /sys/module/msm_thermal/parameters/core_limit_temp_degC;
  echo 15 > /sys/module/msm_thermal/parameters/freq_control_mask;
  echo 14 > /sys/module/msm_thermal/parameters/core_control_mask;
  echo run warm >> $KERNEL_LOGFILE;
fi

#GPU Clock settings
if [ "`grep GPU_OC=1 $KERNEL_CONF`" ]; then
  echo 320000000 > /sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/max_gpuclk;
  echo 320MHz GPU >> $KERNEL_LOGFILE;
elif [ "`grep GPU_OC=3 $KERNEL_CONF`" ]; then
  echo 450000000 > /sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/max_gpuclk;
  echo 450MHz GPU >> $KERNEL_LOGFILE;
elif [ "`grep GPU_OC=4 $KERNEL_CONF`" ]; then
  echo 504000000 > /sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/max_gpuclk;
  echo 504MHz GPU >> $KERNEL_LOGFILE;
elif [ "`grep GPU_OC=5 $KERNEL_CONF`" ]; then
  echo 545000000 > /sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/max_gpuclk;
  echo 545MHz GPU >> $KERNEL_LOGFILE;
elif [ "`grep GPU_OC=6 $KERNEL_CONF`" ]; then
  echo 600000000 > /sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/max_gpuclk;
  echo 600MHz GPU >> $KERNEL_LOGFILE;
elif [ "`grep GPU_OC=7 $KERNEL_CONF`" ]; then
  echo 627000000 > /sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/max_gpuclk;
  echo 627MHz GPU >> $KERNEL_LOGFILE;
else
  echo 400000000 > /sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/max_gpuclk;
  echo 400MHz GPU >> $KERNEL_LOGFILE;
fi

#GPU Governor settings
if [ "`grep GPU_GOV=2 $KERNEL_CONF`" ]; then
  echo interactive > /sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/pwrscale/trustzone/governor;
  echo Interactive GPU Governor >> $KERNEL_LOGFILE;
elif [ "`grep GPU_GOV=3 $KERNEL_CONF`" ]; then
  echo performance > /sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/pwrscale/trustzone/governor;
  echo Performance GPU Governor >> $KERNEL_LOGFILE;
else
  echo ondemand > /sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/pwrscale/trustzone/governor;
  echo Ondemand GPU Governor >> $KERNEL_LOGFILE;
fi

#GPU uV settings
if [ "`grep GPU_UV=2 $KERNEL_CONF`" ]; then
  printf "920000\n1025000\n1125000\n" > /sys/devices/system/cpu/cpufreq/vdd_table/vdd_levels_GPU;
  echo -25mV GPU uV >> $KERNEL_LOGFILE;
elif [ "`grep GPU_UV=3 $KERNEL_CONF`" ]; then
  printf "895000\n1000000\n1100000\n" > /sys/devices/system/cpu/cpufreq/vdd_table/vdd_levels_GPU;
  echo -50mV GPU uV >> $KERNEL_LOGFILE;
elif [ "`grep GPU_UV=4 $KERNEL_CONF`" ]; then
  printf "870000\n975000\n1075000\n" > /sys/devices/system/cpu/cpufreq/vdd_table/vdd_levels_GPU;
  echo -75mV GPU uV >> $KERNEL_LOGFILE;
elif [ "`grep GPU_UV=5 $KERNEL_CONF`" ]; then
  printf "845000\n950000\n1050000\n" > /sys/devices/system/cpu/cpufreq/vdd_table/vdd_levels_GPU;
  echo -100mV GPU uV >> $KERNEL_LOGFILE;
elif [ "`grep GPU_UV=6 $KERNEL_CONF`" ]; then
  printf "820000\n925000\n1025000\n" > /sys/devices/system/cpu/cpufreq/vdd_table/vdd_levels_GPU;
  echo -125mV GPU uV >> $KERNEL_LOGFILE;
elif [ "`grep GPU_UV=7 $KERNEL_CONF`" ]; then
  printf "795000\n900000\n1000000\n" > /sys/devices/system/cpu/cpufreq/vdd_table/vdd_levels_GPU;
  echo -150mV GPU uV >> $KERNEL_LOGFILE;
else
  printf "945000\n1050000\n1150000\n" > /sys/devices/system/cpu/cpufreq/vdd_table/vdd_levels_GPU;
  echo Stock GPU voltage >> $KERNEL_LOGFILE;
fi

#Battery life extender
if [ "`grep BLE=2 $KERNEL_CONF`" ]; then
  echo 4200 > /sys/devices/i2c-0/0-006a/float_voltage;
  echo 4.2V charge voltage >> $KERNEL_LOGFILE;
elif [ "`grep BLE=3 $KERNEL_CONF`" ]; then
  echo 4100 > /sys/devices/i2c-0/0-006a/float_voltage;
  echo 4.1V charge voltage >> $KERNEL_LOGFILE;
elif [ "`grep BLE=4 $KERNEL_CONF`" ]; then
  echo 4000 > /sys/devices/i2c-0/0-006a/float_voltage;
  echo 4.0V charge voltage >> $KERNEL_LOGFILE;
else
  echo 4300 > /sys/devices/i2c-0/0-006a/float_voltage;
  echo Stock charge voltage >> $KERNEL_LOGFILE;
fi

#Wait a bit before applying governor changes
sleep 20

#CPU governor
if [ "`grep CPU_GOV=2 $KERNEL_CONF`" ]; then
  governor=interactive
elif [ "`grep CPU_GOV=3 $KERNEL_CONF`" ]; then
  governor=intellidemand
elif [ "`grep CPU_GOV=4 $KERNEL_CONF`" ]; then
  governor=smartmax
elif [ "`grep CPU_GOV=5 $KERNEL_CONF`" ]; then
  governor=smartmax_eps
elif [ "`grep CPU_GOV=6 $KERNEL_CONF`" ]; then
  governor=intelliactive
elif [ "`grep CPU_GOV=7 $KERNEL_CONF`" ]; then
  governor=conservative
else
  governor=ondemand
fi
  echo $governor > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor;
  echo CPU Governor: $governor >> $KERNEL_LOGFILE;

#Backup settings to sdcard
 cp /system/etc/glitch-settings.conf /sdcard/glitch-settings.conf
 echo "Settings backup created on sdcard root" >> $KERNEL_LOGFILE;

###########SYS

# **************************************************************
# Add Synapse support
# **************************************************************

SYN=/data/synapse;
BB=/sbin/busybox;
UCI_CONFIG=$SYN/config.json;
DEBUG=$SYN/debug;
UCI_FILE=$SYN/uci;
UCI_XBIN=/system/xbin/uci;

# Delete known files that re-create uci config

if [ -e "/data/ak/ak-post-boot.sh" ]; then
	$BB rm -f /data/ak/ak-post-boot.sh #ak
	$BB rm -f /sbin/post-init.sh #neobuddy89
fi

# Delete default uci config in case kernel has one already to avoid duplicates.

if [ -e "/sbin/uci" ]; then
	$BB rm -f /sbin/uci
fi

# Delete all debug files so it can be re-created on boot.

$BB rm -f $DEBUG/*

# Reset profiles to default

$BB echo "Custom" > $SYN/files/gamma_prof
$BB echo "Custom" > $SYN/files/lmk_prof
$BB echo "Custom" > $SYN/files/sound_prof
$BB echo "Custom" > $SYN/files/speaker_prof
$BB echo "0" > $SYN/files/volt_prof;
$BB echo "0" > $SYN/files/dropcaches_prof;

# Symlink uci file to xbin in case it's not found.

if [ ! -e $UCI_XBIN ]; then
	$BB mount -o remount,rw /system
	$BB mount -t rootfs -o remount,rw rootfs
	
	$BB chmod 755 $UCI_FILE
	$BB ln -s $UCI_FILE $UCI_XBIN
	$BB chmod 755 $UCI_XBIN
	
	$BB mount -t rootfs -o remount,ro rootfs
	$BB mount -o remount,ro /system
fi

# If uci files does not have 755 permissions, set permissions.

if [ `$BB stat -c %a $UCI_FILE` -lt "755" ]; then
	$BB chmod 755 $UCI_FILE
fi

if [ `$BB stat -c %a $UCI_XBIN` -lt "755" ]; then
	$BB mount -o remount,rw /system
	$BB mount -t rootfs -o remount,rw rootfs
	$BB chmod 755 $UCI_XBIN
	$BB mount -t rootfs -o remount,ro rootfs
	$BB mount -o remount,ro /system
fi

# Reset uci config so it can be re-created on boot.

$UCI_XBIN reset;
$BB sleep 1;
$UCI_XBIN;
##########/SYS

exit 0
