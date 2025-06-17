$(document).ready(function () {
    'use strict';

    // --- Configuration & Global State ---
    const ADMIN_CREDENTIALS = {
        email: 'admin@grievance.com',
        password: 'AdminPass123'
    };

    const AppState = {
        loggedInEmail: sessionStorage.getItem('loggedInEmail'),
        isAdminLoggedIn: sessionStorage.getItem('isAdminLoggedIn') === 'true',
        complaints: JSON.parse(localStorage.getItem('complaints')) || [],
        nextId: parseInt(localStorage.getItem('nextId') || '1')
    };
    
    let performanceChartInstance = null; // To hold the chart object

    // --- UI Update Functions ---

    /**
     * Checks login status and updates the navigation bar accordingly.
     */
    function updateNav() {
        // Show logout link if either a regular user or an admin is logged in
        if (AppState.loggedInEmail || AppState.isAdminLoggedIn) {
            $('#logout-link').removeClass('d-none');
        } else {
            $('#logout-link').addClass('d-none');
        }
    }
    
    /**
     * Shows a modern, sleek toast notification.
     * @param {string} message The message to display.
     * @param {string} type 'success' or 'error'.
     */
    function showToast(message, type = 'success') {
        const toastId = `toast-${Date.now()}`;
        const toastHtml = `
            <div id="${toastId}" class="custom-toast bg-${type === 'error' ? 'danger' : 'success'}" role="alert" aria-live="assertive" aria-atomic="true">
                <div>${message}</div>
            </div>
        `;
        $('.toast-container').append(toastHtml);
        const toastElement = $(`#${toastId}`);
        
        // Animate in
        setTimeout(() => toastElement.addClass('show'), 10);
        
        // Animate out and remove
        setTimeout(() => {
            toastElement.removeClass('show');
            setTimeout(() => toastElement.remove(), 500);
        }, 3500);
    }

    // --- Core Logic & Validation ---

    function saveState() {
        localStorage.setItem('complaints', JSON.stringify(AppState.complaints));
        localStorage.setItem('nextId', AppState.nextId);
    }
    
    function getNextId() {
        const id = AppState.nextId;
        AppState.nextId++;
        saveState();
        return id;
    }

    function isValidEmail(email) {
        return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
    }

    function isValidPassword(pwd) {
        return /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,16}$/.test(pwd);
    }
    
    function handleFormValidation(form) {
        form.addClass('was-validated');
        return form[0].checkValidity();
    }


    // --- Page-Specific Initializers ---

    // 1. USER LOGIN PAGE
    if ($('#loginForm').length) {
        $('#loginForm').on('submit', function (e) {
            e.preventDefault();
            e.stopPropagation();

            const emailInput = $('#email');
            const passwordInput = $('#password');

            // Custom validation logic
            if (!isValidEmail(emailInput.val())) {
                emailInput.get(0).setCustomValidity("Invalid format.");
            } else {
                emailInput.get(0).setCustomValidity("");
            }

            if (!isValidPassword(passwordInput.val())) {
                passwordInput.get(0).setCustomValidity("Invalid format.");
            } else {
                passwordInput.get(0).setCustomValidity("");
            }

            if (!handleFormValidation($(this))) {
                return;
            }

            const email = $.trim(emailInput.val());
            const $btn = $(this).find('button[type="submit"]');
            $btn.prop('disabled', true).html('<span class="spinner-border spinner-border-sm" aria-hidden="true"></span> Logging in...');
            
            setTimeout(() => {
                sessionStorage.setItem('loggedInEmail', email);
                AppState.loggedInEmail = email;
                showToast('Login successful! Redirecting...');
                setTimeout(() => window.location.href = 'complaint-form.html', 1500);
            }, 800);
        });
    }

    // 2. ADMIN LOGIN PAGE
    if ($('#adminLoginForm').length) {
        $('#adminLoginForm').on('submit', function (e) {
            e.preventDefault();
            if (!handleFormValidation($(this))) return;

            const email = $.trim($('#adminEmail').val());
            const password = $('#adminPassword').val();
            const $btn = $(this).find('button[type="submit"]');

            $btn.prop('disabled', true).html('<span class="spinner-border spinner-border-sm" aria-hidden="true"></span> Verifying...');

            setTimeout(() => {
                if (email === ADMIN_CREDENTIALS.email && password === ADMIN_CREDENTIALS.password) {
                    sessionStorage.setItem('isAdminLoggedIn', 'true');
                    AppState.isAdminLoggedIn = true;
                    showToast('Admin login successful!');
                    setTimeout(() => window.location.href = 'admin-dashboard.html', 1500);
                } else {
                    showToast('Invalid admin credentials.', 'error');
                    $btn.prop('disabled', false).text('Login as Admin');
                }
            }, 800);
        });
    }
    
    // 3. LOGOUT (Works for both User and Admin)
    $('#logout').on('click', function (e) {
        e.preventDefault();
        sessionStorage.removeItem('loggedInEmail');
        sessionStorage.removeItem('isAdminLoggedIn');
        AppState.loggedInEmail = null;
        AppState.isAdminLoggedIn = false;
        showToast('You have been logged out.');
        setTimeout(() => window.location.href = 'index.html', 1500);
    });

    // 4. COMPLAINT FORM
    if ($('#complaintForm').length) {
        // Redirect if not logged in
        if (!AppState.loggedInEmail) {
            showToast('Please login to submit a complaint.', 'error');
            setTimeout(() => window.location.href = 'login.html', 1500);
            return;
        }

        $('#complaintForm').on('submit', function (e) {
            e.preventDefault();
            
            const descriptionInput = $('#description');
            if ($.trim(descriptionInput.val()).length < 15) {
                descriptionInput.get(0).setCustomValidity("Too short.");
            } else {
                descriptionInput.get(0).setCustomValidity("");
            }

            if (!handleFormValidation($(this))) return;

            const newComplaint = {
                id: getNextId(),
                email: AppState.loggedInEmail,
                category: $('#category').val(),
                description: $.trim(descriptionInput.val()),
                status: 'Pending',
                attachment: $('#attachment')[0].files[0] ? $('#attachment')[0].files[0].name : null,
                date: new Date().toISOString()
            };

            AppState.complaints.push(newComplaint);
            saveState();

            showToast(`Complaint submitted! Your ID is ${newComplaint.id}`);
            setTimeout(() => window.location.href = 'status-tracking.html', 2000);
        });
    }

    // 5. STATUS TRACKING
    if ($('#statusForm').length) {
        $('#statusForm').on('submit', function(e) {
            e.preventDefault();
            if (!handleFormValidation($(this))) return;

            const input = $.trim($('#complaintId').val()).toLowerCase();
            const results = AppState.complaints.filter(c => c.id.toString() === input || c.email.toLowerCase() === input);

            const getStatusBadge = (status) => {
                const statusMap = {
                    'Pending': 'bg-warning text-dark',
                    'In Progress': 'bg-info text-dark',
                    'Resolved': 'bg-success'
                };
                return `<span class="badge ${statusMap[status] || 'bg-secondary'}">${status}</span>`;
            };
            
            const statusResultDiv = $('#statusResult');
            statusResultDiv.empty().hide();

            if (results.length > 0) {
                results.forEach(result => {
                    statusResultDiv.append(`
                        <div class="alert alert-light mt-4" style="background-color: rgba(255,255,255,0.1); border-color: rgba(255,255,255,0.2);">
                            <h5 class="alert-heading">Status for Complaint #${result.id}</h5>
                            <p><strong>Category:</strong> ${result.category}</p>
                            <p class="mb-0"><strong>Status:</strong> ${getStatusBadge(result.status)}</p>
                        </div>
                    `);
                });
                statusResultDiv.fadeIn();
            } else {
                showToast('No matching complaint found.', 'error');
            }
        });
    }

    // 6. ADMIN DASHBOARD
    if ($('#adminDashboard').length) {
        // --- SECURITY GUARD ---
        // If not logged in as admin, redirect immediately.
        if (!AppState.isAdminLoggedIn) {
            showToast('Access Denied. Please log in as an admin.', 'error');
            setTimeout(() => window.location.href = 'admin-login.html', 1500);
            return; // Stop executing any further code on this page
        }

        const complaintModal = new bootstrap.Modal(document.getElementById('viewComplaintModal'));

        function populateTable() {
            const tbody = $('#complaintTable tbody');
            tbody.empty();
            if (AppState.complaints.length === 0) {
                tbody.html('<tr><td colspan="4" class="text-center text-muted py-4">No complaints have been submitted yet.</td></tr>');
                return;
            }
            // Display newest complaints first
            [...AppState.complaints].reverse().forEach(c => {
                tbody.append(`
                    <tr>
                        <td><strong>#${c.id}</strong></td>
                        <td>${c.category}</td>
                        <td>
                            <select class="form-select form-select-sm status-select" data-id="${c.id}" aria-label="Update status">
                                <option value="Pending" ${c.status === 'Pending' ? 'selected' : ''}>Pending</option>
                                <option value="In Progress" ${c.status === 'In Progress' ? 'selected' : ''}>In Progress</option>
                                <option value="Resolved" ${c.status === 'Resolved' ? 'selected' : ''}>Resolved</option>
                            </select>
                        </td>
                        <td class="text-end">
                            <button class="btn btn-sm btn-outline-light view-btn" data-id="${c.id}">View</button>
                        </td>
                    </tr>
                `);
            });
        }

        function updateChart() {
            const statusCounts = AppState.complaints.reduce((acc, c) => {
                acc[c.status] = (acc[c.status] || 0) + 1;
                return acc;
            }, { 'Resolved': 0, 'Pending': 0, 'In Progress': 0 });

            const chartData = {
                labels: ['Resolved', 'Pending', 'In Progress'],
                datasets: [{
                    label: 'Complaints',
                    data: [statusCounts.Resolved, statusCounts.Pending, statusCounts['In Progress']],
                    backgroundColor: ['rgba(80, 227, 194, 0.7)', 'rgba(255, 193, 7, 0.7)', 'rgba(79, 193, 233, 0.7)'],
                    borderColor: ['#50e3c2', '#ffc107', '#4fc1e9'],
                    borderWidth: 2,
                }]
            };

            const ctx = document.getElementById('performanceChart');
            if (!ctx) return; // Don't proceed if canvas doesn't exist

            if (performanceChartInstance) {
                performanceChartInstance.data = chartData;
                performanceChartInstance.update();
            } else {
                performanceChartInstance = new Chart(ctx.getContext('2d'), {
                    type: 'doughnut',
                    data: chartData,
                    options: {
                        responsive: true,
                        plugins: {
                            legend: { position: 'top', labels: { color: 'white' } },
                            title: { display: false }
                        },
                        cutout: '70%'
                    }
                });
            }
        }
        
        // Event listeners for Admin page
        $(document).on('change', '.status-select', function () {
            const id = $(this).data('id');
            const newStatus = $(this).val();
            const complaint = AppState.complaints.find(c => c.id == id);
            if (complaint) {
                complaint.status = newStatus;
                saveState();
                updateChart();
                showToast(`Status for #${id} updated.`);
            }
        });

        $(document).on('click', '.view-btn', function () {
            const id = $(this).data('id');
            const complaint = AppState.complaints.find(c => c.id == id);
            if (complaint) {
                const formattedDate = new Date(complaint.date).toLocaleString();
                $('#modalBodyContent').html(`
                    <p><strong>Complaint ID:</strong> #${complaint.id}</p>
                    <p><strong>User Email:</strong> ${complaint.email}</p>
                    <p><strong>Date Submitted:</strong> ${formattedDate}</p>
                    <p><strong>Category:</strong> ${complaint.category}</p>
                    <p><strong>Status:</strong> ${complaint.status}</p>
                    <hr class="border-secondary">
                    <p><strong>Description:</strong></p>
                    <p class="bg-dark p-2 rounded" style="white-space: pre-wrap; word-wrap: break-word;">${complaint.description}</p>
                    <p><strong>Attachment:</strong> ${complaint.attachment || 'None'}</p>
                `);
                complaintModal.show();
            }
        });

        // Initial load for admin dashboard
        populateTable();
        updateChart();
    }

    // --- Global Initialization ---
    updateNav();
});