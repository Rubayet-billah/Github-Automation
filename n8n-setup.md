# n8n + ngrok Live Setup

Expose local n8n (`localhost:5678`) through a public ngrok URL.

## 1. Start n8n

Open **PowerShell Window 1**:

```powershell
$env:WEBHOOK_URL="https://pedicure-crazed-unaudited.ngrok-free.dev/"
n8n.cmd start
```

Keep this window running.

## 2. Start ngrok

Open **PowerShell Window 2**:

```powershell
ngrok http 5678 --url https://pedicure-crazed-unaudited.ngrok-free.dev
```

Keep this window running.

## 3. Open n8n

Open:

```text
https://pedicure-crazed-unaudited.ngrok-free.dev/
```

Or from PowerShell:

```powershell
Start-Process "https://pedicure-crazed-unaudited.ngrok-free.dev/"
```

## 4. Webhook URL

Your n8n webhook URLs will use:

```text
https://pedicure-crazed-unaudited.ngrok-free.dev/webhook/<webhook-path>
```

Example:

```text
https://pedicure-crazed-unaudited.ngrok-free.dev/webhook/test
```

## Important

Both **n8n** and **ngrok** must remain running.

If your ngrok URL changes, update `WEBHOOK_URL` and the `--url` value accordingly.
