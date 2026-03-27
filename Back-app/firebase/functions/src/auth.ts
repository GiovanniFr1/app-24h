import * as admin from "firebase-admin";
import {auth} from "firebase-functions/v1";
import {onCall, HttpsError} from "firebase-functions/v2/https";

const db = admin.firestore();

/**
 * Triggered whenever a new user is created in Firebase Auth.
 * Creates the /users/{uid} document in Firestore with default values.
 */
export const onUserCreated = auth.user().onCreate(async (user) => {
  await db.collection("users").doc(user.uid).set({
    email: user.email ?? "",
    name: user.displayName ?? "",
    phone: user.phoneNumber ?? "",
    role: "passenger",
    fcmToken: null,
    profilePhotoUrl: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
});

/**
 * Callable: set the role (passenger | driver) for the current user.
 * Sets a custom claim on the Firebase Auth token and updates Firestore.
 */
export const setRole = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Must be authenticated.");
  }

  const data = request.data as {role: string; cpf?: string; cnh?: string};
  const validRoles = ["passenger", "driver"];

  if (!validRoles.includes(data.role)) {
    throw new HttpsError("invalid-argument", "Role must be passenger or driver.");
  }

  const uid = request.auth.uid;

  await admin.auth().setCustomUserClaims(uid, {role: data.role});

  const update: Record<string, unknown> = {role: data.role};

  if (data.role === "driver") {
    update.cpf = data.cpf ?? "";
    update.cnh = data.cnh ?? "";
    update.approvalStatus = "pending";
    update.rejectionReason = null;
    update.isVerified = false;
  }

  await db.collection("users").doc(uid).update(update);

  return {success: true};
});

/**
 * Callable: save the FCM token for the authenticated user.
 * Called by the mobile app on every login / app open.
 */
export const saveFcmToken = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Must be authenticated.");
  }

  const data = request.data as {token: string};

  await db.collection("users").doc(request.auth.uid).update({
    fcmToken: data.token,
  });

  return {success: true};
});
