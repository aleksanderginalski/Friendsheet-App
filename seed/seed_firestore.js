const admin = require("firebase-admin");
const data = require("./global_categories.json");

// Replace with path to your service account key
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function seed() {
    const batch = db.batch();

    data.forEach((category) => {
        const ref = db.collection("activity_categories").doc(category.id);
        batch.set(ref, category);
    });

    await batch.commit();
    console.log(`Seeded ${data.length} global categories.`);
}

seed().catch(console.error);