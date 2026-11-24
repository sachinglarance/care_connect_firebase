// Sends a push notification to a resident's family whenever a caregiver
// records a vital. Abnormal values get a warning title.
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();

// Keep in sync with VitalType in lib/models/resident.dart.
const VITALS = {
  heartRate: { label: 'Heart rate', unit: 'bpm', min: 50, max: 110 },
  temperature: { label: 'Temperature', unit: '°C', min: 36.1, max: 37.8 },
  oxygen: { label: 'SpO₂', unit: '%', min: 94, max: 100 },
  systolic: { label: 'Systolic BP', unit: 'mmHg', min: 90, max: 140 },
};

const STALE_TOKEN_ERRORS = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
]);

exports.notifyFamilyOnVital = onDocumentCreated('residents/{rid}/vitals/{vid}', async (event) => {
  const vital = event.data?.data();
  const meta = vital && VITALS[vital.type];
  if (!meta) return;

  const db = getFirestore();
  const resident = (await db.doc(`residents/${event.params.rid}`).get()).data();
  const emails = resident?.familyEmails ?? [];
  if (emails.length === 0) return;

  // Firestore `in` queries accept up to 30 values.
  const family = await db.collection('users').where('email', 'in', emails.slice(0, 30)).get();
  const tokens = family.docs.flatMap((d) => d.get('fcmTokens') ?? []);
  if (tokens.length === 0) return;

  const abnormal = vital.value < meta.min || vital.value > meta.max;
  const response = await getMessaging().sendEachForMulticast({
    tokens,
    notification: {
      title: abnormal ? `⚠️ ${resident.name}: please check vitals` : `${resident.name}: new vitals`,
      body: `${meta.label} ${vital.value} ${meta.unit}, recorded by ${vital.recordedBy}`,
    },
    data: { residentId: event.params.rid },
    android: { priority: abnormal ? 'high' : 'normal' },
  });

  // Remove tokens for uninstalled apps so the list doesn't grow forever.
  const stale = response.responses
    .map((r, i) => (!r.success && STALE_TOKEN_ERRORS.has(r.error?.code) ? tokens[i] : null))
    .filter(Boolean);
  if (stale.length > 0) {
    await Promise.all(family.docs.map((d) => d.ref.update({ fcmTokens: FieldValue.arrayRemove(...stale) })));
  }
});
