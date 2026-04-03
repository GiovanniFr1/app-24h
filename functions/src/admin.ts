import * as admin from "firebase-admin";
import {onCall, HttpsError, CallableRequest} from "firebase-functions/v2/https";

const db = admin.firestore();

/**
 * Helper: verify the caller has the 'admin' custom claim.
 */
function assertAdmin(request: CallableRequest): void {
  if (!request.auth || request.auth.token["role"] !== "admin") {
    throw new HttpsError("permission-denied", "Only admins can perform this action.");
  }
}

/**
 * Callable: approve a driver registration.
 * Sets approvalStatus = 'approved', isVerified = true.
 * Sends FCM push notification to the driver.
 */
export const approveDriver = onCall(async (request) => {
  assertAdmin(request);

  const data = request.data as {uid: string};
  if (!data.uid) {
    throw new HttpsError("invalid-argument", "uid is required.");
  }

  const userRef = db.collection("users").doc(data.uid);
  const userSnap = await userRef.get();

  if (!userSnap.exists) {
    throw new HttpsError("not-found", "Driver not found.");
  }

  await userRef.update({
    approvalStatus: "approved",
    isVerified: true,
    rejectionReason: null,
    approvedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  const fcmToken = userSnap.data()?.fcmToken as string | null;
  if (fcmToken) {
    await admin.messaging().send({
      token: fcmToken,
      notification: {
        title: "Cadastro aprovado!",
        body: "Seu cadastro foi aprovado. Já pode aceitar corridas.",
      },
      data: {type: "driver_approved"},
    });
  }

  return {success: true};
});

/**
 * Callable: reject a driver registration.
 * Sets approvalStatus = 'rejected', stores rejection reason.
 * Sends FCM push notification to the driver.
 */
export const rejectDriver = onCall(async (request) => {
  assertAdmin(request);

  const data = request.data as {uid: string; reason: string};
  if (!data.uid) {
    throw new HttpsError("invalid-argument", "uid is required.");
  }

  const userRef = db.collection("users").doc(data.uid);
  const userSnap = await userRef.get();

  if (!userSnap.exists) {
    throw new HttpsError("not-found", "Driver not found.");
  }

  await userRef.update({
    approvalStatus: "rejected",
    isVerified: false,
    rejectionReason: data.reason ?? "Não informado.",
    rejectedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  const fcmToken = userSnap.data()?.fcmToken as string | null;
  if (fcmToken) {
    await admin.messaging().send({
      token: fcmToken,
      notification: {
        title: "Cadastro recusado",
        body: data.reason ?? "Seu cadastro foi recusado.",
      },
      data: {type: "driver_rejected"},
    });
  }

  return {success: true};
});

/**
 * Callable: grant admin role to a user.
 * Can only be called by an existing admin.
 */
export const setAdminRole = onCall(async (request) => {
  assertAdmin(request);

  const data = request.data as {uid: string};
  if (!data.uid) {
    throw new HttpsError("invalid-argument", "uid is required.");
  }

  await admin.auth().setCustomUserClaims(data.uid, {role: "admin"});
  await db.collection("users").doc(data.uid).update({role: "admin"});

  return {success: true};
});
