const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(); // Initialize Firebase Admin SDK

// Firebase Function to decrement nextBillInDays
exports.decrementNextBillInDays = functions.pubsub.schedule('every 20 minutes') // Run every 20 minutes
  .timeZone('Asia/Kolkata') // Set the timezone to IST
  .onRun(async (context) => {
    const firestore = admin.firestore();
    const usersCollection = firestore.collection('users');

    try {
      // Get all user documents
      const userDocs = await usersCollection.get();

      // Iterate through each user document
      userDocs.forEach(async (userDoc) => {
        const studentsCollection = userDoc.ref.collection('students');

        // Get all student documents for this user
        const studentDocs = await studentsCollection.get();

        // Update nextBillInDays for each student
        studentDocs.forEach(async (studentDoc) => {
          const studentData = studentDoc.data();

          if (studentData.nextBillInDays > 0) {
            await studentDoc.ref.update({
              nextBillInDays: studentData.nextBillInDays - 1
            });
          } else {
            // Set nextBillInDays to 30 if it's less than or equal to 0
            await studentDoc.ref.update({
              nextBillInDays: 2
            });
          }
        });
      });

      return null; // Success
    } catch (error) {
      console.error('Error updating nextBillInDays:', error);
      throw new Error('Failed to update nextBillInDays');
    }
  });
