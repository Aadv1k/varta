console.log("FROM: firebase-messaging-sw.js");

importScripts('https://www.gstatic.com/firebasejs/11.0.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/11.0.2/firebase-messaging-compat.js');

const firebaseConfig = {
  "apiKey": "AIzaSyBEdzTqFWw6wSHd_v84ePkNl2BTVQcjebI",
  "authDomain": "varta-app-5f6ac.firebaseapp.com",
  "projectId": "varta-app-5f6ac",
  "storageBucket": "varta-app-5f6ac.firebasestorage.app",
  "messagingSenderId": "791653531041",
  "appId": "1:791653531041:web:aabee4aa7b9047c6d7dfe0"
};

firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();

messaging.onMessage(function(payload) {
    console.log(payload)
});

messaging.onBackgroundMessage(function(payload) {
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: "/icons/icon-192.png",
        badge: "/icons/icon-192.png",
    };

    return self.registration.showNotification(notificationTitle, notificationOptions);
});
