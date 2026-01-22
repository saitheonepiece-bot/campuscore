// Utility Functions

// Modal System Functions
function showModal(title, message, type = 'info') {
    const existingModal = document.querySelector('.modal-overlay');
    if (existingModal) {
        existingModal.remove();
    }

    const icons = {
        success: '✓',
        error: '✕',
        warning: '⚠',
        info: 'ℹ'
    };

    const icon = icons[type] || icons.info;

    const modalOverlay = document.createElement('div');
    modalOverlay.className = 'modal-overlay';
    modalOverlay.innerHTML = `
        <div class="modal-content">
            <div class="modal-header">
                <div class="modal-icon ${type}">${icon}</div>
                <h3 class="modal-title">${title}</h3>
            </div>
            <div class="modal-message">${message}</div>
            <div class="modal-buttons">
                <button class="modal-btn modal-btn-confirm" onclick="closeModal()">OK</button>
            </div>
        </div>
    `;

    document.body.appendChild(modalOverlay);

    modalOverlay.addEventListener('click', (e) => {
        if (e.target === modalOverlay) {
            closeModal();
        }
    });

    const escHandler = (e) => {
        if (e.key === 'Escape') {
            closeModal();
            document.removeEventListener('keydown', escHandler);
        }
    };
    document.addEventListener('keydown', escHandler);
}

function showConfirm(title, message, onConfirm, onCancel = null, confirmText = 'Confirm', cancelText = 'Cancel', isDangerous = false) {
    const existingModal = document.querySelector('.modal-overlay');
    if (existingModal) {
        existingModal.remove();
    }

    const modalOverlay = document.createElement('div');
    modalOverlay.className = 'modal-overlay';

    const confirmBtnClass = isDangerous ? 'modal-btn-danger' : 'modal-btn-confirm';

    modalOverlay.innerHTML = `
        <div class="modal-content">
            <div class="modal-header">
                <div class="modal-icon warning">⚠</div>
                <h3 class="modal-title">${title}</h3>
            </div>
            <div class="modal-message">${message}</div>
            <div class="modal-buttons">
                <button class="modal-btn modal-btn-cancel" onclick="closeModal(false)">${cancelText}</button>
                <button class="modal-btn ${confirmBtnClass}" onclick="closeModal(true)">${confirmText}</button>
            </div>
        </div>
    `;

    document.body.appendChild(modalOverlay);

    window._modalConfirmCallback = onConfirm;
    window._modalCancelCallback = onCancel;

    modalOverlay.addEventListener('click', (e) => {
        if (e.target === modalOverlay) {
            closeModal(false);
        }
    });

    const escHandler = (e) => {
        if (e.key === 'Escape') {
            closeModal(false);
            document.removeEventListener('keydown', escHandler);
        }
    };
    document.addEventListener('keydown', escHandler);
}

function closeModal(confirmed = null) {
    const modalOverlay = document.querySelector('.modal-overlay');
    if (modalOverlay) {
        modalOverlay.remove();
    }

    if (confirmed === true && window._modalConfirmCallback) {
        window._modalConfirmCallback();
        delete window._modalConfirmCallback;
        delete window._modalCancelCallback;
    } else if (confirmed === false && window._modalCancelCallback) {
        window._modalCancelCallback();
        delete window._modalConfirmCallback;
        delete window._modalCancelCallback;
    }
}

// Date formatting
function formatDate(date) {
    if (typeof date === 'string') {
        date = new Date(date);
    }
    return date.toLocaleDateString('en-IN');
}

// Get today's date in YYYY-MM-DD format
function getTodayDate() {
    return new Date().toISOString().split('T')[0];
}

// Loading spinner
function showLoading() {
    const existingLoader = document.querySelector('.loading-overlay');
    if (existingLoader) return;

    const loader = document.createElement('div');
    loader.className = 'loading-overlay';
    loader.innerHTML = `
        <div class="loading-spinner">
            <div class="spinner"></div>
            <p class="loading-text">Loading...</p>
        </div>
    `;
    document.body.appendChild(loader);
}

function hideLoading() {
    const loader = document.querySelector('.loading-overlay');
    if (loader) {
        loader.remove();
    }
}

// Export functions to window object
window.showModal = showModal;
window.showConfirm = showConfirm;
window.closeModal = closeModal;
window.formatDate = formatDate;
window.getTodayDate = getTodayDate;
window.showLoading = showLoading;
window.hideLoading = hideLoading;
