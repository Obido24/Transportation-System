const supportTopics = {
  'help-center': {
    badge: 'Support Hub',
    icon: 'help_center',
    title: 'I-Metro Help Center',
    summary: 'Browse common support topics or jump straight to one of our live contact channels.',
    description: 'Use the official I-Metro help center to solve route, ticketing, accessibility, and account issues faster.',
    bullets: [
      'Support desk hours: Monday-Saturday, 9:00am-6:00pm',
      'Average formal ticket response: 4 business hours',
      'Contact channels: phone, WhatsApp, and email'
    ],
    meta: [
      'Best for: browsing articles',
      'Tickets are tracked through the support form',
      'Formal replies usually arrive within 4 business hours'
    ],
    quickActions: [
      { label: 'Ticketing & Payments', topic: 'payment-methods' },
      { label: 'Routes & Scheduling', topic: 'routes-schedule' },
      { label: 'Accessibility', topic: 'accessibility' },
      { label: 'Network Status', topic: 'network-status' }
    ],
    keywords: ['help center', 'support', 'articles', 'directory', 'contact', 'quick help']
  },
  'metropay-autoreload': {
    badge: 'Ticketing & Payments',
    icon: 'autorenew',
    title: 'How to set up MetroPay auto-reload',
    summary: 'Keep your wallet topped up automatically so you do not get blocked at the gate.',
    description: 'MetroPay auto-reload is available from the Wallet screen in the I-Metro app.',
    bullets: [
      'Open I-Metro > Wallet > MetroPay.',
      'Choose Auto-reload and link a supported debit or credit card.',
      'Set a trigger amount and recharge value.',
      'Save the setup and keep your payment confirmation for records.'
    ],
    note: 'Auto-reloads usually clear within a few minutes after payment authorization. If a station gate does not update immediately, wait a moment or refresh the app.',
    meta: [
      'Best for: frequent riders',
      'Reloads post after payment authorization',
      'You can disable auto-reload anytime'
    ],
    quickActions: [
      { label: 'Accepted payment methods', topic: 'payment-methods' },
      { label: 'Talk to support', topic: 'phone-support' }
    ],
    keywords: ['metropay', 'auto-reload', 'wallet', 'balance', 'recharge', 'top up']
  },
  'payment-methods': {
    badge: 'Ticketing & Payments',
    icon: 'payments',
    title: 'Accepted payment methods in station terminals',
    summary: 'Use MetroPay, bank cards, or contactless payments at supported gates and kiosks.',
    description: 'Station terminals and the I-Metro app accept the main payment options below. Availability can vary by station.',
    bullets: [
      'MetroPay wallet balance can be used across the network.',
      'Visa, Mastercard, and Verve cards are supported for app top-ups and selected terminal transactions.',
      'Contactless tap payments are available at enabled gates and kiosks.',
      'If a card is declined, try again after checking your bank app or use MetroPay.'
    ],
    note: 'For receipts or refund questions, keep your transaction ID and submit a support ticket.',
    meta: [
      'Best for: one-off top-ups',
      'Keep your transaction ID handy',
      'Refund requests need a ticket'
    ],
    quickActions: [
      { label: 'MetroPay auto-reload', topic: 'metropay-autoreload' },
      { label: 'Email support', topic: 'email-support' }
    ],
    keywords: ['payment', 'card', 'terminal', 'tap', 'wallet', 'metropay', 'accepted']
  },
  'routes-schedule': {
    badge: 'Routes & Scheduling',
    icon: 'route',
    title: 'Routes and scheduling help',
    summary: 'Find live route planning guidance, first and last service timing, and delay notices.',
    description: 'Use live route updates in the app to plan your trip and avoid service interruptions.',
    bullets: [
      'Check the live map before you travel for station-by-station updates.',
      'Planned timetable changes are published in the app and on the website when available.',
      'Enable route alerts to get notices about delays, diversions, and temporary stops.',
      'If you need help choosing the best route, search by station or destination in the app.'
    ],
    note: 'Service notices and disruption banners are updated as soon as operations confirm them.',
    meta: [
      'Best for: trip planning',
      'Enable route alerts',
      'Check the live map before travel'
    ],
    quickActions: [
      { label: 'Network status', topic: 'network-status' },
      { label: 'Accessibility', topic: 'accessibility' }
    ],
    keywords: ['routes', 'schedule', 'timetable', 'delay', 'live map', 'trip', 'departures']
  },
  'accessibility': {
    badge: 'Accessibility',
    icon: 'accessible_forward',
    title: 'Accessibility support at stations',
    summary: 'Plan step-free travel, request assistance, and check lift or ramp information.',
    description: 'I-Metro is designed to help commuters with mobility, visual, or hearing needs move more comfortably.',
    bullets: [
      'Look for step-free entrances, lifts, ramps, and accessible gates in station details.',
      'Request station assistance in advance when you need guided boarding or transfer support.',
      'Use the app to check accessibility status before you travel.',
      'If a lift or ramp is out of service, the network team will show the update in the status feed.'
    ],
    note: 'When assistance is needed, arrive a little earlier so staff can coordinate the most suitable route.',
    meta: [
      'Best for: step-free planning',
      'Check lift status before travel',
      'Request staff assistance in advance'
    ],
    quickActions: [
      { label: 'Routes & Scheduling', topic: 'routes-schedule' },
      { label: 'Phone support', topic: 'phone-support' }
    ],
    keywords: ['accessibility', 'disabled', 'wheelchair', 'lift', 'ramp', 'step free', 'assistance']
  },
  'safety-privacy': {
    badge: 'Safety & Privacy',
    icon: 'shield_person',
    title: 'Safety and privacy information',
    summary: 'Understand how I-Metro protects commuters and their trip data.',
    description: 'Safety, privacy, and data protection are built into the commuter experience.',
    bullets: [
      'Stations are monitored with standard security and support teams can escalate incidents quickly.',
      'The app keeps payment and account data encrypted when supported by your device and browser.',
      'Report suspicious behavior or safety concerns to station staff or support right away.',
      'Use your account privacy settings to manage notifications and saved devices.'
    ],
    note: 'Never share one-time codes or personal payment details in public chats.',
    meta: [
      'Best for: account protection',
      'Report safety issues immediately',
      'Keep OTPs private'
    ],
    quickActions: [
      { label: 'Email support', topic: 'email-support' },
      { label: 'Help Center', topic: 'help-center' }
    ],
    keywords: ['safety', 'privacy', 'security', 'data', 'report', 'incident', 'account']
  },
  'network-status': {
    badge: 'Service Status',
    icon: 'campaign',
    title: 'Network status and disruption updates',
    summary: 'Check planned maintenance, live incidents, and recovery notices.',
    description: 'The status feed shows active incidents and planned maintenance so you can decide whether to leave now or wait.',
    bullets: [
      'Planned maintenance is posted ahead of time whenever possible.',
      'Live incidents include the affected line or station, the start time, and the current recovery status.',
      'Use route alerts to receive updates while you are travelling.',
      'If a disruption affects your journey, support can help you find a safer alternate route.'
    ],
    note: 'For the latest operational notices, check the in-app status banner before departure.',
    meta: [
      'Best for: live service notices',
      'Check before leaving home',
      'Use route alerts for updates'
    ],
    quickActions: [
      { label: 'Routes & Scheduling', topic: 'routes-schedule' },
      { label: 'WhatsApp support', topic: 'whatsapp-support' }
    ],
    keywords: ['network', 'status', 'maintenance', 'disruption', 'incident', 'service', 'outage']
  },
  'phone-support': {
    badge: 'Direct support',
    icon: 'phone_in_talk',
    title: 'Phone support',
    summary: 'Call our toll-free line for urgent travel, payment, or account help.',
    description: 'Phone support is available Monday to Saturday, 9:00am to 6:00pm, for time-sensitive issues.',
    bullets: [
      'Toll-free line: +2347070050444',
      'Use this line for urgent trip disruptions, account lockouts, and payment checks.',
      'If your issue needs a record, the agent can help you submit a formal ticket after the call.'
    ],
    note: 'Average escalation response for formal tickets is 4 business hours.',
    meta: [
      'Best for: urgent issues',
      'Hours: Monday-Saturday, 9:00am-6:00pm',
      'Good for live trip support'
    ],
    quickActions: [
      { label: 'WhatsApp support', topic: 'whatsapp-support' },
      { label: 'Email support', topic: 'email-support' }
    ],
    keywords: ['phone', 'call', 'toll-free', 'hotline', 'support', 'urgent']
  },
  'whatsapp-support': {
    badge: 'Direct support',
    icon: 'chat',
    title: 'WhatsApp support',
    summary: 'Send a quick message when you need immediate guidance.',
    description: 'WhatsApp is best for riders who want fast answers without making a call.',
    bullets: [
      'Great for screenshot sharing, quick route checks, and ticketing questions.',
      'Have your route name, transaction ID, or station name ready to speed up the reply.',
      'For formal complaints, WhatsApp can point you to the support ticket form if needed.'
    ],
    note: 'Response times are usually fastest during operating hours.',
    meta: [
      'Best for: quick messages',
      'Share screenshots and IDs',
      'Fastest during operating hours'
    ],
    quickActions: [
      { label: 'Phone support', topic: 'phone-support' },
      { label: 'Email support', topic: 'email-support' }
    ],
    keywords: ['whatsapp', 'chat', 'message', 'quick', 'support', 'instant']
  },
  'email-support': {
    badge: 'Direct support',
    icon: 'mail',
    title: 'Email support',
    summary: 'Use email for detailed issues, documentation, and follow-up records.',
    description: 'Email is the right option when your issue needs attachments or a written trail.',
    bullets: [
      'Write to support@ridei-metro.com for complex enquiries and documentation.',
      'Include your full name, contact number, route name, and transaction ID when available.',
      'Attach screenshots or receipts so the team can investigate faster.'
    ],
    note: 'Formal ticket replies are usually returned within 4 business hours.',
    meta: [
      'Best for: detailed cases',
      'Attachments help investigations',
      'Written record for follow-up'
    ],
    quickActions: [
      { label: 'Help Center', topic: 'help-center' },
      { label: 'Phone support', topic: 'phone-support' }
    ],
    keywords: ['email', 'support', 'document', 'follow-up', 'attachment', 'ticket', 'written']
  }
};

