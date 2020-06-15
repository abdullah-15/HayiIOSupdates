const functions = require('firebase-functions');
const Firestore = require('@google-cloud/firestore');

const firestore = new Firestore();

exports.onUserStatusChanged = functions.database.ref('/user/{uid}/status') // Reference to the Firebase RealTime database key
  .onUpdate( async (change,context) => {

// Get the data written to Realtime Database
      const eventStatus = change.after.val();

      // Then use other event data to create a reference to the
      // corresponding Firestore document.
      const userStatusFirestoreRef = firestore.doc(`User/${context.params.uid}`);

      // It is likely that the Realtime Database change that triggered
      // this event has already been overwritten by a fast change in
      // online / offline status, so we'll re-read the current data
      // and compare the timestamps.
      const statusSnapshot = await change.after.ref.once('value');
      const status = statusSnapshot.val();
      console.log(status, eventStatus);
      // If the current timestamp for this data is newer than
      // the data that triggered this event, we exit this function.

	userStatusFirestoreRef.update({isOnline: eventStatus})


      // ... and write it to Firestore.

      return userStatusFirestoreRef
  });
