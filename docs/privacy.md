# Privacy Policy

**Friendsheet**
**Last updated:** March 2026

---

## 1. Introduction

Friendsheet ("we", "our", "the app") is committed to protecting your privacy. This Privacy Policy explains what data we collect, how we use it, and your rights regarding your personal information.

By using Friendsheet, you agree to the collection and use of information as described in this policy.

---

## 2. Data We Collect

### 2.1 Account Information
When you sign in with Google, we receive:
- Your name
- Your email address
- Your Google profile photo URL

This data is provided by Google and is used solely to identify your account within the app.

### 2.2 App Data
Data you enter manually into the app:
- Meeting records (name, date, participants)
- Friend profiles (first name, last name)
- Activity categories

### 2.3 Google Calendar Data (optional)
If you choose to connect Google Calendar, we temporarily access:
- Event titles
- Event start dates and times
- Whether an event is all-day
- Attendee email addresses (used to suggest friends)
- Calendar name and ID (used to identify which calendar to import from)

This data is used **only during the import process** to pre-fill meeting suggestions. It is **never stored in our database (Firestore)**. Once you confirm or discard the import, the data is discarded from memory.

### 2.4 Data We Do NOT Collect
- Location data
- Device identifiers
- Usage analytics
- Advertising identifiers
- Data from Google Drive, Gmail, or any other Google services not listed above

---

## 3. How We Use Your Data

Your data is used exclusively to provide the app's core functionality:
- Displaying your meetings, friends, and activities
- Generating statistics about your social activity
- Persisting your data across app sessions
- Suggesting meeting entries based on your Google Calendar events (only when you explicitly initiate an import)

We do not use your data for advertising, profiling, or any commercial purpose.

---

## 4. Data Storage

Your data is stored in **Google Firebase Firestore** under your unique Google account identifier (UID). Firebase is a Google Cloud service subject to [Google's Privacy Policy](https://policies.google.com/privacy).

- Data is stored in the **EU (Firebase region: `europe-central2`, Warsaw, Poland)**
- Data is encrypted at rest and in transit
- Only you can access your own data (enforced by Firebase Security Rules)
- Google Calendar data is **never stored in Firestore** — it is processed in memory only during import

---

## 5. Data Sharing

We do not sell, rent, or share your personal data with any third parties.

The only third-party services that process your data are:
- **Google Firebase** — used for authentication and data storage
- **Google Calendar API** — used only when you explicitly connect your calendar and initiate an import

---

## 6. Data Retention

Your data is retained for as long as you use the app. You may request deletion of your account and all associated data at any time by contacting us at **aleksander.ginalski@gmail.com**.

---

## 7. Your Rights

Depending on your location, you may have the following rights:
- **Access** — request a copy of your data
- **Correction** — request correction of inaccurate data
- **Deletion** — request deletion of your data
- **Portability** — request your data in a portable format

To exercise any of these rights, contact us at **aleksander.ginalski@gmail.com**.

---

## 8. Children's Privacy

Friendsheet is not intended for children under the age of 13. We do not knowingly collect personal data from children. If you believe a child has provided us with personal data, please contact us and we will delete it.

---

## 9. Changes to This Policy

We may update this Privacy Policy from time to time. We will notify you of significant changes by updating the "Last updated" date at the top of this document. Continued use of the app after changes constitutes acceptance of the updated policy.

---

## 10. Contact

If you have any questions about this Privacy Policy, please contact us at:

**aleksander.ginalski@gmail.com**

---

*Friendsheet is an independent app developed as a personal portfolio project.*