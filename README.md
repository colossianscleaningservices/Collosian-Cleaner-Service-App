# Colossians Cleaning Services App

A mobile application for clients and staff of Colossians Cleaning Services, built with Flutter.

## About The Project

This is a mobile application for both Customers (Clients) and Staff (Cleaners) of Colossians Cleaning Services. The goal is to enhance usability, accessibility, and operational efficiency by providing dedicated mobile experiences that are powered by a centralized backend system.

The app provides role-based access to features, meaning that the user interface and available functionality will change depending on whether the user is a Client or a Cleaner.

## License

This is a closed-source project. The source code and all associated assets are the confidential and proprietary information of Colossians Cleaning Services. For more information, see the `LICENSE` file.

## Built With

[![Flutter][Flutter-badge]][Flutter-url]
[![Dart][Dart-badge]][Dart-url]
[![GetX][GetX-badge]][GetX-url]
[![Dio][Dio-badge]][Dio-url]

## Features

### For Clients

*   **Onboarding:**
    *   Simple and secure registration with email and password.
    *   Complete a user profile with personal details.
*   **Property Management:**
    *   Add and manage multiple properties.
    *   Specify property details such as address, access instructions (e.g., keys, client will open), and whether pets are present.
    *   Indicate what cleaning equipment is available at the property (e.g., hoover, washing machine).
*   **Job Creation & Scheduling:**
    *   Create new cleaning jobs for any of your properties.
    *   Schedule one-time or recurring jobs.
    *   Specify the number of cleaners required.
*   **Job Tracking:**
    *   View all your jobs in a calendar or a list.
    *   Track the status of your jobs in real-time (Pending, Approved, In Progress, Completed).
*   **Preferred Staff:**
    *   Select your favorite cleaners to be prioritized for your future jobs.
*   **Notifications:**
    *   Receive push notifications for important job updates, such as when a cleaner is assigned, when a job starts, and when it's completed.

### For Cleaners (Staff)

*   **Onboarding & Verification:**
    *   A comprehensive onboarding process to ensure all staff are vetted and qualified.
    *   Includes an initial assessment, government-issued ID verification, and the ability to upload necessary documents like passports and work permits.
*   **Job Management:**
    *   View a list of available jobs and apply for them.
    *   Once assigned, view all job details including client information, property address, and any special instructions.
    *   A simple check-in and check-out process to accurately track work hours.
*   **Availability:**
    *   Set your weekly availability to be matched with suitable jobs.
    *   Block out specific days or times when you are unavailable.
*   **Payouts:**
    *   Track your work hours for each job.
    *   View detailed payout summaries for different pay periods.
*   **Training & Resources:**
    *   Access a library of training materials, including documents and videos, to help you perform your job effectively.
*   **Reviews:**
    *   View feedback and ratings from clients to help you improve your service.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### Prerequisites

- Flutter SDK: >=3.1.3 <4.0.0
- Dart SDK: >=3.1.3 <4.0.0

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/your_username_/ccs_app.git
   ```
2. Install packages
   ```sh
   flutter pub get
   ```

## Project Structure

The project is structured as follows:

- `lib/`: Contains the main source code for the application.
  - `app/`: Contains the core application modules.
    - `core/`: Core components of the application.
    - `gen/`: Generated files.
    - `model/`: Data models.
    - `modules/`: Feature modules.
    - `network/`: Networking layer.
    - `routes/`: Application routes.
    - `services/`: Application services.
    - `theme/`: Application theme.
    - `utils/`: Utility functions.
    - `widget/`: Reusable widgets.
  - `main.dart`: The main entry point of the application.
  - `export.dart`: Exports of commonly used files.
- `assets/`: Contains static assets such as images and fonts.
- `test/`: Contains unit and widget tests.

[Flutter-badge]: https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white
[Flutter-url]: https://flutter.dev/
[Dart-badge]: https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white
[Dart-url]: https://dart.dev/
[GetX-badge]: https://img.shields.io/badge/GetX-8A2BE2?style=for-the-badge
[GetX-url]: https://pub.dev/packages/get
[Dio-badge]: https://img.shields.io/badge/Dio-4A4A4A?style=for-the-badge
[Dio-url]: https://pub.dev/packages/dio
