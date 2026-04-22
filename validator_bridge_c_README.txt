I-Metro validator bridge (C version)
=====================================

This file is the hardware fallback note for the dedicated Linux/ARM validator device.

Current recommendation:
  - Use the web validator at /validator for daily scanning.
  - Keep this bridge only as a backup for the physical validator device.

What the C bridge does:
  - opens the scanner serial device
  - reads QR payloads from the vendor hardware
  - POSTs scans to the backend validator endpoint
  - keeps running continuously

Default runtime settings:
  - serial port: /dev/ttyC0
  - baud: 115200
  - backend URL: http://127.0.0.1:3000/api

Typical validator device path:
  - /app/validator_bridge/validator_bridge

If you need to rebuild later:
  - use the ARM toolchain from CL-0409_SDK
  - produce a Linux ARM binary
  - copy it onto the validator device

If you need to troubleshoot the hardware validator later:
  - verify the serial device name
  - verify the backend URL
  - verify the validator API key
  - check the validator service logs

Note:
  - The web validator is the primary working validator path right now.
