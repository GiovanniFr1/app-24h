import * as admin from "firebase-admin";

// Initialize Firebase Admin SDK once
admin.initializeApp();

// Sprint 5: Auth & User Model
export * from "./auth";

// Sprint 5: Admin backoffice (driver approval)
export * from "./admin";

// Sprint 7: Trip lifecycle & matching
// export * from "./trips";
// export * from "./matching";

// Sprint 8: Push notifications
// export * from "./notifications";

// Sprint 9: Pagar.me payment
// export * from "./payments";
