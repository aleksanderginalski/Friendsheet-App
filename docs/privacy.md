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

### 2.5 AI Assistant Data (optional)

If you choose to use the AI Assistant feature, a summary of your social activity data
is sent to **OpenAI's API** on your behalf. This data is prepared on-device and anonymized
before sending:

**Always sent to OpenAI (when you use the AI Assistant):**
- Meeting list: name, date, and activity categories for each meeting in the last 12 months
- Social graph summary: meeting counts per friend, last meeting date, most common activities, most active month
- All friend names are replaced with generic identifiers (Friend_A, Friend_B, ...) before
  the data leaves your device — OpenAI never receives real names

**Sent only when you explicitly enter notes collection mode (Mode 1):**
- Meeting notes — only when you open the AI Assistant specifically to add or review notes
  for a meeting. Notes are never sent during free queries (Mode 3) or friend-context queries (Mode 2).

**Never sent to OpenAI:**
- Your real name or your friends' real names
- Raw Firestore data or any data not explicitly listed above
- Your email address, Google UID, or any account credentials

The AI Assistant uses your **own OpenAI API key** (BYOK — Bring Your Own Key). We do not
proxy your requests through our servers. Your API key is stored exclusively on your device
using Android Keystore-backed secure storage and is never written to Firestore or logs.
It authenticates directly with OpenAI's API from your device — Friendsheet servers never see it.

You must explicitly accept this data processing before using the AI Assistant.
You can withdraw consent at any time by deleting your API key in Settings → AI Assistant.

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

### 5.1 Sharing meetings with friends

When you choose to share meetings with a linked friend using the "Send meetings" feature, the following data is sent to your friend's account:

- Meeting name, date, and weight
- Your sender signature (first name, last name, optional nickname)
- Optionally: first name and last name of other meeting participants (if you choose to include them)
- Optionally: activity names associated with the meetings (if you choose to include them)

**What is never shared:** notes, nicknames of participants, or any other contact details beyond first and last name.

You will be shown a privacy notice and asked to confirm before any data is sent. Sharing is always an explicit, opt-in action.

---

## 6. Data Retention and Deletion
 
Your data is retained for as long as you use the app.
 
**You can permanently delete your account and all associated data directly from the app:**
Settings → Delete Account
 
This will immediately and permanently remove:
- All your meetings, friends, and activity categories from Firestore
- Your account from Firebase Authentication
- All locally cached data (preferences, OAuth tokens, statistics cache)
 
This action is irreversible. Once deleted, your data cannot be recovered.
 
You may also request deletion by contacting us at **aleksander.ginalski@gmail.com**.

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