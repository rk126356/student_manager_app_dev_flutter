const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.generateBills = functions.https.onCall(async (data, context) => {
  try {
    const userId = data.userId;
    const firestore = admin.firestore();
    const usersCollection = firestore.collection('users');
    const studentsCollection = usersCollection.doc(userId).collection('students');
    const userDoc = await usersCollection.doc(userId).get();
    const paymentsCollection = usersCollection.doc(userId).collection('payments');

    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'User not found');
    }

    const studentDocs = await studentsCollection.get();
    const currentDate = new Date();

    for (const studentDoc of studentDocs.docs) {
      const studentData = studentDoc.data();
      const lastBillDate = studentData.lastBillDate ? parseDate(studentData.lastBillDate) : null;

      if (!lastBillDate) {
        throw new functions.https.HttpsError('invalid-argument', 'Student does not have a valid lastBillDate');
      }

      const monthsPassed = (currentDate.getMonth() - lastBillDate.getMonth()) +
        (12 * (currentDate.getFullYear() - lastBillDate.getFullYear()));

      if (monthsPassed <= 0) {
        continue;
      }

      // Add a check for isLeft property here
      if (studentData.isLeft === true) {
              continue; // Skip generating bills for this student
            }

      const feesCollection = studentsCollection.doc(studentDoc.id).collection('payments');

      for (let i = 0; i < monthsPassed; i++) {
        const nextBillDate = new Date(lastBillDate);
        nextBillDate.setMonth(lastBillDate.getMonth() + i + 1);

        const existingBillQuerySnapshot = await feesCollection
          .where('billDate', '==', nextBillDate.toISOString())
          .get();

        if (existingBillQuerySnapshot.empty) {
          // Generate a bill for this month and student
          const billData = {
            studentId: studentDoc.id,
            studentName: studentData.studentName,
            studentImageUrl: studentData.studentImageURL,
            studentBatch: studentData.studentBatch,
            chargePerMonth: studentData.chargePerMonth,
            // ... other bill data ...
            billDate: nextBillDate.toISOString(),
            isPaid: false,
          };
          await paymentsCollection.add(billData);
        }
      }

      // Update the lastBillDate and nextBillDate for this student
      const newLastBillDate = new Date(lastBillDate);
      newLastBillDate.setMonth(lastBillDate.getMonth() + monthsPassed);

      const newNextBillDate = new Date(newLastBillDate);
      newNextBillDate.setMonth(newLastBillDate.getMonth() + 1);

      await studentsCollection.doc(studentDoc.id).update({
        lastBillDate: formatDate(newLastBillDate),
        nextBillDate: formatDate(newNextBillDate),
      });
    }

    return { message: 'Bills generated successfully.' };
  } catch (error) {
    console.error('Error:', error);
    throw new functions.https.HttpsError('internal', 'An error occurred while generating bills.');
  }
});

// Function to parse date strings in the format "9/7/2023" into a Date object
function parseDate(dateString) {
  const parts = dateString.split('/');
  if (parts.length === 3) {
    const day = parseInt(parts[0]);
    const month = parseInt(parts[1]) - 1; // Months are 0-indexed (0 = January)
    const year = parseInt(parts[2]);
    return new Date(year, month, day);
  }
  return null; // Return null for invalid date strings
}

// Function to format a Date object as "dd/mm/yyyy"
function formatDate(date) {
  const day = date.getDate().toString().padStart(2, '0');
  const month = (date.getMonth() + 1).toString().padStart(2, '0'); // Months are 0-indexed
  const year = date.getFullYear().toString();
  return `${day}/${month}/${year}`;
}
