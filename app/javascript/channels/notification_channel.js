import consumer from "channels/consumer";

consumer.subscriptions.create("NotificationChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("NotificationChannel connected");
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    const toastSpinner = document.querySelector("#toast-spinner");
    if (toastSpinner) {
      toastSpinner.innerText = `${data.message}\nClick here to view your sent messages and their statuses.`;
    }
    console.log("NotificationChannel received data:", data);
    // Called when there's incoming data on the websocket for this channel
  },
});
