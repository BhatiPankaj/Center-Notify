importScripts("https://www.gstatic.com/firebasejs/8.4.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.4.1/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyBJFvcjPubw6KUBHyNmHTtsW4gQRrNpvoc",
    authDomain: "center-notify.firebaseapp.com",
    projectId: "center-notify",
    storageBucket: "center-notify.appspot.com",
    messagingSenderId: "928875183682",
    appId: "1:928875183682:web:2c261ac59d41283427b7db"
  });

const messaging = firebase.messaging();


// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
//  alert("onBackgroundMessage");
});