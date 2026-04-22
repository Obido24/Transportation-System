I-Metro validator notes
=======================

Current recommended validator setup:
  - Use the web validator at /validator for daily gate scanning.
  - Open it on a phone, allow camera access, and keep the bus selected at startup.
  - The page sends scans to the backend API and shows VALID / INVALID feedback live.

Bus workflow:
  - Select the bus once at startup.
  - The bus label stays saved locally on that device.
  - Scan activity is also visible in the admin Bus Scan Logs page.

Support workflow:
  - Passenger complaints now show a success notice after sending.
  - Support status changes from admin can be seen in the user app as Open / In progress / Resolved.

Backend notes:
  - Validator scans use the backend API at /api/validators/validate-qr.
  - The validator API key is created in the backend and stored in the validator web app setup only for configuration.

Hardware bridge note:
  - The old Linux/ARM validator bridge files are still available for the dedicated device flow.
  - If the physical validator device is used again, keep the compiled validator_bridge binary in /app/validator_bridge/.

Important:
  - The web validator is the current primary working path.
  - The hardware bridge is optional backup infrastructure.
