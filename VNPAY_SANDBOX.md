# VNPay Sandbox

The deposit flow uses VNPay Payment Gateway API v2.1.0 and the official Sandbox payment URL.

Set these environment variables on the Tomcat process before starting it:

- `VNPAY_TMN_CODE`: your VNPay Sandbox merchant code.
- `VNPAY_HASH_SECRET`: the matching Sandbox secret key. Keep it out of source control.
- `VNPAY_RETURN_URL` (optional): public or local browser return URL. By default the app builds it from the current request.

The app creates `vnpay_payments` automatically on startup. For a manually managed database, run `database/migration_add_vnpay_payments.sql` after the existing `orders`, `conversations`, and `products` tables have been created.

Configure the merchant's IPN URL as:

`https://your-public-host/your-context/vnpay-ipn`

For local testing, the customer browser can return to localhost, but VNPay cannot call an IPN endpoint on a private localhost address. Use a public HTTPS tunnel or a deployed public host and set the IPN URL in the VNPay Sandbox merchant configuration to receive server-to-server payment notifications.

The app verifies VNPay HMAC-SHA512 signatures and the returned amount before marking a transaction paid. It creates a `DEPOSITED` order only after a verified successful callback. The app does not ship with merchant credentials; register for Sandbox credentials in the VNPay developer portal.
