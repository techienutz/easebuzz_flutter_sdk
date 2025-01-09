# Easebuzz Flutter SDK

The **Easebuzz Flutter SDK** provides seamless integration with the Easebuzz payment gateway, enabling merchants to securely collect online payments through various payment modes such as credit cards, debit cards, UPI, and more. This SDK ensures robust encryption and security measures to safeguard customer data. Easebuzz is a fully API-integrated platform, simplifying payment processing for websites and mobile apps.

---

## Features

- Multiple payment modes: Credit/Debit Cards, UPI, Net Banking, and more.
- Secure and encrypted transactions.
- Easy integration with Flutter apps.
- Fully API-integrated payment gateway.
- Sandbox environment for testing.

---

## Prerequisites

Before integrating the Easebuzz Flutter SDK, ensure the following:

1. **Merchant Onboarding**

    - Create a merchant account and complete the onboarding process via the [Easebuzz Signup Portal](https://easebuzz.in/signup).

2. **Sandbox/Test Integration Credentials**

    - Test credentials will be sent to your registered email address. Use these credentials to test payment functionality in a secure sandbox environment.
    - Once testing is complete, replace the test keys with live keys to enable real transactions in the production environment.

3. **Platform-Specific Configuration**

    - **Web**:

        - Add the following two `<script>` tags in the `<head>` section of your `web/index.html`:

           ```html
           <script src="https://ebz-static.s3.ap-south-1.amazonaws.com/easecheckout/v2.0.0/easebuzz-checkout-v2.min.js"></script>
           <script src="https://cdnjs.cloudflare.com/ajax/libs/crypto-js/4.1.1/crypto-js.min.js"></script>
          ```


---

## Installation

To integrate the SDK, follow these steps:

1. **Add the Dependency**

   Add the following to your `pubspec.yaml` file:

   ```yaml
   dependencies:
     easebuzz_flutter_sdk: ^0.0.1
   ```

   Fetch the package by running:

   ```bash
   flutter pub get
   ```

2. **Import the Package**

   Import the SDK in your Dart file:

   ```dart
   import 'package:easebuzz_flutter_sdk/easebuzz_flutter_sdk.dart';
   ```

---

## How to Use
### Step 1: Initialize the SDK

Before using any functionality from the SDK, initialize the EasebuzzFlutterSdk instance:

```final EasebuzzFlutterSdk _easebuzzFlutterPlugin = EasebuzzFlutterSdk();```

### Step 2: Create the Payment Model

Start by creating an instance of `EasebuzzPaymentModel`:

```dart
final paymentModel = EasebuzzPaymentModel(
  txnid: "TEST${DateTime.now().millisecondsSinceEpoch}", // Unique transaction ID
  amount: amount, // Payment amount
  productinfo: productName, // Product/service name
  firstname: "John", // Customer's first name
  email: "john@example.com", // Customer's email
  phone: "9999999999", // Customer's phone number
  surl: "https://your-success-url.com", // Success URL
  furl: "https://your-failure-url.com", // Failure URL
  splitPayments: jsonEncode({"your_label": amount}), // Split payments if applicable
  key: key, // Merchant key
);
```

> **Note:** Replace `surl` and `furl` with your actual success and failure handling URLs.

### Step 3: Generate Hash

Generate a hash to ensure secure communication:

```dart
final hash = await _easebuzzFlutterPlugin.generateHash(
  paymentModel: paymentModel,
  key: key, // Merchant key
  salt: salt, // Merchant salt
);
```

### Step 4: Initiate Payment Link

#### For Mobile Platforms (Android/iOS):

Use the `initiateLink` method:

```dart
final response = await _easebuzzFlutterPlugin.initiateLink(
  isTestMode: true, // Set to `false` for production
  hash: hash,
  paymentModel: paymentModel,
);
```

#### For Web:

The `initiateLink` method is **not supported** on web due to CORS issues. Instead, generate the access key on your backend or cloud function by calling the Easebuzz API:

- Refer to the [Initiate Payment API Documentation](https://docs.easebuzz.in/docs/payment-gateway/8ec545c331e6f-initiate-payment-api).

Example for generating access key:

```dart
final response = await createAccessTokenForWeb(
  hash: hash,
  requestBody: paymentModel.toJson(),
);
```

---

### Step 4: Proceed to Payment

After obtaining the `access key` from `initiateLink` or your backend, proceed with the payment:

```dart
final paymentResponse = await _easebuzzFlutterPlugin.payWithEasebuzz(
  response, // Access key from initiateLink response
  "test", // Payment mode: "test" for sandbox or "production" for live
);
```

---

### Full Example for Payment Integration

Here’s an example of how to use the Easebuzz SDK in a Flutter app:

```
Future<void> initiatePayment({
  required String productName,
  required double amount,
  required Function(String) onSuccess,
  required Function(String) onError,
}) async {
  final paymentModel = EasebuzzPaymentModel(
    txnid: "TEST${DateTime.now().millisecondsSinceEpoch}",
    amount: amount,
    productinfo: productName,
    firstname: "John",
    email: "john@example.com",
    phone: "9999999999",
    surl: "https://your-success-url.com",
    furl: "https://your-failure-url.com",
    splitPayments: jsonEncode({"your_label": amount}),
    key: key,
  );

  try {
    // Generate hash
    final hash = await _easebuzzFlutterPlugin.generateHash(
      paymentModel: paymentModel,
      key: EaseBuzzPaymentRepository.key,
      salt: EaseBuzzPaymentRepository.salt,
    );

    if (hash == null) {
      onError("Failed to generate hash.");
      return;
    }

    // Initiate payment link
    final response = kIsWeb
        ? await createAccessTokenForWeb(
            hash: hash, requestBody: paymentModel.toJson()) // 
        : await _easebuzzFlutterPlugin.initiateLink(
            isTestMode: true, // Set to false for production
            hash: hash,
            paymentModel: paymentModel,
          );

    if (response == null) {
      onError("Failed to initiate payment link.");
      return;
    }

    // Proceed to payment
    final paymentResponse =
        await _easebuzzFlutterPlugin.payWithEasebuzz(response, "test");

    if (paymentResponse != null) {
      // Handle successful payment
      onSuccess("Payment successful: $paymentResponse");
    } else {
      // Handle failed payment
      onError("Payment failed: Payment response is null.");
    }
  } on PlatformException catch (e) {
    // Handle platform-specific errors
    onError("Payment failed: ${e.message}");
  } catch (e) {
    // Handle general errors
    onError("Payment failed: ${e.toString()}");
  }
}

/// Call this above method on paybutton

Future<void> _processPayment(BuildContext context, Product product) async {
    await paymentService.initiatePayment(
      productName: product.title,
      amount: product.price,
      onSuccess: (response) {
        _showFeedbackSnackBar(
          context,
          'Payment Successful: $response',
          Colors.green,
        );
      },
      onError: (error) {
        _showFeedbackSnackBar(
          context,
          'Payment Failed: $error',
          Colors.red,
        );
      },
    );
  }

```

---
## Why Use Backend for Web Integration?

- Due to CORS restrictions, the `Initiate Payment API` must be called from your backend or cloud function.
- Backend integration ensures secure handling of the `access key`.

---

### Example Screen Recording

Watch the example screen recordings for different platforms to see how to integrate the Easebuzz Flutter SDK:

- **Android**: [Watch Android Example Video](https://drive.google.com/file/d/1g36rUZu0ncPbRR4fun6h6eeGsmlYllAx/view?usp=sharing)
- **iOS**: [Watch iOS Example Video](https://drive.google.com/file/d/1TNLWmB_LOErCoORDSWtHbLzFFcMjYOUe/view?usp=sharing)
- **Web**: [Watch Web Example Video](https://drive.google.com/file/d/1QdsISMbLfV4mlTmEcgZ5Bz051NL1kuF8/view?usp=sharing)


---
## Resources

- [Easebuzz Signup Portal](https://easebuzz.in/signup)
- [Initiate Payment API Documentation](https://docs.easebuzz.in/docs/payment-gateway/8ec545c331e6f-initiate-payment-api)

---
