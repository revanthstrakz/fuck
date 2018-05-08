#!/system/bin/sh
# Project WIPE https://github.com/yc9559/cpufreq-interactive-opt
# Author: yc9559
# Modified by Raphiel Rollerscaperers
# Generated at: Wed May  2 19:34:58 2018

# $1:value $2:file path
function set_value() {
	if [ -f $2 ]; then
		chown system:system $2
		chmod 0664 $2
		echo $1 > $2
		chmod 0664 $2
	fi
}

# $1:cpu0 $2:timer_rate $3:value
function set_param() {
	echo $3 > /sys/devices/system/cpu/cpufreq/interactive/$2
}

# Defaulting to balance because it's supposed to be
# a init script, replacing Qualcomm's one
action=balance

# RunOnce
if [ ! -f /dev/project_wipe_runonce ]; then
	# make sure that sysfs is RW
	mount -o remount,rw sysfs /sys
fi

# RunOnce
if [ ! -f /dev/project_wipe_runonce ]; then
	# set flag
	touch /dev/project_wipe_runonce

	# Perfd, nothing to worry about, if error the script will continue
	stop perfd

	set_value 90 /proc/sys/kernel/sched_spill_load
	set_value 0 /proc/sys/kernel/sched_boost
	set_value 1 /proc/sys/kernel/sched_prefer_sync_wakee_to_waker
	set_value 40 /proc/sys/kernel/sched_init_task_load
	set_value 3000000 /proc/sys/kernel/sched_freq_inc_notify
	
	set_value 0-1 /dev/cpuset/background/cpus
	set_value 0-1 /dev/cpuset/system-background/cpus
	set_value 1-3,4-7 /dev/cpuset/foreground/cpus
	set_value 1-3,4-7 /dev/cpuset/top-app/cpus

	set_value 25 /proc/sys/kernel/sched_downmigrate
	set_value 50 /proc/sys/kernel/sched_upmigrate

	set_value 400000 /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq

	# shared interactive parameters
	set_param cpu0 timer_rate 20000
	set_param cpu0 timer_slack 180000
	set_param cpu0 io_is_busy 0
	set_param cpu0 use_sched_load 1
	set_param cpu0 ignore_hispeed_on_notif 0
	set_value 0 /sys/devices/system/cpu/cpufreq/interactive/enable_prediction
fi

if [ "$action" = "powersave" ]; then
	set_param cpu0 above_hispeed_delay "38000 1380000:18000 1680000:58000 1780000:138000"
	set_param cpu0 hispeed_freq 980000
	set_param cpu0 go_hispeed_load 80
	set_param cpu0 boostpulse_duration 58000
	set_param cpu0 target_loads "80 980000:59 1380000:99"
	set_param cpu0 min_sample_time 18000
fi

if [ "$action" = "balance" ]; then
	set_param cpu0 above_hispeed_delay "38000 1380000:18000 1680000:58000 1780000:138000"
	set_param cpu0 hispeed_freq 980000
	set_param cpu0 go_hispeed_load 89
	set_param cpu0 boostpulse_duration 78000
	set_param cpu0 target_loads "80 980000:58 1380000:84 1680000:99"
	set_param cpu0 min_sample_time 18000
fi

if [ "$action" = "performance" ]; then
	set_param cpu0 above_hispeed_delay "18000 1680000:58000 1780000:38000"
	set_param cpu0 hispeed_freq 980000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 boostpulse_duration 18000
	set_param cpu0 target_loads "80 980000:58 1380000:67 1680000:99"
	set_param cpu0 min_sample_time 38000
fi

# Additional Scripts
swapoff /dev/block/zram0
echo 1 > /sys/block/zram0/reset
echo 1073741824 > /sys/block/zram0/disksize

# Set mincpubw back to cpufreq
for devfreq_gov in /sys/class/devfreq/qcom,mincpubw*/governor
    do
        echo "cpufreq" > $devfreq_gov
    done
    
# Tune HW devfreq
for cpu_io_percent in /sys/class/devfreq/soc:qcom,cpubw/bw_hwmon/io_percent
    do
        echo 34 > $cpu_io_percent
    done
for cpu_guard_band in /sys/class/devfreq/soc:qcom,cpubw/bw_hwmon/guard_band_mbps
    do
        echo 0 > $cpu_guard_band
    done
for cpu_hist_memory in /sys/class/devfreq/soc:qcom,cpubw/bw_hwmon/hist_memory
    do
        echo 20 > $cpu_hist_memory
    done
for cpu_hyst_length in /sys/class/devfreq/soc:qcom,cpubw/bw_hwmon/hyst_length
    do
        echo 10 > $cpu_hyst_length
    done
for cpu_idle_mbps in /sys/class/devfreq/soc:qcom,cpubw/bw_hwmon/idle_mbps
    do
        echo 1600 > $cpu_idle_mbps
    done
for cpu_low_power_delay in /sys/class/devfreq/soc:qcom,cpubw/bw_hwmon/low_power_delay
    do
        echo 20 > $cpu_low_power_delay
    done
for cpu_low_power_io_percent in /sys/class/devfreq/soc:qcom,cpubw/bw_hwmon/low_power_io_percent
    do
        echo 34 > $cpu_low_power_io_percent
    done
for cpu_mbps_zones in /sys/class/devfreq/soc:qcom,cpubw/bw_hwmon/mbps_zones
    do
        echo "1611 3221 5859 6445 7104" > $cpu_mbps_zones
    done
for cpu_sample_ms in /sys/class/devfreq/soc:qcom,cpubw/bw_hwmon/sample_ms
    do
        echo 4 > $cpu_sample_ms
    done
for cpu_up_scale in /sys/class/devfreq/soc:qcom,cpubw/bw_hwmon/up_scale
    do
        echo 250 > $cpu_up_scale
done
for cpu_min_freq in /sys/class/devfreq/soc:qcom,cpubw/min_freq
    do
        echo 1611 > $cpu_min_freq
    done

# GPU BIMC I/O Percentage tune
for gpu_bimc_io_percent in /sys/class/devfreq/soc:qcom,gpubw/bw_hwmon/io_percent
    do
        echo 40 > $gpu_bimc_io_percent
    done


exit 0
