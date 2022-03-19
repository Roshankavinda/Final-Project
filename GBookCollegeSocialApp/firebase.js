import * as firebase from "firebase";
import "firebase/firestore";


const app = firebase.initializeApp({
  apiKey: "AIzaSyCQazdLG0-UrcwwHsMWv8g1xyR2F1UPnSs",
  authDomain: "collegeapp-9a284.firebaseapp.com",
  projectId: "collegeapp-9a284",
  storageBucket: "collegeapp-9a284.appspot.com",
  messagingSenderId: "723049608751",
  appId: "1:723049608751:web:af72b7b64c9f65cbbb78da"
});

export const fireDB = app.firestore();
export default app;

