### One-Time 60-Minute Shutdown Timer

Quick guide to schedule a 60-minute shutdown without permanently changing the 10-minute default sleep settings. 

### Instructions

1. Press **Windows Key + R** to open the Run dialog box.
2. Type the following command and press **Enter**: 

cmd

shutdown -s -t 3600

Use code with caution. 3. A Windows notification will confirm the scheduled shutdown.

### How to Cancel

If you need to stop the countdown before the 60 minutes are up: 

1. Press **Windows Key + R**.
2. Type the following command and press **Enter**: 

cmd

shutdown -a

Use code with caution.

### Note on Sleep Settings

The shutdown command overrides the default sleep timer for this session. After the PC shuts down and restarts, the system will automatically return to the default **10-minute sleep** behavior.
