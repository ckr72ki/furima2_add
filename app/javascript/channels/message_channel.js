import consumer from "./consumer"

consumer.subscriptions.create("MessageChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    console.log(data.user)
    const html = `<p>${data.user.nickname}:${data.content.text}</p>`
    // const html_user = `<p>${data.user.nickname}</p>`;
    const messages = document.getElementById('messages');
    const newMessage = document.getElementById('message_text');
    messages.insertAdjacentHTML('beforeend', html);
    newMessage.value='';
    }
});