const searchInput = document.getElementById('support-search-input');
const searchResults = document.getElementById('support-search-results');
const searchWrapper = searchInput?.parentElement;
const modal = document.getElementById('support-modal');
const modalEyebrow = document.getElementById('support-modal-eyebrow');
const modalTitle = document.getElementById('support-modal-title');
const modalSubtitle = document.getElementById('support-modal-subtitle');
const modalSummary = document.getElementById('support-modal-summary');
const modalContent = document.getElementById('support-modal-content');
const modalFooter = document.getElementById('support-modal-footer');
function escapeHtml(value) {
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function getTopics() {
  return Object.entries(supportTopics).map(([id, topic]) => ({ id, ...topic }));
}

function scoreTopic(topic, query) {
  const haystack = [topic.title, topic.summary, topic.description, ...(topic.keywords || [])].join(' ').toLowerCase();
  if (!haystack.includes(query)) return -1;

  let score = 0;
  const title = topic.title.toLowerCase();
  if (title.startsWith(query)) score += 6;
  if (title.includes(query)) score += 4;
  if ((topic.keywords || []).some(keyword => keyword.toLowerCase().includes(query))) score += 3;
  if ((topic.summary || '').toLowerCase().includes(query)) score += 2;
  if ((topic.description || '').toLowerCase().includes(query)) score += 1;
  return score;
}

function renderSearchResults(query) {
  if (!searchResults) return;
  const trimmed = query.trim().toLowerCase();

  if (!trimmed) {
    searchResults.innerHTML = '';
    searchResults.classList.add('hidden');
    searchInput?.setAttribute('aria-expanded', 'false');
    return;
  }

  const matches = getTopics()
    .map(topic => ({ ...topic, score: scoreTopic(topic, trimmed) }))
    .filter(topic => topic.score >= 0)
    .sort((a, b) => b.score - a.score || a.title.localeCompare(b.title))
    .slice(0, 5);

  if (!matches.length) {
    searchResults.innerHTML = `
      <div class="p-5">
        <p class="font-bold text-primary">No exact match found.</p>
        <p class="mt-1 text-sm text-on-surface-variant">Try searching for MetroPay, route delay, accessibility, or network status.</p>
        <div class="mt-4 flex flex-wrap gap-2">
          <button type="button" class="rounded-full border border-outline-variant/30 bg-surface px-4 py-2 text-sm font-semibold text-primary transition-colors hover:bg-surface-container" data-support-topic="help-center">Open Help Center</button>
          <button type="button" class="rounded-full border border-outline-variant/30 bg-surface px-4 py-2 text-sm font-semibold text-primary transition-colors hover:bg-surface-container" data-support-topic="payment-methods">Ticketing &amp; Payments</button>
          <button type="button" class="rounded-full border border-outline-variant/30 bg-surface px-4 py-2 text-sm font-semibold text-primary transition-colors hover:bg-surface-container" data-support-topic="routes-schedule">Routes &amp; Scheduling</button>
        </div>
      </div>
    `;
  } else {
    searchResults.innerHTML = `
      <div class="border-b border-outline-variant/30 bg-surface-container-low px-4 py-3">
        <p class="text-xs font-bold uppercase tracking-[0.2em] text-secondary">Quick matches</p>
        <p class="mt-1 text-sm text-on-surface-variant">Tap an article to open the official I-Metro support details.</p>
      </div>
      <div class="divide-y divide-outline-variant/30">
        ${matches.map(topic => `
          <button type="button" class="w-full px-4 py-4 text-left transition-colors hover:bg-surface-container" data-support-topic="${topic.id}">
            <div class="flex items-start justify-between gap-4">
              <div class="flex items-start gap-3">
                <span class="material-symbols-outlined mt-0.5 text-secondary">${topic.icon}</span>
                <div>
                  <p class="text-xs font-bold uppercase tracking-[0.2em] text-secondary">${escapeHtml(topic.badge)}</p>
                  <p class="mt-1 font-bold text-primary">${escapeHtml(topic.title)}</p>
                  <p class="mt-1 text-sm text-on-surface-variant">${escapeHtml(topic.summary)}</p>
                </div>
              </div>
              <span class="material-symbols-outlined text-outline-variant">chevron_right</span>
            </div>
          </button>
        `).join('')}
      </div>
    `;
  }

  searchResults.classList.remove('hidden');
  searchInput?.setAttribute('aria-expanded', 'true');
}

function renderTopic(topic) {
  if (!modal) return;
  modalEyebrow.textContent = topic.badge || 'I-Metro Support';
  modalTitle.textContent = topic.title;
  modalSubtitle.textContent = topic.summary || '';

  const summary = [
    topic.description ? `<p class="text-base leading-7 text-on-surface-variant">${escapeHtml(topic.description)}</p>` : '',
    topic.note ? `<p class="mt-3 rounded-xl border border-secondary-container/30 bg-secondary-container/20 p-4 text-sm text-on-surface-variant">${escapeHtml(topic.note)}</p>` : ''
  ].join('');

  const bullets = topic.bullets?.length
    ? `<div class="rounded-2xl border border-outline-variant/30 bg-surface-container-low p-5"><p class="text-sm font-bold uppercase tracking-[0.2em] text-secondary">What to know</p><ul class="mt-4 space-y-3">${topic.bullets.map(item => `<li class="flex gap-3 text-on-surface-variant"><span class="material-symbols-outlined mt-0.5 text-secondary">check_circle</span><span>${escapeHtml(item)}</span></li>`).join('')}</ul></div>`
    : '';

  const meta = topic.meta?.length
    ? topic.meta.map(item => `<div class="rounded-xl border border-outline-variant/30 bg-white px-4 py-3 text-sm text-on-surface-variant">${escapeHtml(item)}</div>`).join('')
    : '<div class="rounded-xl border border-outline-variant/30 bg-white px-4 py-3 text-sm text-on-surface-variant">Official I-Metro support information</div>';

  const quickActions = topic.quickActions?.length
    ? `<div class="space-y-3"><p class="text-sm font-bold uppercase tracking-[0.2em] text-secondary">Related topics</p>${topic.quickActions.map(action => `<button type="button" class="flex w-full items-center justify-between rounded-xl border border-outline-variant/30 bg-white px-4 py-3 text-left font-semibold text-primary transition-colors hover:bg-surface-container" data-support-topic="${action.topic}"><span>${escapeHtml(action.label)}</span><span class="material-symbols-outlined text-base">chevron_right</span></button>`).join('')}</div>`
    : '';

  modalSummary.innerHTML = summary;
  modalContent.innerHTML = bullets;
  modalFooter.innerHTML = `${meta}${quickActions ? `<div class="pt-3">${quickActions}</div>` : ''}`;

  modal.classList.remove('hidden');
  modal.classList.add('flex');
  document.body.classList.add('overflow-hidden');
}

function openSupportTopic(topicId) {
  renderTopic(supportTopics[topicId] || supportTopics['help-center']);
}

function closeSupportModal() {
  if (!modal) return;
  modal.classList.add('hidden');
  modal.classList.remove('flex');
  document.body.classList.remove('overflow-hidden');
}

searchInput?.addEventListener('focus', () => {
  if (searchWrapper) {
    searchWrapper.style.transform = 'scale(1.02)';
    searchWrapper.style.transition = 'transform 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275)';
  }
  renderSearchResults(searchInput.value);
});

searchInput?.addEventListener('blur', () => {
  if (searchWrapper) {
    searchWrapper.style.transform = 'scale(1)';
  }
});

searchInput?.addEventListener('input', event => {
  renderSearchResults(event.target.value);
});

searchInput?.addEventListener('keydown', event => {
  if (event.key === 'Enter') {
    event.preventDefault();
    const query = searchInput.value.trim().toLowerCase();
    const matches = getTopics()
      .map(topic => ({ ...topic, score: scoreTopic(topic, query) }))
      .filter(topic => topic.score >= 0)
      .sort((a, b) => b.score - a.score || a.title.localeCompare(b.title));
    openSupportTopic(matches[0]?.id || 'help-center');
  }

  if (event.key === 'Escape') {
    searchInput.value = '';
    renderSearchResults('');
  }
});

document.addEventListener('click', event => {
  const trigger = event.target.closest('[data-support-topic]');
  if (trigger) {
    if (trigger.tagName.toLowerCase() === 'a') {
      event.preventDefault();
    }
    openSupportTopic(trigger.dataset.supportTopic);
    return;
  }

  if (event.target.closest('[data-close-support-modal]')) {
    closeSupportModal();
  }
});

document.addEventListener('keydown', event => {
  const trigger = event.target.closest('[data-support-topic][role="button"]');
  if (trigger && (event.key === 'Enter' || event.key === ' ')) {
    event.preventDefault();
    openSupportTopic(trigger.dataset.supportTopic);
  }

  if (event.key === 'Escape' && modal && !modal.classList.contains('hidden')) {
    closeSupportModal();
  }
});

modal?.addEventListener('click', event => {
  if (event.target === modal) {
    closeSupportModal();
  }
});

document.getElementById('year').textContent = new Date().getFullYear();



const supportForm = document.getElementById('support-ticket-form');
const supportFormFeedback = document.getElementById('support-ticket-feedback');
const supportFormSubmit = document.getElementById('support-ticket-submit');
const supportNameInput = document.getElementById('support-full-name');
const supportEmailInput = document.getElementById('support-email');
const supportCategoryInput = document.getElementById('support-category');
const supportMessageInput = document.getElementById('support-message');
const supportPrivacyInput = document.getElementById('support-privacy-consent');

function getSupportApiUrl() {
  const configuredBase = typeof window !== 'undefined' && window.I_METRO_API_BASE_URL
    ? String(window.I_METRO_API_BASE_URL).trim().replace(/\/$/, '')
    : '';

  return `${configuredBase}/api/support/messages/public`;
}

function setFormFeedback(message, tone = 'success') {
  if (!supportFormFeedback) return;

  supportFormFeedback.textContent = message;
  supportFormFeedback.classList.remove('hidden', 'support-feedback-success', 'support-feedback-error', 'support-feedback-info');

  if (tone === 'success') {
    supportFormFeedback.classList.add('support-feedback-success');
  } else if (tone === 'error') {
    supportFormFeedback.classList.add('support-feedback-error');
  } else {
    supportFormFeedback.classList.add('support-feedback-info');
  }
}

async function submitSupportTicket(event) {
  event.preventDefault();

  if (!supportForm || !supportFormSubmit) return;

  const name = supportNameInput?.value.trim() ?? '';
  const email = supportEmailInput?.value.trim() ?? '';
  const subject = supportCategoryInput?.value.trim() ?? '';
  const message = supportMessageInput?.value.trim() ?? '';
  const consentGiven = Boolean(supportPrivacyInput?.checked);

  if (!name || !email || !subject || !message) {
    setFormFeedback('Please complete all required fields before submitting your support ticket.', 'error');
    return;
  }

  if (!consentGiven) {
    setFormFeedback('Please agree to the Privacy Policy before submitting your ticket.', 'error');
    return;
  }

  const originalLabel = supportFormSubmit.textContent?.trim() || 'Submit Support Ticket';
  supportFormSubmit.disabled = true;
  supportFormSubmit.textContent = 'Sending...';
  setFormFeedback('Sending your support ticket to the I-Metro team...', 'info');

  try {
    const response = await fetch(getSupportApiUrl(), {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        name,
        email,
        subject,
        message,
      }),
    });

    const data = await response.json().catch(() => ({}));

    if (!response.ok || data?.ok === false) {
      throw new Error(data?.reason || data?.message || `Request failed with status ${response.status}`);
    }

    supportForm.reset();
    setFormFeedback(
      `${data.notice || 'Your support ticket has been received.'}${data.id ? ` Ticket ID: ${data.id}.` : ''}`,
      'success'
    );
  } catch (error) {
    const messageText = error instanceof Error ? error.message : 'Unknown error';
    const friendlyMessage = messageText === 'Failed to fetch'
      ? 'We could not reach the support backend right now. Please try again in a moment.'
      : `We could not submit your ticket yet. ${messageText}`;
    setFormFeedback(friendlyMessage, 'error');
  } finally {
    supportFormSubmit.disabled = false;
    supportFormSubmit.textContent = originalLabel;
  }
}

supportForm?.addEventListener('submit', submitSupportTicket);
