# Pairing another device with OpenCode

OpenCode's web interface connects to the shared background service on the
computer running your sessions. To pair a phone or another computer from
anywhere, run this on that computer:

```bash
opencode pair --remote
```

The first time, OpenCode asks you to confirm internet exposure. Remote access
uses an end-to-end encrypted tunnel and requires the server password.

## Phone

Scan the displayed QR code, or securely transfer the printed pairing link to
the phone and open it in a browser.

## Another computer

Copy the pairing link printed above the QR code and transfer it securely to
the other computer, for example through a trusted password manager or an
encrypted message to yourself. Open the link in a browser, or paste it into
the OpenCode app's server address field. No QR-code scan is necessary.

Choose the project and session you want to view in the web interface.

## Security and troubleshooting

- Generate a fresh link for each device. Links work once and expire after
  five minutes; paired browser or app sessions last 30 days.
- Treat pairing links as credentials. Anyone who can use a valid link can
  access your OpenCode server. Do not post or share them publicly.
- Changing the server password signs out all paired sessions.
- A link beginning with `127.0.0.1` refers to the device opening it, not
  necessarily the computer running OpenCode. Use `--remote` for a phone or
  another computer unless you have set up another secure connection.
- Check the service with `opencode service status`. Pairing requires the
  shared service and is unavailable when that service is disabled.

Source: [OpenCode web documentation](https://opencode.ai/docs/cli/web/).
