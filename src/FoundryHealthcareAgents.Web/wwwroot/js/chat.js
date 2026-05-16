(function () {
    const form = document.getElementById('chatForm');
    const input = document.getElementById('userInput');
    const messages = document.getElementById('chatMessages');
    const agentId = document.getElementById('agentId').value;
    const sendBtn = document.getElementById('sendBtn');

    let chatHistory = [];

    form.addEventListener('submit', async function (e) {
        e.preventDefault();
        const text = input.value.trim();
        if (!text) return;

        appendMessage('user', text);
        chatHistory.push({ role: 'user', content: text });
        input.value = '';
        sendBtn.disabled = true;

        const typing = showTyping();

        try {
            const response = await fetch('/Chat', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'RequestVerificationToken': getAntiForgeryToken()
                },
                body: JSON.stringify({ agentId: agentId, messages: chatHistory })
            });

            const data = await response.json();
            removeTyping(typing);

            appendMessage('assistant', data.reply);
            chatHistory.push({ role: 'assistant', content: data.reply });
        } catch (err) {
            removeTyping(typing);
            appendMessage('assistant', '⚠️ Failed to get a response. Please try again.');
        }

        sendBtn.disabled = false;
        input.focus();
    });

    input.addEventListener('keydown', function (e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            form.dispatchEvent(new Event('submit'));
        }
    });

    function appendMessage(role, content) {
        const div = document.createElement('div');
        div.className = 'message ' + role;
        div.innerHTML = '<div class="message-content">' + escapeHtml(content) + '</div>';
        messages.appendChild(div);
        messages.scrollTop = messages.scrollHeight;
    }

    function showTyping() {
        const div = document.createElement('div');
        div.className = 'message assistant typing';
        div.innerHTML = '<div class="typing-indicator"><span></span><span></span><span></span></div>';
        messages.appendChild(div);
        messages.scrollTop = messages.scrollHeight;
        return div;
    }

    function removeTyping(el) {
        if (el && el.parentNode) el.parentNode.removeChild(el);
    }

    function getAntiForgeryToken() {
        const el = document.querySelector('input[name="__RequestVerificationToken"]');
        return el ? el.value : '';
    }

    function escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
})();
